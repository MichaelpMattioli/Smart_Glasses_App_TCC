import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/ui/ConfigurationPage.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../main.dart';
import 'Functionalities.dart';
import 'ConfigurationPage.dart';

class HomePage extends StatefulWidget {
  final bool checkAvailability;

  HomePage({Key? key, this.checkAvailability = true}) : super(key: key);

  @override
  _HomePage createState() => new _HomePage();
}

enum _DeviceAvailability {
  no,
  maybe,
  yes,
}

class _DeviceWithAvailability {
  BluetoothDevice device;
  _DeviceAvailability availability;

  _DeviceWithAvailability(this.device, this.availability);
}

class _HomePage extends State<HomePage> {
  String _address = "...";
  String _name = "...";

  double batteryLevel = 0;

  //Devices bonded
  List<_DeviceWithAvailability> devices =
      List<_DeviceWithAvailability>.empty(growable: true);
  BluetoothDevice? selectedDevice;

  //Connection Bluetooth
  BluetoothConnection? connection;
  bool isConnecting = true;

  bool get isConnected => (connection?.isConnected ?? false);
  bool isDisconnecting = false;

  _HomePage();

  var info_battery = Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        "Não conectado",
        style: TextStyle(
            fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
      )
    ],
  );

  Icon bluetooth_icon =
      Icon(Icons.bluetooth_disabled, size: 25, color: Color(0xFF4D7FAE));

  @override
  void initState() {
    super.initState();

    // bool isDevicePared = selectedDevice!.isConnected;

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          _address = address!;
        });
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name!;
      });
    });

    // Setup a list of the bonded devices
    FlutterBluetoothSerial.instance
        .getBondedDevices()
        .then((List<BluetoothDevice> bondedDevices) {
      setState(() {
        devices = bondedDevices
            .map(
              (device) => _DeviceWithAvailability(
                device,
                widget.checkAvailability
                    ? _DeviceAvailability.maybe
                    : _DeviceAvailability.yes,
              ),
            )
            .toList();
      });
    });
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);

    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }

    super.dispose();
  }

  Future<bool>? test_connection_with_bluetooth(BluetoothDevice? server) {
    print(server);
    BluetoothConnection.toAddress(server?.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });
      final listener_data_bluetooth =
          connection!.input!.listen(_onDataReceived);

      listener_data_bluetooth.onDone(() {
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
      listener_data_bluetooth.onData((data) {
        String? stringData = _onDataReceived(data);
        if (stringData!.contains("paring_returned")) {
          print("ping pong - Success");
          isDisconnecting = true;
          connection?.dispose();
          connection = null;
          change_screen_of_connection_device_successful();
          navigatorKey.currentState!.pop();
        }
      });
      _sendMessage("init_paring");
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
      change_screen_of_connection_device_failed();
      selectedDevice = null;
      navigatorKey.currentState!.pop();
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          alignment: Alignment.center,
          actionsAlignment: MainAxisAlignment.center,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(24))),
          title: Text("\nNão foi possivel conectar ao dispositivo.",
              maxLines: 3,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 19,
                  color: Color(0XFF7371FC),
                  fontWeight: FontWeight.bold)),
          actions: <Widget>[
            TextButton(
              child: const Text('OK',
                  maxLines: 3,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16,
                      color: Color(0XFF7371FC),
                      fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      );
    });
  }

  String? _onDataReceived(Uint8List data) {
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
    return dataString;
  }

  Future _sendMessage(String text) async {
    text = text.trim();
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

  BluetoothDevice? select_raspberryPi_as_device() {
    for (var device in devices) {
      if (device.device.name.toString().contains("raspberry")) {
        print(device.device.name);
        selectedDevice = device.device;
      }
    }
  }

  void change_screen_of_connection_device_successful() {
    print(
        'Connect -> selected ${selectedDevice?.address} + ${selectedDevice?.isConnected}');
    setState(() {
      batteryLevel = 60;
      info_battery = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.battery_1_bar_rounded, size: 25, color: Colors.white),
          Text(
            batteryLevel.toString() + "%",
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          )
        ],
      );
    });
  }

  void change_screen_of_connection_device_failed() {
    setState(() {
      batteryLevel = 0;
      info_battery = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Não conectado",
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          )
        ],
      );
    });
  }

  Future<bool?> connect_to_raspberry() async {
    bool isConnect = false;
    await Future.doWhile(() async {
      // Wait if adapter not enabled
      if (devices.length > 0) {
        return false;
      }
      await Future.delayed(Duration(seconds: 60));
      return true;
    }).then((value) => select_raspberryPi_as_device());
    return isConnect;
  }

  void _startFunctionalities(BuildContext context, BluetoothDevice server) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return FunctionPage(server: server);
        },
      ),
    );
  }

  void _startConfiguration(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ConfigurationPage();
        },
      ),
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    showLoaderDialog(BuildContext context) {
      AlertDialog alert = AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            Container(
                margin: EdgeInsets.only(left: 7),
                // alignment: Alignment.center,
                child: Text("Loading...")),

          ],
        ),
      );
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          alignment: Alignment.center,
          actionsAlignment: MainAxisAlignment.center,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(24))),
          title: Text("Conectando ao dispositivo\n aguarde...",
              maxLines: 3,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 19,
                  color: Color(0XFF7371FC),
                  fontWeight: FontWeight.bold)),
          actions: <Widget>[
            CircularProgressIndicator(
              color: Color(0XFF7371FC),
            ),
          ],
        ),
      );
    }

    Future connectToRasp() async {
      showLoaderDialog(context);
      try {
        await connect_to_raspberry();
        await test_connection_with_bluetooth(selectedDevice);
      } catch (e) {
        print(e);
      }
    }

    return Scaffold(
      backgroundColor: Color(0xFF7371FC),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('SMART GLASS'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app_rounded),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  alignment: Alignment.center,
                  actionsAlignment: MainAxisAlignment.center,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(24))),
                  title: Text("\nRealmente deseja desconectar?",
                      maxLines: 3,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 19,
                          color: Color(0XFF7371FC),
                          fontWeight: FontWeight.bold)),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Discordo',
                          maxLines: 3,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16,
                              color: Color(0XFF7371FC),
                              fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                    ),
                    TextButton(
                      child: const Text('Quero sair',
                          maxLines: 3,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 15,
                              color: Color(0XFFFC71A3),
                              fontWeight: FontWeight.bold)),
                      onPressed: () {
                        navigatorKey.currentState!.pop();
                        _signOut();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        titleSpacing: 4,
      ),
      body: ListView(children: <Widget>[
        Column(children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 325,
                        height: 350,
                        margin: EdgeInsets.symmetric(
                            vertical:
                                (MediaQuery.of(context).size.height) * 0.03),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                          color: Color(0XFF7371FC),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xff5C5BB4).withOpacity(0.5),
                              spreadRadius: 7,
                              blurRadius: 6,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 250,
                        height: 250,
                        margin: EdgeInsets.symmetric(
                            vertical:
                                (MediaQuery.of(context).size.height) * 0.07),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0XFF7371FC),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xff5C5BB4).withOpacity(0.6),
                              spreadRadius: 7,
                              blurRadius: 6,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 250,
                        height: 250,
                        margin: EdgeInsets.symmetric(
                            vertical:
                                (MediaQuery.of(context).size.height) * 0.07),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Color(0XFFF5EFFF)),
                        child: SfRadialGauge(axes: <RadialAxis>[
                          RadialAxis(
                            minimum: 0,
                            maximum: 100,
                            showLabels: false,
                            showTicks: false,
                            axisLineStyle: AxisLineStyle(
                              thickness: 0.08,
                              cornerStyle: CornerStyle.bothCurve,
                              color: Color(0XFF7371FC),
                              thicknessUnit: GaugeSizeUnit.factor,
                            ),
                            pointers: <GaugePointer>[
                              RangePointer(
                                value: batteryLevel,
                                cornerStyle: CornerStyle.bothCurve,
                                width: 0.08,
                                sizeUnit: GaugeSizeUnit.factor,
                                color: Colors.white,
                              )
                            ],
                          )
                        ]),
                      ),
                      Container(
                        width: 125,
                        height: 125,
                        margin: EdgeInsets.symmetric(
                            vertical:
                                (MediaQuery.of(context).size.height) * 0.07),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0XFF7371FC),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.9),
                                spreadRadius: -7,
                                blurRadius: 6,
                                offset:
                                    Offset(0, 3), // changes position of shadow
                              ),
                            ]),
                        child: InkWell(
                            onTap: () async {
                              var deviceName = selectedDevice?.name;
                              var isDeviceBonded = selectedDevice?.isBonded;
                              print(
                                  "Status Device -> ${isDeviceBonded}\n Device -> ${deviceName}");
                              if (isDeviceBonded == null ||
                                  isDeviceBonded == false) {
                                connectToRasp();
                              }
                            },
                            child: Image.asset(
                              'assets/images/glasses.png',
                              fit: BoxFit.fill,
                            )),
                      ),
                    ],
                  ),
                  Container(
                      width: 325,
                      height: 350,
                      margin: EdgeInsets.symmetric(
                          vertical:
                              (MediaQuery.of(context).size.height) * 0.03),
                      padding: const EdgeInsets.all(16),
                      // color: Colors.red,
                      alignment: Alignment.bottomCenter,
                      child: info_battery),
                ],
              ),
            ],
          ),
          Row(//ROW 2
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
            Stack(
              children: [
                Positioned.fill(
                  // top: 0,
                  // bottom: 0,
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: 55,
                        width: 55,
                        margin: EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(Icons.blur_on,
                            size: 30, color: Color(0xFF4D7FAE)),
                        decoration: BoxDecoration(
                            color: Color(0xffF5EFFF),
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                      ),
                      Expanded(
                        // height: 55,
                        // alignment: Alignment.centerLeft,
                        child: Text(
                          'Funcionalidades',
                          maxLines: 3,
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(0, 0, 16, 0),
                        height: 55,
                        alignment: Alignment.centerLeft,
                        child: Icon(Icons.keyboard_arrow_right,
                            color: Color(0xffF5EFFF)),
                      ),
                    ],
                  ),
                ),
                Container(
                  constraints: BoxConstraints(maxWidth: 328, maxHeight: 55),
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  child: InkWell(
                    onTap: () {
                      print(selectedDevice);
                      if (selectedDevice != null) {
                        var isConnectedBlue = selectedDevice?.isConnected;
                        print(isConnectedBlue);
                        try {
                          showLoaderDialog(context);
                          _startFunctionalities(context, selectedDevice!);
                        } catch (ex) {
                          navigatorKey.currentState!.pop();
                        }
                      } else {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: Color(0XFFF5EFFF),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(24))),
                            title: Text("Dispositivo não conectado",
                                maxLines: 3,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 19,
                                    color: Color(0XFF7371FC),
                                    fontWeight: FontWeight.bold)),
                            content: Text(
                                "Funcionalidades são inacessiveis enquanto o dispositivo está desconectado.",
                                textAlign: TextAlign.left,
                                style: TextStyle(fontSize: 16)),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                },
                                child: Text("Ok",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontSize: 17,
                                        color: Color(0XFF7371FC),
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ]),
          Container(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
              child: Divider(color: Color(0xffF5EFFF))),
          Row(//ROW 2
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
            Stack(
              children: [
                Positioned.fill(
                  // top: 0,
                  // bottom: 0,
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: 55,
                        width: 55,
                        margin: EdgeInsets.symmetric(horizontal: 16),
                        child: IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.settings,
                              size: 30, color: Color(0xFF4D7FAE)),
                        ),
                        decoration: BoxDecoration(
                            color: Color(0xffF5EFFF),
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                      ),
                      Expanded(
                        child: Text(
                          'Configurações',
                          maxLines: 3,
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                      Container(
                          padding: EdgeInsets.fromLTRB(0, 0, 16, 0),
                          height: 55,
                          alignment: Alignment.centerLeft,
                          child: Icon(
                            Icons.keyboard_arrow_right,
                            color: Color(0xffF5EFFF),
                          )),
                    ],
                  ),
                ),
                Container(
                  constraints: BoxConstraints(maxWidth: 328, maxHeight: 55),
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  child: InkWell(
                    onTap: () {
                      _startConfiguration(context);
                    },
                  ),
                ),
              ],
            ),
          ]),
        ]),
      ]),
    );
  }
}
