import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: const PrajwalApp(),
    ),
  );
}

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage(this.text, this.isUser);
}

class AppState extends ChangeNotifier {
  bool isGuestMode = false;
  String userName = 'Prajwal';
  List<ChatMessage> messages = [
    ChatMessage("Hello Prajwal, how can I assist you today?", false)
  ];

  void setGuestMode(bool isGuest, {String? guestName}) {
    isGuestMode = isGuest;
    userName = isGuest && guestName != null ? guestName : 'Prajwal';
    messages.add(ChatMessage("Switched to ${isGuest ? 'Guest' : 'Owner'} Mode", false));
    notifyListeners();
  }

  void addMessage(String text, bool isUser) {
    messages.add(ChatMessage(text, isUser));
    notifyListeners();
    if (isUser) {
      _handleResponse(text);
    }
  }

  void _handleResponse(String query) {
    // Basic AI mock
    Future.delayed(const Duration(seconds: 1), () {
      if (query.toLowerCase().contains("open youtube") || query.toLowerCase().contains("yt")) {
        messages.add(ChatMessage("Opening YouTube...", false));
      } else if (query.toLowerCase().contains("weather")) {
        messages.add(ChatMessage("It's currently sunny. How else can I help?", false));
      } else {
        messages.add(ChatMessage("I am Prajwal AI. I understand '$query'. I am continuously learning.", false));
      }
      notifyListeners();
    });
  }
}

class PrajwalApp extends StatelessWidget {
  const PrajwalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prajwal AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();

  void _sendMessage(AppState state) {
    if (_controller.text.trim().isNotEmpty) {
      state.addMessage(_controller.text.trim(), true);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Prajwal AI${state.isGuestMode ? " (Guest Mode)" : ""}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.messages.length,
                itemBuilder: (context, index) {
                  final msg = state.messages[index];
                  return Align(
                    alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: msg.isUser ? Theme.of(context).colorScheme.primaryContainer : Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(msg.text),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Ask Prajwal AI...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: (_) => _sendMessage(state),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.mic),
                    onPressed: () {
                      state.addMessage("Voice input activated...", false);
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () => _sendMessage(state),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Language'),
            subtitle: const Text('English (Primary)'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Privacy & Security'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 16),
            Text(
              state.userName,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(state.isGuestMode ? 'Guest User' : 'Owner'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                if (state.isGuestMode) {
                  state.setGuestMode(false);
                } else {
                  state.setGuestMode(true, guestName: 'Guest User');
                }
              },
              child: Text(state.isGuestMode ? 'Switch to Owner' : 'Switch to Guest Mode'),
            ),
          ],
        ),
      ),
    );
  }
}
