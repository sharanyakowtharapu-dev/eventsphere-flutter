import 'package:flutter/material.dart';
import 'storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EventStore.initialize();
  final stored = await EventStore.loadState();
  if (stored.eventMaps.isNotEmpty) { appEvents..clear()..addAll(stored.eventMaps.map(EventItem.fromMap)); } else { await EventStore.saveEvents(appEvents.map((e) => e.toMap()).toList()); }
  appSavedEvents..clear()..addAll(stored.savedTitles);
  appRegisteredEventTitles..clear()..addAll(stored.registeredTitles);
  runApp(const EventSphereApp());
}

const navy = Color(0xFF14265D);
const navyDark = Color(0xFF101A3A);
const blue = Color(0xFF246BFD);
const purple = Color(0xFF8067E8);
const pale = Color(0xFFF3F7FF);
const ink = Color(0xFF18213D);
const muted = Color(0xFF77809A);
const teal = Color(0xFF16A887);
const orange = Color(0xFFF59B31);
const pink = Color(0xFFF05C8B);

class EventSphereApp extends StatelessWidget {
  const EventSphereApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'EventSphere',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: pale,
      colorScheme: ColorScheme.fromSeed(seedColor: blue),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 16, color: ink),
        bodyMedium: TextStyle(fontSize: 14, color: ink),
        bodySmall: TextStyle(fontSize: 14, color: muted),
        titleLarge: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: ink),
        titleMedium: TextStyle(fontSize: 21, fontWeight: FontWeight.w700, color: ink),
        titleSmall: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: ink),
        labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        labelMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: pale,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    ),
    home: const SplashScreen(),
  );
}

class EventItem {
  final String title, category, date, time, venue, description, organizer;
  final Color color;
  const EventItem({
    required this.title,
    required this.category,
    required this.date,
    required this.time,
    required this.venue,
    required this.description,
    required this.color,
    this.organizer = 'Campus Events Club',
  });

  Map<String, Object?> toMap() => {
    'title': title, 'category': category, 'date': date, 'time': time,
    'venue': venue, 'description': description, 'organizer': organizer,
    'color': color.value,
  };

  factory EventItem.fromMap(Map<String, Object?> map) => EventItem(
    title: map['title'] as String? ?? '',
    category: map['category'] as String? ?? 'Technology',
    date: map['date'] as String? ?? '',
    time: map['time'] as String? ?? '',
    venue: map['venue'] as String? ?? '',
    description: map['description'] as String? ?? '',
    organizer: map['organizer'] as String? ?? 'Campus Events Club',
    color: Color((map['color'] as num?)?.toInt() ?? 0xFF4268D6),
  );
}

const demoEvents = <EventItem>[
  EventItem(
    title: 'TechFest 2026', category: 'Technology', date: '20 Jan 2026',
    time: '10:00 AM – 4:00 PM', venue: 'Main Auditorium, DIET',
    description: 'Innovate, build, and connect. Explore new technologies, AI demonstrations, student projects, and talks from industry speakers.',
    color: Color(0xFF4268D6), organizer: 'Tech Club',
  ),
  EventItem(
    title: 'AI Workshop Series', category: 'Workshop', date: '15 Jan 2026',
    time: '10:00 AM – 4:00 PM', venue: 'Main Auditorium, DIET',
    description: 'A hands-on workshop on AI applications. Learn from practical demonstrations and build your first mini project.',
    color: Color(0xFF725CE0), organizer: 'Data Science Club',
  ),
  EventItem(
    title: 'Cultural Night', category: 'Cultural', date: '18 Jan 2026',
    time: '6:00 PM – 9:00 PM', venue: 'Open Air Stage',
    description: 'Enjoy music, dance, performances, and an evening celebrating campus creativity and community.',
    color: Color(0xFFE26C91), organizer: 'Cultural Club',
  ),
  EventItem(
    title: 'Data Science Workshop', category: 'Workshop', date: '02 Nov 2026',
    time: '9:30 AM – 1:00 PM', venue: 'Lab Block B',
    description: 'Explore data preparation, machine learning, and practical data science workflows.',
    color: Color(0xFF208D83), organizer: 'Data Science Club',
  ),
  EventItem(
    title: 'Intercollege Sports Meet', category: 'Sports', date: '06 Nov 2026',
    time: '8:00 AM – 5:00 PM', venue: 'Main Sports Ground',
    description: 'Celebrate friendly competition, team spirit, and campus sports.',
    color: Color(0xFFD58A3A), organizer: 'Sports Committee',
  ),
];

// Persistent local store: SQLite on Android, browser storage on Chrome.
final List<EventItem> appEvents = List<EventItem>.from(demoEvents);
final Set<String> appSavedEvents = <String>{};
final Set<String> appRegisteredEventTitles = <String>{};

DateTime? _eventDate(EventItem event) {
  try { final parts = event.date.split(' '); return DateTime(int.parse(parts[2]), _monthNumber(parts[1]), int.parse(parts[0])); } catch (_) { return null; }
}
int _monthNumber(String month) {
  const months = {'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6, 'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12};
  return months[month] ?? 1;
}

class OrbitLogo extends StatelessWidget {
  final double size;
  const OrbitLogo({super.key, this.size = 46});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: CustomPaint(painter: PlanetPainter()),
  );
}

class PlanetPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100;
    canvas.save();
    canvas.scale(scale);
    final center = const Offset(48, 53);
    final planetRect = Rect.fromCircle(center: center, radius: 28);
    final planetPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFB65AFF), Color(0xFF5266E9), Color(0xFF1A3C9D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(planetRect);
    canvas.drawCircle(center, 28, planetPaint);
    final stripe = Paint()
      ..color = const Color(0xFF172B78).withOpacity(.48)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;
    canvas.drawArc(Rect.fromCircle(center: center, radius: 18), .25, 2.55, false, stripe);
    final orbit = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFD46BFF), Color(0xFF6B67FF), Color(0xFF1D4CA8)],
      ).createShader(const Rect.fromLTWH(4, 20, 92, 65))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.save();
    canvas.translate(48, 53);
    canvas.rotate(-.42);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 92, height: 31), orbit);
    canvas.restore();
    final starPaint = Paint()..color = const Color(0xFF342B9A);
    final star = Path()
      ..moveTo(82, 13)..lineTo(87, 23)..lineTo(97, 28)
      ..lineTo(87, 32)..lineTo(82, 42)..lineTo(77, 32)
      ..lineTo(67, 28)..lineTo(77, 23)..close();
    canvas.drawPath(star, starPaint);
    canvas.drawCircle(const Offset(82, 28), 3, Paint()..color = Colors.white);
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF101947), Color(0xFF202B72), Color(0xFF111B42)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Spacer(),
              const OrbitLogo(size: 150),
              const SizedBox(height: 18),
              const Text('EventSphere', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              const Text('Smart Events.\nBetter Experiences.', textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 18, height: 1.5)),
              const Spacer(),
              Container(
                height: 100, width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(colors: [Color(0xFF253A8B), Color(0xFF6C52C6)]),
                ),
                child: const Stack(children: [
                  Positioned(left: 22, bottom: 0, child: Icon(Icons.people, size: 85, color: Color(0x663C4C99))),
                  Positioned(right: 25, bottom: 0, child: Icon(Icons.auto_awesome, size: 70, color: Color(0x66FFFFFF))),
                  Center(child: Icon(Icons.music_note_rounded, color: Colors.white, size: 40)),
                ]),
              ),
              const SizedBox(height: 30),
              SizedBox(width: double.infinity, height: 52, child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: navy),
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OnboardingScreen())),
                child: const Text('Get Started', style: TextStyle(fontWeight: FontWeight.bold)),
              )),
              TextButton(
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainShell())),
                child: const Text('Skip', style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}
class _OnboardingScreenState extends State<OnboardingScreen> {
  int page = 0;
  final pages = const [
    ('Explore Amazing Campus Events', 'Find, join and manage events all in one place.', Icons.groups_rounded),
    ('Never Miss a Moment', 'Keep your registrations and tickets together.', Icons.confirmation_number_rounded),
    ('Make Every Event Smarter', 'Discover personalized suggestions and useful updates.', Icons.auto_awesome_rounded),
  ];
  @override
  Widget build(BuildContext context) {
    final item = pages[page];
    return Scaffold(
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(children: [
          Align(alignment: Alignment.centerLeft, child: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back))),
          const Spacer(),
          Container(height: 250, width: double.infinity, decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: const LinearGradient(colors: [Color(0xFFE7EDFF), Color(0xFFF7F4FF)])),
              child: Icon(item.$3, size: 125, color: blue)),
          const SizedBox(height: 32),
          Text(item.$1, textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: ink)),
          const SizedBox(height: 12),
          Text(item.$2, textAlign: TextAlign.center, style: const TextStyle(color: muted, fontSize: 15)),
          const Spacer(),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(3, (i) => Container(
            margin: const EdgeInsets.all(4), width: page == i ? 22 : 8, height: 8,
            decoration: BoxDecoration(color: page == i ? navy : const Color(0xFFC7CEE2), borderRadius: BorderRadius.circular(9)),
          ))),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, height: 52, child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: navy),
            onPressed: () {
              if (page < 2) { setState(() => page++); }
              else { Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())); }
            },
            child: Text(page == 2 ? 'Continue to Login' : 'Next'),
          )),
          TextButton(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainShell())), child: const Text('Skip for now')),
        ]),
      )),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool hidePassword = true;
  @override
  void dispose() { email.dispose(); password.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: ListView(padding: const EdgeInsets.all(24), children: [
      const SizedBox(height: 24),
      const Center(child: OrbitLogo(size: 78)),
      const SizedBox(height: 16),
      const Text('Welcome Back', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: ink)),
      const SizedBox(height: 8),
      const Text('Sign in to continue to EventSphere', textAlign: TextAlign.center, style: TextStyle(color: muted)),
      const SizedBox(height: 34),
      TextField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(prefixIcon: Icon(Icons.person_outline), hintText: 'Email or Phone')),
      const SizedBox(height: 14),
      TextField(controller: password, obscureText: hidePassword, decoration: InputDecoration(prefixIcon: const Icon(Icons.lock_outline), hintText: 'Password', suffixIcon: IconButton(icon: Icon(hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: () => setState(() => hidePassword = !hidePassword)))),
      Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => _message(context, 'Password recovery will be connected to the backend.'), child: const Text('Forgot Password?'))),
      const SizedBox(height: 8),
      SizedBox(height: 52, child: FilledButton(style: FilledButton.styleFrom(backgroundColor: navy), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainShell())), child: const Text('Login'))),
      const SizedBox(height: 18),
      const Center(child: Text('Or continue with', style: TextStyle(color: muted))),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: OutlinedButton(onPressed: () => _message(context, 'Social login will be added later.'), child: const Text('Google'))),
        const SizedBox(width: 10),
        Expanded(child: OutlinedButton(onPressed: () => _message(context, 'Social login will be added later.'), child: const Text('Apple'))),
      ]),
      const SizedBox(height: 18),
      Center(child: TextButton(onPressed: () => _message(context, 'Account creation will be connected to the backend.'), child: const Text("Don't have an account? Sign Up"))),
      const SizedBox(height: 20),
      Container(height: 90, decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), gradient: const LinearGradient(colors: [Color(0xFFE1EAFF), Color(0xFFF1E8FF)])), child: const Icon(Icons.account_balance_rounded, size: 65, color: Color(0xFF6B8FE9))),
    ])),
  );
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}
class _MainShellState extends State<MainShell> {
  int index = 0;
  final Set<String> registered = Set<String>.from(appRegisteredEventTitles);
  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(registered: registered, onRegister: (event) => setState(() { registered.add(event.title); appRegisteredEventTitles.add(event.title); EventStore.saveRegistered(appRegisteredEventTitles); })),
      MyEventsPage(registered: registered, onOpen: _openEvent, onExplore: () => setState(() => index = 0)),
      OrganizerPage(onEventsChanged: () => setState(() {})),
      OperationsPage(),
      const AIPage(),
    ];
    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE3EAFF),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.confirmation_number_outlined), selectedIcon: Icon(Icons.confirmation_number), label: 'My Events'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline), selectedIcon: Icon(Icons.add_circle), label: 'Create'),
          NavigationDestination(icon: Icon(Icons.monitor_heart_outlined), selectedIcon: Icon(Icons.monitor_heart), label: 'Operations'),
          NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome), label: 'AI'),
        ],
      ),
    );
  }
  void _openEvent(EventItem event) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailsPage(
      event: event,
      isRegistered: registered.contains(event.title),
      onRegister: () => setState(() { registered.add(event.title); appRegisteredEventTitles.add(event.title); EventStore.saveRegistered(appRegisteredEventTitles); }),
    )));
  }
}

