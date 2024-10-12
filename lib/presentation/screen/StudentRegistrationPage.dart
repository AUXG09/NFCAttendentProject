import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nfc_manager/nfc_manager.dart';

class StudentRegistrationPage extends StatefulWidget {
  const StudentRegistrationPage({super.key});

  @override
  _StudentRegistrationPageState createState() => _StudentRegistrationPageState();
}

class _StudentRegistrationPageState extends State<StudentRegistrationPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController studentIdController = TextEditingController();
  String _cardInfo = 'รอการสแกน NFC...';
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _startNFCScan(); // เริ่มการสแกน NFC เมื่อหน้าโหลด
  }

  Future<void> _showInfoDialog(String hexString) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('กรอกข้อมูลนักศึกษา'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(hintText: 'ชื่อ'),
                ),
                TextField(
                  controller: studentIdController,
                  decoration: const InputDecoration(hintText: 'รหัสนักศึกษา'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('บันทึก'),
              onPressed: () async {
                await _registerStudent(hexString); // ส่ง hexString ไปยังฟังก์ชัน
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _registerStudent(String hexString) async {
    String name = nameController.text;
    String studentId = studentIdController.text;

    // เก็บข้อมูลลง Firestore
    final collection = FirebaseFirestore.instance.collection('Students');
    final docRef = collection.doc(hexString); // ใช้ NFCID เป็น Primary Key

    // เช็คว่ามีข้อมูลอยู่ใน Firestore หรือไม่
    final docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      // ถ้ามีข้อมูลอยู่แล้ว แจ้งให้ผู้ใช้ทราบ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('นักศึกษาได้ลงทะเบียนแล้ว')),
      );
    } else {
      // ถ้ายังไม่มีข้อมูล ให้บันทึกข้อมูลใหม่
      await docRef.set({
        'Name': name,
        'StudentID': studentId,
        'NFCID': hexString, // เก็บ NFC ID
      });

      // แสดง snackbar แจ้งว่าเก็บข้อมูลเรียบร้อยแล้ว
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ลงทะเบียนนักศึกษาเรียบร้อยแล้ว')),
      );

      // เคลียร์ข้อมูลใน TextField
      nameController.clear();
      studentIdController.clear();
    }
  }

  Future<void> _startNFCScan() async {
    if (_isScanning) {
      // หยุดการสแกน NFC
      await NfcManager.instance.stopSession();
      setState(() {
        _isScanning = false;
        _cardInfo = 'รอการสแกน NFC...';
      });
    } else {
      // เริ่มการสแกน NFC
      bool isAvailable = await NfcManager.instance.isAvailable();

      if (!isAvailable) {
        setState(() {
          _cardInfo = 'อุปกรณ์นี้ไม่รองรับ NFC';
        });
        return;
      }

      setState(() {
        _cardInfo = 'กำลังสแกน... กรุณาแตะการ์ดของคุณ';
        _isScanning = true;
      });

      try {
        await NfcManager.instance.startSession(
          onDiscovered: (NfcTag tag) async {
            var tech = tag.data;
            var uid = String.fromCharCodes(tech["nfca"]["identifier"]);
            List<int> charCodes = uid.runes.toList();
            String hexString = charCodes.map((code) => code.toRadixString(16)).join(':');

            setState(() {
              _cardInfo = 'ตรวจพบการ์ด $hexString';
            });

            // เช็คว่ามีข้อมูลอยู่ใน Firestore หรือไม่
            final docRef = FirebaseFirestore.instance.collection('Students').doc(hexString);
            final docSnapshot = await docRef.get();

            if (docSnapshot.exists) {
              // ถ้ามีข้อมูลอยู่แล้ว แจ้งให้ผู้ใช้ทราบ
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('นักศึกษาได้ลงทะเบียนแล้ว')),
              );
            } else {
              // แสดง Dialog ให้กรอกข้อมูลนักศึกษา
              await _showInfoDialog(hexString);
            }
          },
        );
      } catch (e) {
        setState(() {
          _cardInfo = 'เกิดข้อผิดพลาด: $e';
          _isScanning = false; // หยุดการสแกนในกรณีมีข้อผิดพลาด
        });
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    studentIdController.dispose();
    NfcManager.instance.stopSession(); // หยุดการสแกนเมื่อหน้าเลิกใช้งาน
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ลงทะเบียนนักศึกษา'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Text(_cardInfo),
              ),
            ),
            ElevatedButton(
              onPressed: _startNFCScan,
              child: Text(_isScanning ? 'หยุดสแกน NFC' : 'เริ่มสแกน NFC'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
