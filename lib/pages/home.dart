import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code/pages/login.dart';
import 'package:qr_code/pages/list_carpets.dart';
import 'package:qr_code/pages/qr/qr_generate.dart';
import 'package:qr_code/pages/qr/qr_scan.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController phoneController = TextEditingController();

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,

      /* Body - Buttons */
      body: Center(
        child: Column(
          children: [
            AppBar(
              title: const Text("CarpeTiem", style: TextStyle(fontSize: 30, color: Colors.black)),
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.exit_to_app, color: Colors.black),
                  onPressed: () {
                    _signOut();
                    Fluttertoast.showToast(msg: "Başarıyla çıkış yaptınız.", toastLength: Toast.LENGTH_LONG);
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                  },
                ),
              ],
            ),
            const SizedBox(height: 130),
            /* Logo */
            Image.asset(
              'assets/images/search.png',
              scale: 4,
            ),
            const SizedBox(height: 50),

            /* Customer's phone number */
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: _getPhoneNumber(),
            ),

            /* First Button */
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: _listCarpets(),
            ),

            /* Second Button */
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: _scanQRCode(),
            ),

            /* Third Button */
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: _generateQRCode(),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  ElevatedButton _generateQRCode() {
    return ElevatedButton(
        onPressed: () {
          String phone = phoneController.text;
          if (phone.length != 14) {
            Fluttertoast.showToast(msg: "Lütfen doğru telefon numarası giriniz");
          } else {
            _findUser(phone, "generate");
          }
        },
        child: const Text(
          "QR Kod Oluştur",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ButtonStyle(
            minimumSize: MaterialStateProperty.all(const Size(320, 48)),
            backgroundColor: MaterialStateProperty.all(Colors.black),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ))));
  }

  ElevatedButton _scanQRCode() {
    return ElevatedButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const QrScan()));
        },
        child: const Text(
          "QR Kod Tara",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ButtonStyle(
            minimumSize: MaterialStateProperty.all(const Size(320, 48)),
            backgroundColor: MaterialStateProperty.all(Colors.black),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ))));
  }

  ElevatedButton _listCarpets() {
    return ElevatedButton(
        onPressed: () {
          String phone = phoneController.text;
          if (phone.length != 14) {
            Fluttertoast.showToast(msg: "Lütfen doğru telefon numarası giriniz");
          } else {
            _findUser(phone, "list");
          }
        },
        child: const Text(
          "Halıları Listele",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ButtonStyle(
            minimumSize: MaterialStateProperty.all(const Size(320, 48)),
            backgroundColor: MaterialStateProperty.all(Colors.black),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ))));
  }

  Widget _getPhoneNumber() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: phoneController,
        keyboardType: TextInputType.phone,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(8.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
          hintText: "Müşteri Telefon Numarası",
        ),
        inputFormatters: [MaskTextInputFormatter(mask: "(###) ### ####")],
      ),
    );
  }

  Future _findUser(String phone, String whichButton) async {
    // Customer as QuerySnapshot
    QuerySnapshot customer = await FirebaseFirestore.instance.collection('customers').where('phone', isEqualTo: phone).get();
    // Warn the user if customer doesn't exist
    if (customer.docs.isEmpty) {
      Fluttertoast.showToast(msg: "Bu numarayla kayıtlı müşteri bulunmamakta.");
      return;
    }
    // Getting document snapshot of the query
    QueryDocumentSnapshot doc = customer.docs[0];
    // Document reference of that snapshot
    DocumentReference docRef = doc.reference;

    if (whichButton.compareTo("generate") == 0) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => QrGenerate(customerID: docRef.id)));
    } else if (whichButton.compareTo("list") == 0) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ListCarpets(customerID: docRef.id)));
    }
  }
}
