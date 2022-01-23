import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';

class QrGenerate extends StatefulWidget {
  final String customerID;

  const QrGenerate({Key? key, required this.customerID}) : super(key: key);

  @override
  State<QrGenerate> createState() => _QrGenerateState();
}

class _QrGenerateState extends State<QrGenerate> {
  TextEditingController areaController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  ScreenshotController screenshotController = ScreenshotController();
  String carpetType = "ince";

  String area = "";
  String price = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("QR Kod Oluşturma Sayfası", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Information text
          _getUser(context),
          // Space
          // Carpet
          _printCarpetInfo(),

          const Spacer(),
          Row(
            children: [
              Expanded(child: _generateAnotherQRButton(context)),
              Expanded(child: _generateButton()),
            ],
            mainAxisSize: MainAxisSize.max,
          )
        ],
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _getUser(BuildContext context) {
    // Getting customer collection
    CollectionReference customers = FirebaseFirestore.instance.collection('customers');

    return FutureBuilder<DocumentSnapshot>(
      future: customers.doc(widget.customerID).get(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text("Bir şeyler yanlış gitti.");
        }
        if (snapshot.hasData && !snapshot.data!.exists) {
          return const Text("Müşteri sistemde kayıtlı değil");
        }
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
          return _printCustomerInfo(data['address'], data['city'], data['district'], data['neighborhood'], data['name'], data['phone']);
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _printCustomerInfo(address, city, district, neighborhood, name, phone) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
          color: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Spacing between Appbar and Müşteri Bilgileri
              const Align(
                child: SizedBox.square(
                  dimension: 20,
                ),
                alignment: Alignment.center,
              ),

              // Text: Müşteri Bilgileri
              const Center(
                child: Text(
                  "Müşteri Bilgileri",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              // Spacing between Müşteri Bilgileri and texts
              const Align(
                child: SizedBox.square(
                  dimension: 20,
                ),
                alignment: Alignment.center,
              ),

              Row(
                children: [
                  Column(
                    children: [
                      RichText(
                          text: const TextSpan(
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                height: 1.5,
                              ),
                              children: <TextSpan>[
                            TextSpan(text: "  İsim\n", style: TextStyle(color: Colors.white)),
                            TextSpan(text: "  Telefon\n", style: TextStyle(color: Colors.white)),
                            TextSpan(text: "  Şehir\n", style: TextStyle(color: Colors.white)),
                            TextSpan(text: "  İlçe\n", style: TextStyle(color: Colors.white)),
                            TextSpan(text: "  Semt\n", style: TextStyle(color: Colors.white)),
                            TextSpan(text: "  Adres\n", style: TextStyle(color: Colors.white)),
                          ]))
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                  ),
                  const Align(
                    child: SizedBox.square(
                      dimension: 10,
                    ),
                    alignment: Alignment.center,
                  ),
                  Column(
                    children: [
                      RichText(
                          text: TextSpan(
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                height: 1.5,
                              ),
                              children: <TextSpan>[
                            TextSpan(text: ": $name   \n", style: const TextStyle(color: Colors.white)),
                            TextSpan(text: ": $phone  \n", style: const TextStyle(color: Colors.white)),
                            TextSpan(text: ": ${city[0].toUpperCase()}${city.substring(1)}   \n", style: const TextStyle(color: Colors.white)),
                            TextSpan(text: ": ${district[0].toUpperCase()}${district.substring(1)}\n", style: const TextStyle(color: Colors.white)),
                            TextSpan(text: ": ${neighborhood[0].toUpperCase()}${neighborhood.substring(1)}\n", style: const TextStyle(color: Colors.white)),
                            TextSpan(text: ": $address\n", style: const TextStyle(color: Colors.white)),
                          ]))
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                  )
                ],
              ),
            ],
          )),
    );
  }

  Widget _printCarpetInfo() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        // Text: Yeni Halı Bilgileri
        const Center(
          child: Text(
            "Yeni Halı Bilgileri",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        // Spacing between Yeni Halı Bilgileri and texts
        const Align(
          child: SizedBox.square(
            dimension: 20,
          ),
          alignment: Alignment.center,
        ),

        Padding(
          padding: const EdgeInsets.all(15),
          child: TextFormField(
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
              hintText: "Halı Ölçüsü (örnek: 3m²)",
            ),
            keyboardType: TextInputType.phone,
            cursorWidth: 2,
            cursorHeight: 20,
            cursorColor: Colors.black,
            controller: areaController,
            onChanged: (val) => area = val,
            autocorrect: false,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15),
          child: TextFormField(
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
              hintText: "Halının Fiyatı (örnek: 24.8₺)",
            ),
            keyboardType: TextInputType.phone,
            cursorWidth: 2,
            cursorHeight: 20,
            cursorColor: Colors.black,
            controller: priceController,
            onChanged: (val) => price = val,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15),
          child: _carpetTypeButton(),
        ),
      ],
    );
  }

  Widget _generateAnotherQRButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ElevatedButton(
        // Customization
        child: const Text("Başka QR Kod Oluştur"),
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.black),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ))),
        // Functional Partf
        onPressed: () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (context) => QrGenerate(customerID: widget.customerID)));
        },
      ),
    );
  }

  Widget _generateButton() {
    String customerID = widget.customerID;
    String status = "Alındı";
    String type = carpetType;
    String newCarpetID = "";

    return Padding(
      child: ElevatedButton(
          // Customization
          child: const Text("Oluştur"),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.black),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ))),
          // Functional Partf
          onPressed: () {
            if (area.isEmpty && price.isEmpty) {
              Fluttertoast.showToast(msg: "Ölçü ve fiyat kısımlarını boş bıraktınız.", toastLength: Toast.LENGTH_LONG);
            } else if (area.isEmpty) {
              Fluttertoast.showToast(msg: "Ölçü kısmını boş bıraktınız.", toastLength: Toast.LENGTH_LONG);
            } else if (price.isEmpty) {
              Fluttertoast.showToast(msg: "Fiyat kısmını boş bıraktınız.", toastLength: Toast.LENGTH_LONG);
            } else {
              _getNewCarpetID(area, price, customerID, status, type).then((value) => {
                    newCarpetID = value,
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Screenshot(
                                  controller: screenshotController,
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: 200,
                                    height: 300,
                                    child: QrImage(
                                      data: newCarpetID,
                                      backgroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                                Text("Halı ID'si: $newCarpetID"),
                                const SizedBox(
                                  height: 20,
                                ),
                                IconButton(
                                  onPressed: _takeScreenshot,
                                  icon: const Icon(Icons.download_rounded),
                                  iconSize: 50,
                                )
                              ],
                            ),
                          );
                        })
                  });
            }
          }),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    );
  }

  Future<String> _getNewCarpetID(area, cost, customerID, status, type) async {
    CollectionReference carpets = FirebaseFirestore.instance.collection("carpets");

    DocumentReference docRef = await carpets.add({
      'area': area,
      'cost': cost,
      'customer_id': customerID,
      'status': status,
      'type': type,
    });
    return docRef.id;
  }

  Widget _carpetTypeButton() {
    return Row(
      children: [
        const Text(
          "Halının tipi : ",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        Expanded(
          child: DropdownButton<String>(
            value: carpetType,
            alignment: Alignment.center,
            iconSize: 24,
            elevation: 0,
            style: const TextStyle(color: Colors.black, fontSize: 20),
            underline: Container(
              height: 2,
              color: Colors.black,
            ),
            onChanged: (String? newValue) {
              setState(() {
                carpetType = newValue!;
              });
            },
            items: <String>['ince', 'orta', 'kalın'].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _takeScreenshot() async {
    final uint8List = await screenshotController.capture();
    String tempPath = (await getTemporaryDirectory()).path;
    File file = File('$tempPath/image.png');
    await file.writeAsBytes(uint8List!);
    await Share.shareFiles([file.path]);
  }
}
