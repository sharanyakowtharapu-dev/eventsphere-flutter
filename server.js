
const express = require("express");
const cors = require("cors");
const mysql = require("mysql2/promise");
require("dotenv").config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT) || 3306,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10
});

// Health check
app.get("/", (req, res) => {
  res.json({ message: "EventSphere backend is running!" });
});

app.get("/api/health", (req, res) => {
  res.json({ status: "OK" });
});

// Database test
app.get("/api/db-test", async (req, res) => {
  try {
    const [rows] = await pool.query("SELECT 1 AS connected");
    res.json({ database: "connected", result: rows[0].connected });
  } catch (error) {
    console.error("Database test failed:", error.message);
    res.status(500).json({ database: "disconnected" });
  }
});

// Get all events
app.get("/api/events", async (req, res) => {
  try {
    const [events] = await pool.query(
      "SELECT * FROM events ORDER BY event_date, start_time"
    );
    res.json(events);
  } catch (error) {
    console.error("Fetch events failed:", error.message);
    res.status(500).json({ error: "Unable to fetch events" });
  }
});

// Get one event
app.get("/api/events/:id", async (req, res) => {
  try {
    const id = Number(req.params.id);

    if (!Number.isInteger(id) || id < 1) {
      return res.status(400).json({ error: "Invalid event ID" });
    }

    const [events] = await pool.execute(
      "SELECT * FROM events WHERE id = ?",
      [id]
    );

    if (!events.length) {
      return res.status(404).json({ error: "Event not found" });
    }

    res.json(events[0]);
  } catch (error) {
    console.error("Fetch event failed:", error.message);
    res.status(500).json({ error: "Unable to fetch event" });
  }
});

// Create an event
app.post("/api/events", async (req, res) => {
  try {
    const {
      title, category, description, event_date,
      start_time, end_time, location, organizer_id
    } = req.body;

    if (!title || !String(title).trim()) {
      return res.status(400).json({ error: "Event title is required" });
    }

    const organizerId =
      organizer_id === undefined || organizer_id === null
        ? null
        : Number(organizer_id);

    if (
      organizerId !== null &&
      (!Number.isInteger(organizerId) || organizerId < 1)
    ) {
      return res.status(400).json({ error: "Invalid organizer ID" });
    }

    const [result] = await pool.execute(
      `INSERT INTO events
       (title, category, description, event_date, start_time,
        end_time, location, organizer_id)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        String(title).trim(),
        category || null,
        description || null,
        event_date || null,
        start_time || null,
        end_time || null,
        location || null,
        organizerId
      ]
    );

    const [events] = await pool.execute(
      "SELECT * FROM events WHERE id = ?",
      [result.insertId]
    );

    res.status(201).json(events[0]);
  } catch (error) {
    console.error("Create event failed:", error.message);
    res.status(500).json({ error: "Unable to create event" });
  }
});

// Start server
async function startServer() {
  try {
    const connection = await pool.getConnection();
    await connection.ping();
    connection.release();

    app.listen(PORT, "0.0.0.0", () => {
      console.log(`EventSphere backend running on port ${PORT}`);
      console.log("MySQL connection successful");
    });
  } catch (error) {
    console.error("MySQL connection failed:", error.message);
    process.exit(1);
  }
}

startServer();