class HomePage extends StatefulWidget {
  final Set<String>? registered;
  final ValueChanged<EventItem>? onRegister;
  const HomePage({super.key, this.registered, this.onRegister});
  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  String query = '';
  String category = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = query.trim().toLowerCase();
    final suggestions = searchQuery.isEmpty
        ? <EventItem>[]
        : appEvents.where((e) =>
    e.title.toLowerCase().contains(searchQuery) ||
        e.category.toLowerCase().contains(searchQuery) ||
        e.venue.toLowerCase().contains(searchQuery) ||
        e.organizer.toLowerCase().contains(searchQuery) ||
        e.date.toLowerCase().contains(searchQuery) ||
        e.description.toLowerCase().contains(searchQuery)).take(4).toList();
    final filtered = appEvents.where((e) =>
    (category == 'All' || e.category == category) &&
        (searchQuery.isEmpty ||
            e.title.toLowerCase().contains(searchQuery) ||
            e.category.toLowerCase().contains(searchQuery) ||
            e.date.toLowerCase().contains(searchQuery) ||
            e.time.toLowerCase().contains(searchQuery) ||
            e.venue.toLowerCase().contains(searchQuery) ||
            e.description.toLowerCase().contains(searchQuery) ||
            e.organizer.toLowerCase().contains(searchQuery))).toList();
    final featured = appEvents.first;
    return Scaffold(body: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(18, 12, 18, 24), children: [
      Row(children: [
        const OrbitLogo(size: 42), const SizedBox(width: 9),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('EventSphere', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: navyDark)),
          Text('Discover • Participate • Experience', style: TextStyle(fontSize: 13, color: muted)),
        ])),
        IconButton(onPressed: () => _message(context, 'Notifications will be connected later.'), icon: const Icon(Icons.notifications_none_rounded, color: navy)),
        const CircleAvatar(radius: 17, backgroundColor: Color(0xFFE2E9FF), child: Icon(Icons.person, color: navy, size: 20)),
      ]),
      const SizedBox(height: 18),
      TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => query = v),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: 'Search events, clubs, categories...',
          isDense: true,
          suffixIcon: query.isEmpty
              ? null
              : IconButton(
            tooltip: 'Clear search',
            icon: const Icon(Icons.close),
            onPressed: () {
              _searchController.clear();
              setState(() => query = '');
            },
          ),
        ),
      ),
      if (searchQuery.isNotEmpty) ...[
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFE1E8FA)),
          ),
          child: suggestions.isEmpty
              ? const Padding(
            padding: EdgeInsets.all(14),
            child: Text('No suggestions found.', style: TextStyle(color: muted)),
          )
              : Column(
            children: suggestions.map((event) => ListTile(
              dense: true,
              leading: Icon(Icons.event_outlined, color: event.color),
              title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.w700, color: ink)),
              subtitle: Text('${event.category} • ${event.venue}', maxLines: 1, overflow: TextOverflow.ellipsis),
              onTap: () {
                _searchController.text = event.title;
                setState(() {
                  query = event.title;
                  category = 'All';
                });
              },
            )).toList(),
          ),
        ),
      ],
      const SizedBox(height: 20),
      const SectionTitle(title: 'Featured event'),
      const SizedBox(height: 10),
      FeaturedCard(event: featured, onTap: () => _openEvent(context, featured, widget.registered ?? {}, widget.onRegister)),
      const SizedBox(height: 22),
      const SectionTitle(title: 'Explore categories'),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        _CategoryButton(label: 'All', icon: Icons.grid_view_rounded, color: blue, selected: category == 'All', onTap: () => setState(() => category = 'All')),
        _CategoryButton(label: 'Tech', icon: Icons.memory_rounded, color: orange, selected: category == 'Technology', onTap: () => setState(() => category = 'Technology')),
        _CategoryButton(label: 'Culture', icon: Icons.celebration_rounded, color: pink, selected: category == 'Cultural', onTap: () => setState(() => category = 'Cultural')),
        _CategoryButton(label: 'Sports', icon: Icons.sports_basketball_rounded, color: teal, selected: category == 'Sports', onTap: () => setState(() => category = 'Sports')),
        _CategoryButton(label: 'Workshop', icon: Icons.lightbulb_outline, color: purple, selected: category == 'Workshop', onTap: () => setState(() => category = 'Workshop')),
      ]),
      const SizedBox(height: 22),
      const SectionTitle(title: 'Recommended for You', action: 'See All'),
      const SizedBox(height: 10),
      SizedBox(height: 132, child: ListView(scrollDirection: Axis.horizontal, children: appEvents.take(3).map((e) => _RecommendedCard(event: e, onTap: () => _openEvent(context, e, widget.registered ?? {}, widget.onRegister))).toList())),
      const SizedBox(height: 20),
      SectionTitle(title: 'Upcoming events', action: '${filtered.length} events'),
      const SizedBox(height: 10),
      if (filtered.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No matching events found.', style: TextStyle(color: muted)))),
      ...filtered.map((e) => EventCard(event: e, onTap: () => _openEvent(context, e, widget.registered ?? {}, widget.onRegister))),
    ])));
  }
}
void _openEvent(BuildContext context, EventItem event, Set<String> registered, ValueChanged<EventItem>? onRegister) {
  Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailsPage(
    event: event, isRegistered: registered.contains(event.title),
    onRegister: () => onRegister?.call(event),
  )));
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  const SectionTitle({super.key, required this.title, this.action});
  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: Text(title, style: const TextStyle(color: ink, fontSize: 17, fontWeight: FontWeight.w800))),
    if (action != null) Text(action!, style: const TextStyle(color: blue, fontSize: 12, fontWeight: FontWeight.w600)),
  ]);
}
class FeaturedCard extends StatelessWidget {
  final EventItem event;
  final VoidCallback onTap;
  const FeaturedCard({super.key, required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) => Container(
    height: 204,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(23),
      gradient: LinearGradient(
        colors: [event.color, navyDark],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Positioned(
          right: -10,
          top: -8,
          child: Icon(
            Icons.auto_awesome,
            size: 94,
            color: Colors.white.withOpacity(.08),
          ),
        ),
        Positioned(
          right: 12,
          top: 20,
          child: Icon(
            Icons.stars_rounded,
            size: 58,
            color: Colors.white.withOpacity(.07),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.auto_awesome, color: Color(0xFFDCD4FF), size: 23),
            const SizedBox(height: 6),
            Text(
              event.category.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFFE2DEFF),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              event.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '${event.date} • ${event.venue}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                height: 38,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: navy,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onPressed: onTap,
                  child: const Text(
                    'Explore event',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
class _CategoryButton extends StatelessWidget {
  final String label; final IconData icon; final Color color; final bool selected; final VoidCallback onTap;
  const _CategoryButton({required this.label, required this.icon, required this.color, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(14), child: SizedBox(width: 59, child: Column(children: [
    Container(width: 42, height: 42, decoration: BoxDecoration(color: selected ? color : color.withOpacity(.12), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: selected ? Colors.white : color, size: 22)),
    const SizedBox(height: 5),
    Text(label, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: selected ? FontWeight.w800 : FontWeight.w600, color: ink)),
  ])));
}
class _RecommendedCard extends StatelessWidget {
  final EventItem event; final VoidCallback onTap;
  const _RecommendedCard({required this.event, required this.onTap});
  @override
  Widget build(BuildContext context) => Container(width: 220, margin: const EdgeInsets.only(right: 10), child: Material(color: Colors.white, borderRadius: BorderRadius.circular(17), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(17), child: Padding(padding: const EdgeInsets.all(11), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      Container(width: 43, height: 43, decoration: BoxDecoration(color: event.color.withOpacity(.15), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.event, color: event.color)),
      const SizedBox(width: 9),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(event.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: ink)),
        Text(event.category, style: const TextStyle(fontSize: 14, color: muted)),
      ])),
    ]),
    const Spacer(),
    Text('${event.date} • ${event.venue}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, color: muted)),
    const SizedBox(height: 7),
    Container(height: 27, alignment: Alignment.center, decoration: BoxDecoration(color: blue, borderRadius: BorderRadius.circular(8)), child: const Text('Explore event', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
  ])))));
}
class EventCard extends StatelessWidget {
  final EventItem event; final VoidCallback onTap;
  const EventCard({super.key, required this.event, required this.onTap});
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 10), child: Material(color: Colors.white, borderRadius: BorderRadius.circular(17), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(17), child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
    Container(width: 64, height: 70, decoration: BoxDecoration(color: event.color.withOpacity(.13), borderRadius: BorderRadius.circular(13)), child: Icon(Icons.event_available, color: event.color, size: 28)),
    const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(event.category.toUpperCase(), style: TextStyle(color: event.color, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: .7)),
      const SizedBox(height: 4),
      Text(event.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: ink, fontWeight: FontWeight.w800, fontSize: 14)),
      const SizedBox(height: 4),
      Text('${event.date} • ${event.time}', style: const TextStyle(color: muted, fontSize: 14)),
      const SizedBox(height: 4),
      Text(event.venue, style: const TextStyle(color: muted, fontSize: 14)),
    ])),
    const Icon(Icons.chevron_right, color: muted),
  ])))));
}

