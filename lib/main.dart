import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:cp949/cp949.dart' as cp949;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GUI for Available COM Ports',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'All the Available COM Ports'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<SerialPort> portList = [];
  SerialPort?
      _serialPort; // Can hold an instance of Serial Port or a null value and _serialPort is a private value
  List<Uint8List> receiveDataList = [];
  final textInputCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    var i = 0;
    for (final name in SerialPort.availablePorts) {
      final sp = SerialPort(name);
      if (kDebugMode) {
        print('${++i}) $name');
        print('\tDescription: ${cp949.decodeString(sp.description ?? '')}');
        print('\tManufacturer: ${sp.manufacturer}');
        print('\tSerial Number: ${sp.serialNumber}');
        print('\tProduct ID: 0x${sp.productId?.toRadixString(16) ?? 00}');
        print('\tVendor ID: 0x${sp.vendorId?.toRadixString(16) ?? 00}');
      }
      portList.add(sp);
    }
    if (portList.isNotEmpty) {
      _serialPort = portList.first;
    }
  }

  void changedDropDownItem(SerialPort sp) {
    setState(() {
      _serialPort = sp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            const BigCard(),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton(
                    value: _serialPort,
                    items: portList.map((item) {
                      return DropdownMenuItem(
                          child: Text(
                              "${item.name}: ${cp949.decodeString(item.description ?? '')}"),
                          value: item);
                    }).toList(),
                    onChanged: 
                     Selection,
                   
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

void Selection(e) {
    setState(() {
      changedDropDownItem(e as SerialPort);
    });

    print('You have selected ${e.name}');
   
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text("Available COM Ports from your device."),
        ),
      ),
    );
  }
}
