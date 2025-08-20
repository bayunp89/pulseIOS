import 'dart:convert';

import 'package:app_pulse/screens/add_nozzle.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:app_pulse/widgets/custom_scaffold.dart';
import 'package:app_pulse/theme/theme.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:app_pulse/mqtt/state/mqtt_appstate.dart';
import 'package:provider/provider.dart';
import 'package:app_pulse/mqtt/mqtt_service.dart';

class homeScreen extends StatefulWidget {
  final String emailID;
  const homeScreen({Key? key, required this.emailID}) : super(key: key);

  @override
  State<homeScreen> createState() => _homeScreenState();
}

class _homeScreenState extends State<homeScreen> {
  final myBox = Hive.box('userData');
  final List<TextEditingController> textController = [TextEditingController()];
  final TextEditingController _textFieldController = TextEditingController();
  final TextEditingController _textBoxPanel = TextEditingController();
  final TextEditingController _textBoxNozzle = TextEditingController();
  final DatabaseReference _dbref = FirebaseDatabase.instance.ref();
  final MQTTAppState currentAppState = MQTTAppState();
  final String _topic = 'MQTTsample/cimacan/1/value';
  final String _publishTopic = 'MQTTsample/cimacan/1/set';


  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final mqtt = context.read<MqttService>();

      // 👉 Setting broker dipanggil di HomePage:
      // bisa hardcode, atau ambil dari Hive/DB sesuai kebutuhan
      final String broker = myBox.get(widget.emailID)[3] as String; // contoh dari pertanyaanmu
      final int port = 1883;
      final String clientId = 'flutter_${DateTime.now().millisecondsSinceEpoch}';

      // 1) Connect ke broker
      await mqtt.connect(
        broker: broker,
        port: port,
        clientId: clientId,
      );

      // 2) Ambil daftar nozzle dari Firebase
      final site = myBox.get(widget.emailID)[2] as String; // contoh: "cimacan"
      final snap = await _dbref.child(site).get();