class EventDetailsPage extends StatefulWidget {
  final EventItem event; final bool isRegistered; final VoidCallback onRegister;
  const EventDetailsPage({super.key, required this.event, required this.isRegistered, required this.onRegister});
  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}
class _EventDetailsPageState extends State<EventDetailsPage> {
  bool registeredHere = false;
  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final isRegistered = widget.isRegistered || registeredHere;
    return Scaffold(
      appBar: AppBar(title: const Text('Event Details')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Container(height: 190, decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: LinearGradient(colors: [event.color, navyDark])), child: const Center(child: Icon(Icons.celebration_rounded, size: 75, color: Colors.white))),
        const SizedBox(height: 20),
        Wrap(spacing: 7, children: [event.category, 'Beginner Friendly'].map((s) => Chip(label: Text(s), backgroundColor: const Color(0xFFE8EEFF), side: BorderSide.none)).toList()),
        Text(event.title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: ink)),
        const SizedBox(height: 12),
        InfoRow(icon: Icons.calendar_month_outlined, title: event.date, subtitle: event.time),
        InfoRow(icon: Icons.location_on_outlined, title: event.venue, subtitle: 'Organized by ${event.organizer}'),
        const SizedBox(height: 12),
        const Row(children: [Icon(Icons.event_seat, color: blue), SizedBox(width: 8), Text('200 seats left', style: TextStyle(color: teal, fontWeight: FontWeight.bold))]),
        const SizedBox(height: 22),
        const Text('About', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: ink)),
        const SizedBox(height: 8),
        Text(event.description, style: const TextStyle(color: muted, height: 1.6)),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: () {
            setState(() { if (appSavedEvents.contains(event.title)) { appSavedEvents.remove(event.title); } else { appSavedEvents.add(event.title); } });
            EventStore.saveSaved(appSavedEvents);
            _message(context, appSavedEvents.contains(event.title) ? 'Event saved.' : 'Event removed from saved events.');
          },
          icon: Icon(appSavedEvents.contains(event.title) ? Icons.bookmark : Icons.bookmark_border),
          label: Text(appSavedEvents.contains(event.title) ? 'Saved' : 'Save Event'),
        ),
        const SizedBox(height: 12),
        SizedBox(height: 52, child: FilledButton(style: FilledButton.styleFrom(backgroundColor: navy), onPressed: isRegistered ? null : () {
          widget.onRegister(); setState(() => registeredHere = true);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Demo registration successful!')));
        }, child: Text(isRegistered ? 'Registered' : 'Register for Event'))),
        const SizedBox(height: 10),
        const Text('Your registration is saved on this device or browser.', textAlign: TextAlign.center, style: TextStyle(color: muted, fontSize: 12)),
      ]),
    );
  }
}
class InfoRow extends StatelessWidget {
  final IconData icon; final String title; final String subtitle;
  const InfoRow({super.key, required this.icon, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 14), child: Row(children: [
    Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFFE7EDFF), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: blue)),
    const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: ink)),
      const SizedBox(height: 3),
      Text(subtitle, style: const TextStyle(color: muted, fontSize: 12)),
    ])),
  ]));
}

