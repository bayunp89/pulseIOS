import 'package:flutter/material.dart';
import 'package:app_pulse/theme/theme.dart';
import 'package:app_pulse/widgets/custom_scaffold.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_database/firebase_database.dart';

class AddNozzleScreen extends StatefulWidget {
  final String userID;
  const AddNozzleScreen({super.key, required this.userID});

  @override
  State<AddNozzleScreen> createState() => _AddNozzleScreenState();
}

class _AddNozzleScreenState extends State<AddNozzleScreen> {
  final _addNozzlebutton = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _tipe = TextEditingController();
  final TextEditingController _value = TextEditingController();
  final TextEditingController _site = TextEditingController();
  final myBox = Hive.box('userData');
  final DatabaseReference _dbref = FirebaseDatabase.instance.ref();

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          Expanded(flex: 0, child: SizedBox(height: 10)),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25, 50, 25, 20),
              decoration: const BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _addNozzlebutton,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Add Nozzle',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: lightColorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      textBoxSite(),
                      const SizedBox(height: 20),
                      textBoxName(),
                      const SizedBox(height: 20),
                      textBoxAddress(),
                      const SizedBox(height: 20),
                      textBoxTipe(),
                      const SizedBox(height: 20),
                      textBoxValue(),
                      const SizedBox(height: 20),
                      buttonSignup(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  SizedBox buttonSignup(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (_addNozzlebutton.currentState!.validate()) {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Add Nozzle'),
                  content: const Text('Are you sure you want to add this nozzle?'),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        if (await _dbref.child(myBox.get(widget.userID)[2])
                            .child(_address.text)
                            .once()
                            .then((snapshot) => snapshot.snapshot.exists)) {
                          Fluttertoast.showToast(
                            msg: "Address already exists",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                          );
                        } else {
                          createRecord();
                          _name.clear();
                          _address.clear();
                          _tipe.clear();
                          _value.clear();
                          _site.clear();
                          Fluttertoast.showToast(
                            msg: "Add Nozzle Successful",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.green,
                            textColor: Colors.white,
                          );
                          //Navigator.pop(context); // Close the dialog
                        }
                      },
                      child: const Text('Yes'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                  ],
                );
              },
            );
          } else {
            Fluttertoast.showToast(
              msg: "Please fill in all fields correctly",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: lightColorScheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          'Add Nozzle',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }


  TextFormField textBoxSite() {
    return TextFormField(
      controller: _site,
      decoration: InputDecoration(
        labelText: 'Site',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your site';
        }
        return null;
      },
    );
  }

  TextFormField textBoxName() {
    return TextFormField(
      controller: _name,
      decoration: InputDecoration(
        labelText: 'Name',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      obscureText: false,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your name';
        }
        return null;
      },
    );
  }

    TextFormField textBoxAddress() {
    return TextFormField(
      controller: _address,
      decoration: InputDecoration(
        labelText: 'Address',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      obscureText: false,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your address';
        }
        return null;
      },
    );
  }

  TextFormField textBoxTipe() {
    return TextFormField(
      controller: _tipe,
      decoration: InputDecoration(
        labelText: 'Tipe',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your Tipe';
        }
        return null;
      },
    );
  }

  TextFormField textBoxValue() {
    return TextFormField(
      controller: _value,
      decoration: InputDecoration(
        labelText: 'Value',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your Value';
        }
        return null;
      },
    );
  }

    void createRecord() {
    DatabaseReference databaseReference = FirebaseDatabase.instance
        .ref(myBox.get(widget.userID)[2])
        .child(_address.text);

    databaseReference.set({
      'nama': _name.text,
      'address': _address.text,
      'tipe': _tipe.text,
      'value': _value.text
    });
  }
}
