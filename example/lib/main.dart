import 'package:apptuner/apptuner.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize apptuner with your API Key
  await apptuner.init(
    apiKey: 'e2214bd7-ce14-4e37-8167-4b86e2b506e4', // Api Key
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apptuner Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return ApptunerWrapper(
          style: ApptunerStyle(
            backgroundGradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1B4332),
                Color(0xFF081C15),
              ],
            ),
            maintenanceIconColor: Colors.white,
            updateIconColor: const Color(0xFFF4D03F),
            maintenanceIconBackgroundColor: Colors.white.withValues(alpha: 0.1),
            updateIconBackgroundColor: const Color(0xFFF4D03F).withValues(alpha: 0.2),
            titleStyle: const TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.bold, 
              color: Colors.white
            ),
            messageStyle: TextStyle(
              fontSize: 16, 
              color: Colors.white.withValues(alpha: 0.7)
            ),
            buttonGradient: const LinearGradient(
              colors: [Color(0xFFF4D03F), Color(0xFFF4D03F)], // Solid golden color
            ),
            buttonTextStyle: const TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.bold, 
              color: Colors.black
            ),
          ),
          child: child!,
        );
      },
      home: const MyHomePage(title: 'Apptuner Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Manually check for updates
              apptuner.checkUpdate();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Checked for updates')),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Apptuner is running in the background.\nIf maintenance is active, an overlay will appear.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