class MyEventsPage extends StatefulWidget {
  final Set<String> registered;
  final void Function(EventItem) onOpen;
  final VoidCallback onExplore;

  const MyEventsPage({
    super.key,
    required this.registered,
    required this.onOpen,
    required this.onExplore,
  });

  @override
  State<MyEventsPage> createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final items = appEvents.where((event) {
      if (selectedTab == 2) return appSavedEvents.contains(event.title);
      if (!widget.registered.contains(event.title)) return false;
      final date = _eventDate(event);
      final isPast = date != null && DateTime(date.year, date.month, date.day).isBefore(DateTime(now.year, now.month, now.day));
      return selectedTab == 1 ? isPast : !isPast;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Events',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: ink),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: const Color(0xFFE7EDFF),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  _eventTab('Upcoming', 0),
                  _eventTab('Past', 1),
                  _eventTab('Saved', 2),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: items.isEmpty
                  ? Center(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 30,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE1E8FA)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFEAF0FF),
                          ),
                          child: const Icon(
                            Icons.confirmation_number_rounded,
                            size: 46,
                            color: blue,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          selectedTab == 2 ? 'No saved events yet' : selectedTab == 1 ? 'No past events yet' : 'No upcoming events yet',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: ink,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          selectedTab == 2 ? 'Save events from Event Details and they will appear here.' : 'Explore events and register. Your event details and tickets will appear here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: Color(0xFF596581),
                          ),
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: navy,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: widget.onExplore,
                            icon: const Icon(Icons.explore_outlined),
                            label: const Text(
                              'Explore Events',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
                  : ListView(
                children: items.map((event) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE1E8FA)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 68,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: event.color.withOpacity(.13),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  Icons.event_available_rounded,
                                  color: event.color,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 13),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event.title,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        color: ink,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${event.date} • ${event.time}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF596581),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      event.venue,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF596581),
                                      ),
                                    ),
                                    const SizedBox(height: 7),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFDFF7EB),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        selectedTab == 2 && !widget.registered.contains(event.title) ? 'Saved' : 'Registered',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF13734E),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: blue,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: selectedTab == 2 && !widget.registered.contains(event.title)
                                      ? () => widget.onOpen(event)
                                      : () => _showDemoTicket(context, event),
                                  icon: Icon(selectedTab == 2 && !widget.registered.contains(event.title) ? Icons.event_available : Icons.qr_code_2),
                                  label: Text(selectedTab == 2 && !widget.registered.contains(event.title) ? 'Register' : 'View Ticket'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => widget.onOpen(event),
                                  child: const Text('Event Details'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _eventTab(String label, int tab) {
    final selected = selectedTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = tab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? navy : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : ink,
            ),
          ),
        ),
      ),
    );
  }

  void _showDemoTicket(BuildContext context, EventItem event) {
    // Demo ID is stable for the event, not unique per attendee.
    final eventNumber = event.title.codeUnits.fold<int>(
      0, (value, character) => (value * 31 + character) % 1000000,
    );
    final ticketId = 'ES-DEMO-${eventNumber.toString().padLeft(6, '0')}';
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.confirmation_number_rounded, color: blue, size: 36),
            const SizedBox(height: 8),
            const Text('Your Event Ticket', textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ink)),
            const SizedBox(height: 6),
            const Text('Registration confirmed (demo)',
                style: TextStyle(color: teal, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: pale,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE1E8FA))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(event.title, style: const TextStyle(fontSize: 20,
                    fontWeight: FontWeight.w800, color: ink)),
                const SizedBox(height: 12),
                Row(children: [const Icon(Icons.calendar_month_outlined, color: blue, size: 20),
                  const SizedBox(width: 8), Expanded(child: Text('${event.date} • ${event.time}'))]),
                const SizedBox(height: 10),
                Row(children: [const Icon(Icons.location_on_outlined, color: blue, size: 20),
                  const SizedBox(width: 8), Expanded(child: Text(event.venue))]),
                const SizedBox(height: 10),
                Row(children: [const Icon(Icons.groups_outlined, color: blue, size: 20),
                  const SizedBox(width: 8), Expanded(child: Text('Organizer: ${event.organizer}'))]),
              ]),
            ),
            const SizedBox(height: 18),
            const Icon(Icons.qr_code_2_rounded, color: navy, size: 105),
            const Text('QR preview only — not scannable',
                style: TextStyle(color: muted, fontSize: 12)),
            const SizedBox(height: 14),
            const Text('DEMO TICKET ID', style: TextStyle(color: muted, fontSize: 12)),
            const SizedBox(height: 4),
            SelectableText(ticketId, style: const TextStyle(fontSize: 17,
                fontWeight: FontWeight.w800, color: navy)),
            const SizedBox(height: 12),
            const Text('Demo ticket only. Unique attendee tickets and secure QR check-in require a backend.',
                textAlign: TextAlign.center,
                style: TextStyle(color: muted, fontSize: 12, height: 1.4)),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: navy),
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Close Ticket'))),
          ]),
        ),
      ),
    );
  }
}

