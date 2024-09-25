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
      title: 'Flutter Windowns Serial Port Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
      ),
      home: const MyHomePage(title: 'Flutter Windowns Serial Port Demo'),
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
  SerialPort? _serialPort;
  List<Uint8List> receiveDataList = [];
  final textInputCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    for (final name in SerialPort.availablePorts) {
      final sp = SerialPort(name);

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
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: SizedBox(
        height: double.infinity,
        child: Column(
          children: <Widget>[
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
                      onChanged: (e) {
                        setState(() {
                          changedDropDownItem(e as SerialPort);
                          debugPrint(e.name);
                        });
                      },
                    ),
                    const SizedBox(
                      width: 50.0,
                    ),
                    OutlinedButton(
                      child: const Text("Select"),
                      onPressed: () {
                        if (_serialPort == null) {
                          return;
                        } else {
                          debugPrint("${_serialPort!
                              .open(mode: SerialPortMode.readWrite)}");
                       
                          if (_serialPort!.isOpen) {
                            debugPrint('${_serialPort!.name} opened!');
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Second()),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}

class Second extends StatelessWidget {
  const Second({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Route'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Go back!'),
        ),
      ),
    );
  }
}
