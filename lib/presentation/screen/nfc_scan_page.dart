import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NFCScanPage extends StatefulWidget {
  const NFCScanPage({super.key});

  @override
  _NFCScanPageState createState() => _NFCScanPageState();
}

class _NFCScanPageState extends State<NFCScanPage> {
  String _cardInfo = 'รอการสแกน NFC...';
  bool _isScanning = false;
  String? selectedCollection;
  String? selectedDocument; // ตัวแปรเพื่อเก็บ Document ที่เลือก
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _startNFCScan() async {
    if (_isScanning) {
      await NfcManager.instance.stopSession(); // หยุดการสแกน
      setState(() {
        _isScanning = false; // เปลี่ยนสถานะการสแกน
        _cardInfo = 'รอการสแกน NFC...'; // แสดงข้อความรอ
      });
      return;
    }

    // เปิด Dialog ให้กรอกชื่อ Collection
    await _selectCollection();

    if (selectedCollection == null) return; // หากไม่มี Collection ที่เลือก

    // เปิด Dialog ให้เลือก Document จาก Collection ที่เลือก
    await _selectDocument();

    if (selectedDocument == null) return; // หากไม่มี Document ที่เลือก

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

          // แสดงข้อมูลการ์ด
          setState(() {
            _cardInfo = 'เช็คชื่อการ์ด: $hexString แล้ว'; // แสดง hexString
          });

          // ตรวจสอบข้อมูลใน Firestore
          await _checkNFCIDAndSave(hexString);
        },
      );
    } catch (e) {
      setState(() {
        _cardInfo = 'เกิดข้อผิดพลาด: $e';
        _isScanning = false; // หยุดการสแกนในกรณีมีข้อผิดพลาด
      });
    }
  }

  Future<void> _selectCollection() async {
    // ตัวแปรเพื่อเก็บค่าจาก TextField
    TextEditingController collectionController = TextEditingController();

    // แสดง Dialog ให้กรอกชื่อ Collection
    String? selected = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('กรอกชื่อ Collection'),
          content: TextField(
            controller: collectionController,
            decoration: const InputDecoration(
              hintText: 'กรุณากรอกชื่อ Collection',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ยกเลิก
              },
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () {
                // ตรวจสอบว่า TextField ไม่ว่างเปล่า
                if (collectionController.text.isNotEmpty) {
                  Navigator.of(context).pop(collectionController.text); // ส่งค่าที่กรอก
                }
              },
              child: const Text('ตกลง'),
            ),
          ],
        );
      },
    );

    // เก็บค่า Collection ที่กรอก
    if (selected != null && selected.isNotEmpty) {
      setState(() {
        selectedCollection = selected;
      });
    }
  }

  Future<void> _selectDocument() async {
    // ดึง Document IDs และ Lesson จาก Collection ที่เลือก
    QuerySnapshot snapshot = await _firestore.collection(selectedCollection!).get();
    List<Map<String, dynamic>> documents = snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        'lesson': data['lesson']?.toString() ?? 'ไม่มีข้อมูล' // แปลงเป็น String
      };
    }).toList();

    // แสดง Dialog ให้เลือก Document
    String? selected = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('เลือก Document'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: documents
                .map((doc) => ListTile(
                      title: Text(doc['lesson'] ?? 'ไม่มีข้อมูล'), // แสดง lesson
                      onTap: () {
                        Navigator.of(context).pop(doc['id']); // ส่งกลับ Document ID
                      },
                    ))
                .toList(),
          ),
        );
      },
    );

    // เก็บค่า Document ที่เลือก
    if (selected != null) {
      setState(() {
        selectedDocument = selected;
      });
    }
  }

  Future<void> _checkNFCIDAndSave(String hexString) async {
    try {
      // ค้นหาใน Collection 'Students'
      QuerySnapshot studentsSnapshot = await _firestore
          .collection('Students') // ใช้ Collection 'Students'
          .where('NFCID', isEqualTo: hexString) // เปรียบเทียบ NFCID กับ hexString
          .get();

      if (studentsSnapshot.docs.isNotEmpty) {
        // หากพบข้อมูล
        for (var studentDoc in studentsSnapshot.docs) {
          // ข้อมูลที่ตรงกัน
          var studentData = studentDoc.data() as Map<String, dynamic>; // แคสต์เป็น Map<String, dynamic>

          // สร้างเอกสารใหม่ใน Sub Collection 'STDcheck' โดยใช้ hexString เป็น Key
          DocumentReference stdCheckDoc = _firestore
              .collection(selectedCollection!) // ใช้ Collection ที่เลือก
              .doc(selectedDocument!) // ใช้ Document ที่เลือก
              .collection('STDcheck')
              .doc(hexString);

          // บันทึกข้อมูลนักเรียน และเพิ่ม timestamp ใหม่
          await stdCheckDoc.set({
            ...studentData, // ข้อมูลนักเรียนเดิม
            'timestamp': FieldValue.serverTimestamp(), // timestamp ใหม่จาก Firebase Server
          });
        }

        setState(() {
          _cardInfo = 'ข้อมูลนักเรียนถูกบันทึกเรียบร้อยแล้ว';
        });
      } else {
        setState(() {
          _cardInfo = 'ไม่พบข้อมูลนักเรียนที่ตรงกัน';
        });
      }
    } catch (e) {
      setState(() {
        _cardInfo = 'เกิดข้อผิดพลาดในการบันทึกข้อมูล: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ATTENDANCE'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(_cardInfo),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startNFCScan,
              child: Text(_isScanning ? 'หยุดการสแกน' : 'เริ่มสแกน NFC'),
            ),
            const SizedBox(height: 2),
          ],
        ),
      ),
    );
  }
}