class OrganizerPage extends StatelessWidget {
  final VoidCallback? onEventsChanged;
  const OrganizerPage({super.key, this.onEventsChanged});

  @override
  Widget build(BuildContext context) {
    final totalRegistrations = appRegisteredEventTitles.length;
    final now = DateTime.now();
    final upcoming = appEvents.where((e) { final d = _eventDate(e); return d == null || !d.isBefore(DateTime(now.year, now.month, now.day)); }).length;
    return Scaffold(appBar: AppBar(title: const Text('Organizer Dashboard')), body: ListView(padding: const EdgeInsets.all(18), children: [
      const Text('Overview', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: ink)),
      const SizedBox(height: 14),
      GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.5, children: [
        _MetricCard(icon: Icons.event, value: '${appEvents.length}', label: 'Events Created', color: blue),
        _MetricCard(icon: Icons.groups, value: '$totalRegistrations', label: 'Registrations', color: teal),
        _MetricCard(icon: Icons.upcoming, value: '$upcoming', label: 'Upcoming Events', color: purple),
        const _MetricCard(icon: Icons.star, value: '—', label: 'Average Rating', color: orange),
      ]),
      const SizedBox(height: 24),
      const Text('Recent Events', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: ink)),
      const SizedBox(height: 10),
      ...appEvents.reversed.take(5).map((e) => EventCard(event: e, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailsPage(event: e, isRegistered: false, onRegister: () {}))))),
      const SizedBox(height: 12),
      SizedBox(height: 52, child: FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: navy), onPressed: () async {
        final created = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const CreateEventPage()));
        if (created == true) onEventsChanged?.call();
      }, icon: const Icon(Icons.add), label: const Text('Create New Event'))),
    ]));
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon; final String value, label; final Color color;
  const _MetricCard({required this.icon, required this.value, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(icon, color: color), const SizedBox(height: 5),
    Text(value, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: ink)),
    Text(label, style: const TextStyle(fontSize: 13, color: muted)),
  ]));
}
class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});
  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}
class _CreateEventPageState extends State<CreateEventPage> {
  final title = TextEditingController();
  final description = TextEditingController();
  final venue = TextEditingController();
  final organizer = TextEditingController(text: 'Campus Events Club');
  String category = 'Technology';
  DateTime? eventDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  bool isSubmitting = false;
  @override
  void dispose() { title.dispose(); description.dispose(); venue.dispose(); organizer.dispose(); super.dispose(); }

