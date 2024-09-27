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
  String data = "";

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
                          debugPrint(
                              "${_serialPort!.open(mode: SerialPortMode.readWrite)}");

                          if (_serialPort!.isOpen) {
                            debugPrint('${_serialPort!.name} opened!');
                            data = _serialPort!.name!;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      Second(data: data, port: _serialPort!)),
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

class Second extends StatefulWidget {
  final String data;
  final SerialPort port;
  Second({required this.data, required this.port});
  @override
  State<Second> createState() => _SecondState();
}

class _SecondState extends State<Second> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(' Port: ${widget.data}'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            widget.port.close();
            debugPrint("${widget.port.name} is closed");
            Navigator.pop(context);
          },
          child: const Text('Close and Go back!'),
        ),
      ),
    );
  }
}