      // 3) Subscribe topik untuk semua nozzle
      if (snap.exists) {
        for (final child in snap.children) {
          final addr = child.key!;
          mqtt.subscribeTopic('MQTTsample/$site/$addr/value');
          mqtt.subscribeTopic('MQTTsample/$site/$addr/set');
        }
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Container(
        margin: const EdgeInsets.only(top: 0, left: 24, right: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hi, ${myBox.get(widget.emailID)[0]}',
                  style: TextStyle(
                    fontSize: 18,
                    color: lightColorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                RotatedBox(
                  quarterTurns: 135,
                  child: IconButton(
                    icon: Icon(Icons.bar_chart_rounded),
                    color: lightColorScheme.onPrimaryContainer,
                    iconSize: 28,
                    onPressed: () {
                      // Handle button press
                      _displayTextInputPassword(context);
                      //createRecord();
                      //_configureAndConnect();
                      // connect();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<DatabaseEvent>(
                future: _dbref.child(myBox.get(widget.emailID)[2]).once(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData ||
                      snapshot.data!.snapshot.value == null) {
                    return Center(child: Text('No data found.'));
                  }
                  final children = snapshot.data!.snapshot.children.toList();
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: children.length, // jumlah nozzle, bisa dynamic
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _cardMenu(
                          title: '',
                          color: Colors.white,
                          fontColor: Colors.white,
                          namaNozzle: children[index].key ?? '',
                          konstanta: children[index].value.toString(),
                          indexCard: index,
                          addr: children[index].key ?? '',
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardMenu({
    required String title,
    Color color = Colors.white,
    Color fontColor = Colors.grey,
    required String namaNozzle,
    required String konstanta,
    required int indexCard,
    required String addr,
  }) {
    return Selector<MqttService, bool>(
      selector: (_, mqtt) => mqtt.isClientOnline(addr),
      builder: (_, isOnline, __) {
        final cardColor = isOnline ? Colors.white : Colors.grey.shade400;
        final textColor = isOnline
            ? lightColorScheme.onPrimaryContainer
            : Colors.grey.shade600;

        return GestureDetector(
          child: Opacity(
            opacity: isOnline
                ? 1.0
                : 0.5, // Set opacity based on online status)
            child: Container(
              //padding: const EdgeInsets.symmetric(vertical: 30),
              width: 350,
              height: 100,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: Offset(0, 5),
                  ),
                ],
                gradient: LinearGradient(
                  colors: [
                    isOnline
                        ? lightColorScheme.primaryContainer
                        : Colors.grey.shade400,
                    isOnline
                        ? const Color.fromARGB(255, 239, 233, 240)
                        : Colors.grey.shade500,
                  ], // List of colors for the gradient
                  begin: Alignment.bottomLeft, // Starting point of the gradient
                  end: Alignment.bottomRight, // Ending point of the gradient
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Selector<MqttService, bool>(
                          selector: (_, mqtt) => mqtt.isClientOnline(addr),
                          builder: (_, isOnline, __) {
                            return Container(
                              margin: const EdgeInsets.fromLTRB(5, 5, 5, 0),
                              width: 100,
                              height: 25,
                              decoration: BoxDecoration(
                                color: isOnline ? Colors.green : Colors.red,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  isOnline ? 'ONLINE' : 'OFFLINE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: GestureDetector(
                            onTap: () {
                              // Your action when the text is tapped
                              _displayTextInputDialog(context, indexCard);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(
                                top: 5,
                                left: 10,
                                right: 24,
                              ),
                              child: StreamBuilder<DatabaseEvent>(
                                stream: _dbref
                                    .child(myBox.get(widget.emailID)[2])
                                    .child(namaNozzle)
                                    .child('nama')
                                    .onValue, // listen terus kalau ada perubahan
                                builder:
                                    (
                                      context,
                                      AsyncSnapshot<DatabaseEvent> snapshot,
                                    ) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Text(
                                          'Loading...',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: lightColorScheme
                                                .onPrimaryContainer,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      }
                                      if (!snapshot.hasData ||
                                          snapshot.data!.snapshot.value ==
                                              null) {
                                        return Text(
                                          'No data',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: lightColorScheme
                                                .onPrimaryContainer,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      }

                                      String name = snapshot
                                          .data!
                                          .snapshot
                                          .value
                                          .toString();

                                      return Text(
                                        name,
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: lightColorScheme
                                              .onPrimaryContainer,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              Container(
                                width: 80,
                                height: 40,
                                margin: const EdgeInsets.fromLTRB(8, 5, 5, 5),
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 5,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white38,
                                ),

                                child: FutureBuilder(
                                  future: _dbref
                                      .child(myBox.get(widget.emailID)[2])
                                      .child(namaNozzle)
                                      .child('value')
                                      .once(),
                                  builder:
                                      (
                                        context,
                                        AsyncSnapshot<DatabaseEvent> snapshot,
                                      ) {
                                        String name = '...';
                                        if (snapshot.connectionState ==
                                                ConnectionState.done &&
                                            snapshot.hasData) {
                                          name =
                                              snapshot.data!.snapshot.value
                                                  ?.toString() ??
                                              '';
                                        }
                                        if (textController.length <=
                                            indexCard) {
                                          textController.add(
                                            TextEditingController(),
                                          );
                                        }
                                        return TextField(
                                          controller: textController[indexCard],
                                          readOnly: !isOnline,
                                          decoration: InputDecoration(
                                            hintText: name,
                                            hintStyle: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: lightColorScheme
                                                  .onPrimaryContainer,
                                            ),
                                            border: InputBorder.none,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 10,
                                                ),
                                          ),
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: lightColorScheme
                                                .onPrimaryContainer,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      },
                                ),
                              ),
                              SizedBox(width: 30),
                              ElevatedButton(
                                onPressed: isOnline
                                    ? () {
                                        final site = myBox.get(
                                          widget.emailID,
                                        )[2]; // contoh: "cimacan"
                                        final addrs =
                                            addr; // bisa dinamis sesuai kebutuhan
                                        final value = textController[indexCard]
                                            .text; // bisa diambil juga dari Hive
                                        final mqttService =
                                            Provider.of<MqttService>(
                                              context,
                                              listen: false,
                                            );
                                        final payload = {
                                          "status":
                                              mqttService
                                                  .getMessageByAddr(addrs)
                                                  ?.status ??
                                              '0',
                                          "tipe": "5",
                                          "site": site,
                                          "addr": addrs,
                                          "value": value,
                                        };

                                        final jsonString = jsonEncode(payload);

                                        context.read<MqttService>().publishMessage(
                                          'MQTTsample/${myBox.get(widget.emailID)[2]}/${addrs}/set',
                                          jsonString,
                                        );

                                        _dbref
                                            .child(myBox.get(widget.emailID)[2])
                                            .child((indexCard + 1).toString())
                                            .child('value')
                                            .set(
                                              textController[indexCard].text,
                                            );
                                        Fluttertoast.showToast(
                                          msg: "Value Updated",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          backgroundColor: Colors.green,
                                          textColor: Colors.white,
                                        );
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      lightColorScheme.secondaryContainer,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 40,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'SET',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Selector<MqttService, String?>(
                      selector: (_, mqtt) =>
                          mqtt.getMessageByAddr(addr)?.status,
                      builder: (_, status, __) {
                        if (status == null) {
                          return Padding(
                            padding: EdgeInsets.all(8.0),
                            child: statusImage('assets/images/power_red.png'),
                          );
                        }
                        return GestureDetector(
                          onTap: isOnline
                              ? () async {
                                  // Ambil value dulu (harus await)
                                  final event = await _dbref
                                      .child(myBox.get(widget.emailID)[2])
                                      .child(addr)
                                      .child('value')
                                      .once();

                                  final value =
                                      event.snapshot.value?.toString() ?? '200';
                                  // contoh: kirim balik ke MQTT ketika status di-tap
                                  final payload = {
                                    "status": status == "1"
                                        ? "0"
                                        : "1", // toggle status
                                    "tipe": "5",
                                    "site": myBox.get(widget.emailID)[2],
                                    "addr": addr,
                                    "value": value,
                                  };
                                  final jsonString = jsonEncode(payload);
                                  context.read<MqttService>().publishMessage(
                                    'MQTTsample/${myBox.get(widget.emailID)[2]}/${addr}/set',
                                    jsonString,
                                  );
                                }
                              : null, // hanya bisa di-tap jika online
                          child: statusImage(status), // gambar status kamu
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget statusImage(String status) {
    switch (status) {
      case "1":
        return Image.asset(
          'assets/images/power_green.png',
          width: 52,
          height: 52,
        );
      case "0":
        return Image.asset(
          'assets/images/power_red.png',
          width: 52,
          height: 52,
        );
      default:
        return Image.asset(
          'assets/images/power_red.png',
          width: 52,
          height: 52,
        );
    }
  }

  Future<void> _displayTextInputPassword(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
          backgroundColor: Colors.white60,
          title: Text('Password'),
          content: TextField(
            controller: _textFieldController,
            decoration: InputDecoration(hintText: "Enter your password"),
            obscureText: true,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                if (_textBoxPanel.text.isNotEmpty) {
                  //print(_textFieldController.text);
                  if (_textFieldController.text == 'adminPOS4321') {
                    _textFieldController.clear();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddNozzleScreen(userID: widget.emailID),
                      ),
                    );
                  } else {
                    Fluttertoast.showToast(
                      msg: "Incorrect password",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                    );
                  }
                } else {
                  // Show an error message or handle empty input
                  Fluttertoast.showToast(
                    msg: "Please enter a valid input",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                  );
                }
                //Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _displayTextInputDialog(
    BuildContext context,
    int indexCard,
  ) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Change Name of Nozzle',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _textBoxNozzle,
                  decoration: InputDecoration(hintText: "Enter new name"),
                ),
                SizedBox(height: 20),
                TextButton(
                  child: Text('CANCEL'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    _dbref
                        .child(myBox.get(widget.emailID)[2])
                        .child((indexCard + 1).toString())
                        .child('nama')
                        .set(_textBoxNozzle.text);

                    _textBoxNozzle.clear();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
