import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class FunctionPage extends StatefulWidget {
  // const FunctionPage({Key? key}) : super(key: key);
  final BluetoothDevice server;

  const FunctionPage({required this.server});

  @override
  State<FunctionPage> createState() => _FunctionsPage();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _FunctionsPage extends State<FunctionPage> {
  bool func1 = false;
  bool func2 = false;

  Color first_func_button = Color(0XFF7371FC);
  Color second_func_button = Color(0XFF7371FC);
  Color first_func_text = Color(0XFFCDC1FF);
  Color second_func_text = Color(0XFFCDC1FF);

  Color button_on = Color(0XFFF5EFFF);
  Color button_off = Color(0XFF7371FC);
  Color text_func_button_on = Color(0XFF7371FC);
  Color text_func_button_off = Color(0XFFCDC1FF);

  static final clientID = 0;
  BluetoothConnection? connection;

  List<_Message> messages = List<_Message>.empty(growable: true);
  String _messageBuffer = '';

  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  bool isConnecting = true;

  bool get isConnected => (connection?.isConnected ?? false);

  bool isDisconnecting = false;

  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection!.input!.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
      Navigator.of(context).pop();
      throw UnimplementedError();
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0XFF7371FC),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('FUNCIONALIDADES'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 4,
      ),
      body: Center(
          child: ListView(children: [
        GestureDetector(
          onTap: () {
            if (isConnected) {
              if (func1 == false) {
                _sendMessage("a1");
                setState(() {
                  func1 = true;
                  first_func_button = button_on;
                  first_func_text = text_func_button_on;
                });
              } else {
                _sendMessage("a0");
                setState(() {
                  func1 = false;
                  first_func_button = button_off;
                  first_func_text = text_func_button_off;
                });
              }
            }
          },
          child: Container(
            height: 75,
            width: 55,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            alignment: Alignment.center,
            child: Text('Funcionalidade 1',
                maxLines: 3,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    color: first_func_text,
                    fontWeight: FontWeight.bold)),
            decoration: BoxDecoration(
              color: first_func_button,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Color(0xff5C5BB4).withOpacity(0.5),
                  spreadRadius: 7,
                  blurRadius: 6,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            if (isConnected) {
              if (func2 == false) {
                _sendMessage("b1");
                setState(() {
                  func2 = true;
                  second_func_button = button_on;
                  second_func_text = text_func_button_on;
                });
              } else {
                _sendMessage("b0");
                setState(() {
                  func2 = false;
                  second_func_button = button_off;
                  second_func_text = text_func_button_off;
                });
              }
            }
          },
          child: Container(
            height: 75,
            width: 55,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            alignment: Alignment.center,
            child: Text('Funcionalidade 2',
                maxLines: 3,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    color: second_func_text,
                    fontWeight: FontWeight.bold)),
            decoration: BoxDecoration(
              color: second_func_button,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Color(0xff5C5BB4).withOpacity(0.5),
                  spreadRadius: 7,
                  blurRadius: 6,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
          ),
        ),
      ])),
    );
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    print(dataString);


  }

  void _sendMessage(String text) async {
    text = text.trim();
    textEditingController.clear();
    print(text);
    if (text.length > 0) {
      try {
        connection!.output.add(Uint8List.fromList(utf8.encode(text + "\r\n")));
        await connection!.output.allSent;

      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }
}