  String _formatDate(DateTime date) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }
  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    return '$hour:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'AM' : 'PM'}';
  }
  Color _categoryColor() => switch (category) {
    'Technology' => const Color(0xFF4268D6), 'Cultural' => const Color(0xFFE26C91),
    'Sports' => const Color(0xFFD58A3A), _ => const Color(0xFF725CE0),
  };

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Create New Event')), body: ListView(padding: const EdgeInsets.all(20), children: [
    const Text('Event information', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ink)),
    const SizedBox(height: 8),
    const Text('Complete the details below to add an event to the demo app.', style: TextStyle(color: muted)),
    const SizedBox(height: 18),
    TextField(controller: title, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Event Title *', hintText: 'Enter event title')),
    const SizedBox(height: 12),
    TextField(controller: description, maxLines: 4, textCapitalization: TextCapitalization.sentences, decoration: const InputDecoration(labelText: 'Description *', hintText: 'What is this event about?')),
    const SizedBox(height: 18),
    const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, color: ink)),
    const SizedBox(height: 8),
    DropdownButtonFormField<String>(initialValue: category, items: ['Technology', 'Cultural', 'Sports', 'Workshop'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => category = v ?? category)),
    const SizedBox(height: 12),
    TextField(controller: venue, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Venue *', hintText: 'Enter venue')),
    const SizedBox(height: 12),
    TextField(controller: organizer, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Organizer')),
    const SizedBox(height: 14),
    OutlinedButton.icon(onPressed: () async {
      final now = DateTime.now();
      final picked = await showDatePicker(context: context, initialDate: eventDate ?? now, firstDate: DateTime(now.year, now.month, now.day), lastDate: DateTime(now.year + 5));
      if (picked != null && mounted) setState(() => eventDate = picked);
    }, icon: const Icon(Icons.calendar_month), label: Text(eventDate == null ? 'Choose event date *' : _formatDate(eventDate!))),
    const SizedBox(height: 8),
    Row(children: [
      Expanded(child: OutlinedButton.icon(onPressed: () async { final picked = await showTimePicker(context: context, initialTime: startTime ?? const TimeOfDay(hour: 10, minute: 0)); if (picked != null && mounted) setState(() => startTime = picked); }, icon: const Icon(Icons.schedule), label: Text(startTime == null ? 'Start time *' : _formatTime(startTime!)))),
      const SizedBox(width: 10),
      Expanded(child: OutlinedButton.icon(onPressed: () async { final picked = await showTimePicker(context: context, initialTime: endTime ?? const TimeOfDay(hour: 16, minute: 0)); if (picked != null && mounted) setState(() => endTime = picked); }, icon: const Icon(Icons.schedule_outlined), label: Text(endTime == null ? 'End time *' : _formatTime(endTime!)))),
    ]),
    const SizedBox(height: 20),
    SizedBox(height: 52, child: FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: navy), onPressed: isSubmitting ? null : _createEvent, icon: const Icon(Icons.add_circle_outline), label: Text(isSubmitting ? 'Creating...' : 'Create Event'))),
    const SizedBox(height: 12),
    const Text('Events are saved locally on this device or browser. Data does not sync between devices.', textAlign: TextAlign.center, style: TextStyle(color: muted, fontSize: 12)),
  ]));

  void _createEvent() {
    if (title.text.trim().isEmpty || description.text.trim().isEmpty || venue.text.trim().isEmpty) { _message(context, 'Please fill in the title, description, and venue.'); return; }
    if (eventDate == null || startTime == null || endTime == null) { _message(context, 'Please choose the event date, start time, and end time.'); return; }
    final startMinutes = startTime!.hour * 60 + startTime!.minute;
    final endMinutes = endTime!.hour * 60 + endTime!.minute;
    if (endMinutes <= startMinutes) { _message(context, 'End time must be after start time.'); return; }
    if (appEvents.any((e) => e.title.trim().toLowerCase() == title.text.trim().toLowerCase())) { _message(context, 'An event with this title already exists.'); return; }
    setState(() => isSubmitting = true);
    appEvents.add(EventItem(
      title: title.text.trim(), category: category, date: _formatDate(eventDate!),
      time: '${_formatTime(startTime!)} – ${_formatTime(endTime!)}', venue: venue.text.trim(),
      description: description.text.trim(), organizer: organizer.text.trim().isEmpty ? 'Campus Events Club' : organizer.text.trim(), color: _categoryColor(),
    ));
    EventStore.saveEvents(appEvents.map((e) => e.toMap()).toList());
    Navigator.pop(context, true);
  }
}

