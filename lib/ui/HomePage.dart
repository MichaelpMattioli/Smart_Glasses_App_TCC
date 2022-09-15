import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../BackgroundCollectingTask.dart';
import 'BluetoothDeviceListEntry.dart';
import 'Functionalities.dart';
import '../SelectBondedDevicePage.dart';

class HomePage extends StatefulWidget {
  //Paleta de cores
  int blue_white = 0xFF4D7FAE;
  int blue_median = 0xFF22496D;
  int purple_strong = 0xFF7371FC;

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
  int? rssi;

  _DeviceWithAvailability(this.device, this.availability, [this.rssi]);
}

class _HomePage extends State<HomePage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  // FlutterBlue flutterBlue = FlutterBlue.instance;

  String _address = "...";
  String _name = "...";

  Timer? _discoverableTimeoutTimer;
  int _discoverableTimeoutSecondsLeft = 0;

  BackgroundCollectingTask? _collectingTask;
  BluetoothDevice? selectedDevice;

  @override
  void initState() {
    super.initState();

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

    //conectar com o raspberry por bluetooth


    List<_DeviceWithAvailability> devices =
    List<_DeviceWithAvailability>.empty(growable: true);

    // Availability
    StreamSubscription<BluetoothDiscoveryResult>? _discoveryStreamSubscription;
    bool _isDiscovering = false;

    // _SelectBondedDevicePage();
    //
    // _isDiscovering = widget.checkAvailability;

    void _startDiscovery() {
      _discoveryStreamSubscription =
          FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
            setState(() {
              Iterator i = devices.iterator;
              while (i.moveNext()) {
                var _device = i.current;
                if (_device.device == r.device) {
                  _device.availability = _DeviceAvailability.yes;
                  _device.rssi = r.rssi;
                }
              }
            });
          });

      _discoveryStreamSubscription?.onDone(() {
        setState(() {
          _isDiscovering = false;
        });
      });
    }

    if (_isDiscovering) {
      _startDiscovery();
    }

    // // Setup a list of the bonded devices
    // FlutterBluetoothSerial.instance
    //     .getBondedDevices()
    //     .then((List<BluetoothDevice> bondedDevices) {
    //   setState(() {
    //     devices = bondedDevices
    //         .map(
    //           (device) => _DeviceWithAvailability(
    //         device,
    //         widget.checkAvailability
    //             ? _DeviceAvailability.maybe
    //             : _DeviceAvailability.yes,
    //       ),
    //     )
    //         .toList();
    //   });
    // });

    void _restartDiscovery() {
      setState(() {
        _isDiscovering = true;
      });

      _startDiscovery();
    }


  }

  Icon bluetooth_icon =
      Icon(Icons.bluetooth_disabled, size: 25, color: Color(0xFF4D7FAE));

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _collectingTask?.dispose();
    _discoverableTimeoutTimer?.cancel();
    super.dispose();
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // retorna um objeto do tipo Dialog
        return AlertDialog(
          title: new Text("Aviso"),
          content: new Text("Não foi estabelecer uma conexão com o óculos"),
          actions: <Widget>[
            // define os botões na base do dialogo
            new TextButton(
              child: new Text("Fechar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    double batteryLevel = 60;
    return Scaffold(
      backgroundColor: Color(0xFF7371FC),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('SMART GLASSES'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app_rounded),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
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
                              selectedDevice = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return SelectBondedDevicePage(
                                        checkAvailability: false);
                                  },
                                ),
                              );
                              // print(selectedDevice?.isConnected);

                              if (selectedDevice != null) {
                                print(
                                    'Connect -> selected ${selectedDevice?.address}');
                                // _startChat(context, selectedDevice);
                              } else {
                                print('Connect -> no device selected');
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
                        vertical: (MediaQuery.of(context).size.height) * 0.03),
                    padding: const EdgeInsets.all(16),
                    // color: Colors.red,
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.battery_1_bar_rounded,
                            size: 25, color: Colors.white),
                        Text(
                          batteryLevel.toString() + "%",
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(//ROW 2
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
            Container(
              height: 55,
              width: 55,
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: Icon(Icons.blur_on, size: 30, color: Color(0xFF4D7FAE)),
              decoration: BoxDecoration(
                  color: Color(0xffF5EFFF),
                  borderRadius: BorderRadius.all(Radius.circular(20))),
            ),
            Expanded(
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
                child: IconButton(
                  onPressed: () {
                    print(selectedDevice);
                    if (selectedDevice != null) {
                      var isConnectedBlue = selectedDevice?.isConnected;
                      print(isConnectedBlue);
                      if (isConnectedBlue == true) {
                        try {
                          _startFunctionalities(context, selectedDevice!);
                        }catch(ex){
                          _showDialog();
                        }
                      }
                    } else {}
                  },
                  icon: Icon(Icons.keyboard_arrow_right,
                      color: Color(0xffF5EFFF)),
                )),
          ]),
          Container(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
              child: Divider(color: Color(0xffF5EFFF))),
          Row(//ROW 3
              children: [
            Container(
              height: 55,
              width: 55,
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: IconButton(
                onPressed: () {},
                icon: Icon(Icons.settings, size: 30, color: Color(0xFF4D7FAE)),
              ),
              decoration: BoxDecoration(
                  color: Color(0xffF5EFFF),
                  borderRadius: BorderRadius.all(Radius.circular(20))),
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
              child: IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.keyboard_arrow_right,
                    color: Color(0xffF5EFFF),
                  )),
            )
          ]),
        ]),
      ]),
    );
  }

// void _startChat(BuildContext context, BluetoothDevice server) {
//   Navigator.of(context).push(
//     MaterialPageRoute(
//       builder: (context) {
//         return ChatPage(server: server);
//       },
//     ),
//   );
// }
//
// Future<void> _startBackgroundTask(
//   BuildContext context,
//   BluetoothDevice server,
// ) async {
//   try {
//     _collectingTask = await BackgroundCollectingTask.connect(server);
//     await _collectingTask!.start();
//   } catch (ex) {
//     _collectingTask?.cancel();
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Error occured while connecting'),
//           content: Text("${ex.toString()}"),
//           actions: <Widget>[
//             new TextButton(
//               child: new Text("Close"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
}
