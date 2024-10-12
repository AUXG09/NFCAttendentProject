import 'package:flutter/material.dart';
import 'package:nfc_check_attendance/presentation/screen/nfc_scan_page.dart';
import 'package:nfc_check_attendance/presentation/screen/StudentRegistrationPage.dart'; // นำเข้า StudentRegistrationPage
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // เริ่มต้น Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NFC CHECK',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 232, 199, 232)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'CYBER ATTENDANCE'),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            // ปุ่มไปหน้าสแกน NFC
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NFCScanPage()),
                );
              },
              child: const Text('Press to Scan NFC Card'),
            ),
            const SizedBox(height: 20),
            // ปุ่มไปหน้าลงทะเบียนนักศึกษา
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StudentRegistrationPage()),
                );
              },
              child: const Text('Press to Register Student'),
            ),
          ],
        ),
      ),
    );
  }
}