class OperationsPage extends StatelessWidget {
  const OperationsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Live Operations')), body: ListView(padding: const EdgeInsets.all(18), children: [
    Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: navy, borderRadius: BorderRadius.circular(20)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('AI Workshop Series', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      SizedBox(height: 12),
      Row(children: [
        Expanded(child: _OperationStat(value: '220', label: 'Checked-in', icon: Icons.login)),
        Expanded(child: _OperationStat(value: '80', label: 'Remaining', icon: Icons.people_outline)),
        Expanded(child: _OperationStat(value: '73%', label: 'Capacity', icon: Icons.pie_chart_outline)),
      ]),
    ])),
    const SizedBox(height: 20),
    const SectionTitle(title: 'Live Attendance', action: '● Live'),
    const SizedBox(height: 10),
    Container(height: 180, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: CustomPaint(painter: AttendanceChart(), child: const SizedBox.expand())),
    const SizedBox(height: 20),
    const SectionTitle(title: 'Queue Status'),
    const SizedBox(height: 10),
    const _QueueTile(title: 'Entry Gate', people: '12', wait: '~5 mins', status: 'Normal', color: teal),
    const _QueueTile(title: 'Help Desk', people: '4', wait: '~2 mins', status: 'Normal', color: teal),
    const _QueueTile(title: 'Food Stall', people: '25', wait: '~12 mins', status: 'Moderate', color: orange),
    const SizedBox(height: 18),
    const SectionTitle(title: 'Live Updates'),
    const ListTile(leading: Icon(Icons.circle, size: 12, color: blue), title: Text('Registrations crossed 200!'), subtitle: Text('12:15 PM')),
    const ListTile(leading: Icon(Icons.circle, size: 12, color: orange), title: Text('Slight crowd increase at Food Stall'), subtitle: Text('11:40 AM')),
    const ListTile(leading: Icon(Icons.circle, size: 12, color: teal), title: Text('Session started on time'), subtitle: Text('10:30 AM')),
  ]));
}
class _OperationStat extends StatelessWidget {
  final String value, label; final IconData icon;
  const _OperationStat({required this.value, required this.label, required this.icon});
  @override
  Widget build(BuildContext context) => Column(children: [Icon(icon, color: const Color(0xFF8BD9FF)), const SizedBox(height: 6), Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)), Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 12))]);
}
class _QueueTile extends StatelessWidget {
  final String title, people, wait, status; final Color color;
  const _QueueTile({required this.title, required this.people, required this.wait, required this.status, required this.color});
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)), child: Row(children: [
    CircleAvatar(backgroundColor: color.withOpacity(.12), child: Icon(Icons.people_alt_outlined, color: color)),
    const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: ink)), Text('$people people in queue', style: const TextStyle(color: muted, fontSize: 12))])),
    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(wait, style: const TextStyle(fontWeight: FontWeight.w800, color: ink)), Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold))]),
  ]));
}
class AttendanceChart extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()..color = const Color(0xFFE8EDF7)..strokeWidth = 1;
    for (int i = 0; i < 4; i++) { final y = 20 + i * (size.height - 45) / 3; canvas.drawLine(Offset(8, y), Offset(size.width - 8, y), grid); }
    final pts = <Offset>[];
    final values = [0.82, .67, .61, .53, .48, .39, .31, .25, .20, .16];
    for (int i = 0; i < values.length; i++) { pts.add(Offset(10 + i * (size.width - 20) / (values.length - 1), 15 + values[i] * (size.height - 50))); }
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) { path.lineTo(p.dx, p.dy); }
    final fillPath = Path.from(path)..lineTo(pts.last.dx, size.height - 18)..lineTo(pts.first.dx, size.height - 18)..close();
    canvas.drawPath(fillPath, Paint()..color = const Color(0xFF5CA5FF).withOpacity(.14));
    canvas.drawPath(path, Paint()..color = blue..strokeWidth = 2.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
    for (final p in pts) { canvas.drawCircle(p, 3, Paint()..color = blue); }
    final tp = TextPainter(textDirection: TextDirection.ltr);
    const labels = ['9AM', '10AM', '11AM', '12PM', '1PM', '2PM', '3PM', '4PM'];
    for (int i = 0; i < labels.length; i++) {
      tp.text = TextSpan(text: labels[i], style: const TextStyle(fontSize: 11, color: muted));
      tp.layout();
      tp.paint(canvas, Offset(8 + i * (size.width - 30) / (labels.length - 1), size.height - 13));
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AIPage extends StatefulWidget {
  const AIPage({super.key});
  @override
  State<AIPage> createState() => _AIPageState();
}
class _AIPageState extends State<AIPage> {
  int tab = 1;
  int simulation = 0;
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('AI Assistant'), actions: const [Padding(padding: EdgeInsets.only(right: 16), child: Icon(Icons.auto_awesome, color: purple))]), body: ListView(padding: const EdgeInsets.all(18), children: [
    SegmentedButton<int>(segments: const [ButtonSegment(value: 0, label: Text('Insights')), ButtonSegment(value: 1, label: Text('Recommendations')), ButtonSegment(value: 2, label: Text('Incidents'))], selected: {tab}, onSelectionChanged: (s) => setState(() => tab = s.first)),
    const SizedBox(height: 16),
    if (tab == 0) ...[
      _AIAlert(color: blue, icon: Icons.insights, title: 'Attendance is increasing', body: 'Registrations have grown compared with the previous event.'),
      _AIAlert(color: teal, icon: Icons.check_circle_outline, title: 'Schedule looks healthy', body: 'No simulated schedule conflicts detected.'),
    ] else if (tab == 1) ...[
      _AIAlert(color: const Color(0xFFE74D61), icon: Icons.warning_amber_rounded, title: 'High Crowd at Main Auditorium', body: 'Demo prediction: venue may reach full capacity in 20 minutes.'),
      const SizedBox(height: 8),
      const Text('Suggested Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: ink)),
      const SizedBox(height: 10),
      _Suggestion(number: '1', title: 'Redirect new attendees to Seminar Hall', subtitle: 'Estimated capacity: 150 seats', onApply: () => _message(context, 'Demo action selected. Organizer approval is required in the real app.')),
      _Suggestion(number: '2', title: 'Extend live streaming to another hall', subtitle: 'Reduce crowd at main venue', onApply: () => _message(context, 'Demo action selected. Organizer approval is required in the real app.')),
      _Suggestion(number: '3', title: 'Reschedule next session by 15 mins', subtitle: 'Give more exit time', onApply: () => _message(context, 'Demo action selected. Organizer approval is required in the real app.')),
    ] else ...[
      _AIAlert(color: orange, icon: Icons.report_gmailerrorred, title: 'Incident monitoring', body: 'No verified incidents are connected yet. Demo alerts are simulated.'),
      const ListTile(leading: Icon(Icons.shield_outlined, color: teal), title: Text('Safety note'), subtitle: Text('AI suggestions should be reviewed by an organizer before action.')),
    ],
    const SizedBox(height: 18),
    const Text('What-if Simulation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: ink)),
    const SizedBox(height: 5),
    const Text('Simulate changes and see their possible impact on crowd levels.', style: TextStyle(color: muted, fontSize: 12)),
    const SizedBox(height: 12),
    DropdownButtonFormField<int>(initialValue: simulation, decoration: const InputDecoration(labelText: 'Scenario'), items: const [DropdownMenuItem(value: 0, child: Text('Increase attendees by 50')), DropdownMenuItem(value: 1, child: Text('Move venue to Seminar Hall')), DropdownMenuItem(value: 2, child: Text('Add an extra entry gate'))], onChanged: (v) => setState(() => simulation = v ?? 0)),
    const SizedBox(height: 12),
    SizedBox(height: 48, child: FilledButton(onPressed: () => showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Simulation Result'), content: Text(['Estimated capacity rises to 90%. Consider opening another hall.', 'Seminar Hall may reduce main venue crowding in this demo.', 'An extra entry gate may reduce the estimated queue.'][simulation]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))])), child: const Text('Run Simulation'))),
  ]));
}
class _AIAlert extends StatelessWidget {
  final Color color; final IconData icon; final String title, body;
  const _AIAlert({required this.color, required this.icon, required this.title, required this.body});
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: color.withOpacity(.09), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(.15))), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(icon, color: color), const SizedBox(width: 10),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: color)), const SizedBox(height: 5), Text(body, style: const TextStyle(color: muted, fontSize: 14, height: 1.45))])),
  ]));
}
class _Suggestion extends StatelessWidget {
  final String number, title, subtitle; final VoidCallback onApply;
  const _Suggestion({required this.number, required this.title, required this.subtitle, required this.onApply});
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)), child: Row(children: [
    CircleAvatar(radius: 15, backgroundColor: const Color(0xFFE3ECFF), child: Text(number, style: const TextStyle(color: blue, fontWeight: FontWeight.bold))),
    const SizedBox(width: 10),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: ink)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(color: muted, fontSize: 12))])),
    const SizedBox(width: 6),
    FilledButton(onPressed: onApply, style: FilledButton.styleFrom(minimumSize: const Size(58, 34), padding: const EdgeInsets.symmetric(horizontal: 10)), child: const Text('Apply', style: TextStyle(fontSize: 13))),
  ]));
}

void _message(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
