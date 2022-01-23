import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'qr_scan.dart';

class QrEdit extends StatefulWidget {
  final String? qrID;

  const QrEdit({Key? key, required this.qrID}) : super(key: key);

  @override
  _QrEditState createState() => _QrEditState();
}

class _QrEditState extends State<QrEdit> {
  List<bool> isSelected = [false, false, false, false];
  String currentCarpetStatus = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Halı Durumu Sayfası", style: TextStyle(color: Colors.black)),
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
          _getCarpets(context),
          // Space
          const Spacer(),
          // Bottom Buttons
          Row(
            children: [
              Expanded(child: _readAnotherQRButton()),
              Expanded(child: _saveButton()),
            ],
            mainAxisSize: MainAxisSize.max,
          )
        ],
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _getUser(BuildContext context, String customerID) {
    // Getting customer collection
    CollectionReference customers = FirebaseFirestore.instance.collection('customers');

    return FutureBuilder<DocumentSnapshot>(
      future: customers.doc(customerID).get(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text("Something went wrong.");
        }
        if (snapshot.hasData && !snapshot.data!.exists) {
          return const Text("Customer does not exist");
        }
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
          return _printCustomerInfo(data['address'], data['city'], data['district'], data['neighborhood'], data['name'], data['phone'], data['email']);
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _printCustomerInfo(address, city, district, neighborhood, name, phone, email) {
    return Card(
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
                          TextSpan(text: ": $name   \n", style: TextStyle(color: Colors.white)),
                          TextSpan(text: ": $phone  \n", style: TextStyle(color: Colors.white)),
                          TextSpan(text: ": ${city[0].toUpperCase()}${city.substring(1)}   \n", style: TextStyle(color: Colors.white)),
                          TextSpan(text: ": ${district[0].toUpperCase()}${district.substring(1)}\n", style: TextStyle(color: Colors.white)),
                          TextSpan(text: ": ${neighborhood[0].toUpperCase()}${neighborhood.substring(1)}\n", style: TextStyle(color: Colors.white)),
                          TextSpan(text: ": $address\n", style: TextStyle(color: Colors.white)),
                        ]))
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                )
              ],
            ),
          ],
        ));
  }

  Widget _getCarpets(BuildContext context) {
    // Getting customer collection
    CollectionReference carpets = FirebaseFirestore.instance.collection('carpets');

    return FutureBuilder<DocumentSnapshot>(
      future: carpets.doc(widget.qrID).get(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text("Something went wrong.");
        }
        if (snapshot.hasData && !snapshot.data!.exists) {
          return const Text("Carpet does not exist");
        }
        if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;

          if (currentCarpetStatus.isEmpty) {
            switch (data['status']) {
              case "Alındı":
                isSelected = [true, false, false, false];
                break;
              case "Yıkanıyor":
                isSelected = [false, true, false, false];
                break;
              case "Kuruyor":
                isSelected = [false, false, true, false];
                break;
              case "Getiriliyor":
                isSelected = [false, false, false, true];
                break;
              default:
            }
          }

          return _printCarpetInfo(data['area'], data['cost'], data['status'], data['type'], data['customer_id']);
        }

        return const Expanded(
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _printCarpetInfo(area, cost, status, type, customerID) {
    return Column(
      children: [
        _getUser(context, customerID),
        // Text: Halı Bilgileri
        const Align(
          child: SizedBox.square(
            dimension: 20,
          ),
          alignment: Alignment.center,
        ),

        const Center(
          child: Text(
            "Halı Bilgileri",
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

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
                      TextSpan(text: "  Alan\n"),
                      TextSpan(text: "  Fiyat\n"),
                      TextSpan(text: "  Durum\n"),
                      TextSpan(text: "  Tür\n"),
                    ]))
              ],
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
            ),
            const Align(
              child: SizedBox.square(
                dimension: 20,
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
                      TextSpan(text: ": $area m²\n"),
                      TextSpan(text: ": $cost ₺\n"),
                      TextSpan(text: ": ${status[0].toUpperCase()}${status.substring(1)}   \n"),
                      TextSpan(text: ": $type\n"),
                    ]))
              ],
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
            )
          ],
        ),

        // ToggleButtons
        _carpetStateToggleButtons(),
      ],
    );
  }

  Widget _carpetStateToggleButtons() {
    return Center(
      child: Column(
        children: [
          const Text(
            "Halı Durumunu Değiştir\n",
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ToggleButtons(
              children: const [
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text("Alındı", style: TextStyle(fontSize: 20)),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text("Yıkanıyor", style: TextStyle(fontSize: 20)),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text("Kuruyor", style: TextStyle(fontSize: 20)),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text("Getiriliyor", style: TextStyle(fontSize: 20)),
                ),
              ],
              isSelected: isSelected,
              onPressed: (index) {
                setState(() {
                  switch (index) {
                    case 0:
                      isSelected = [true, false, false, false];
                      currentCarpetStatus = "Alındı";
                      break;
                    case 1:
                      isSelected = [false, true, false, false];
                      currentCarpetStatus = "Yıkanıyor";
                      break;
                    case 2:
                      isSelected = [false, false, true, false];
                      currentCarpetStatus = "Kuruyor";
                      break;
                    case 3:
                      isSelected = [false, false, false, true];
                      currentCarpetStatus = "Getiriliyor";
                      break;
                    default:
                      isSelected = [false, false, false, false];
                      currentCarpetStatus = "empty";
                      break;
                  }
                });
              },
              borderWidth: 1,
              borderRadius: BorderRadius.circular(18),
              fillColor: Colors.amber,
              selectedColor: Colors.black,
              borderColor: Colors.black,
              selectedBorderColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _saveButton() {
    return Padding(
      child: ElevatedButton(
        // Customization
        child: const Text("Kaydet"),
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.black),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ))),
        // Functional Partf
        onPressed: () {
          _updateCarpetStatus();
          setState(() {});
        },
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    );
  }

  Future<void> _updateCarpetStatus() {
    CollectionReference carpets = FirebaseFirestore.instance.collection('carpets');

    return carpets
        .doc(widget.qrID)
        .update({'status': currentCarpetStatus})
        .then((value) => Fluttertoast.showToast(
              msg: "Halı durumu başarıyla $currentCarpetStatus yapıldı.",
            ))
        .catchError((error) => Fluttertoast.showToast(
              msg: "Durum değiştirme başarısız.",
            ));
  }

  Widget _readAnotherQRButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ElevatedButton(
        // Customization
        child: const Text("Başka QR Kod Okut"),
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.black),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ))),
        // Functional Partf
        onPressed: () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (context) => const QrScan()));
        },
      ),
    );
  }
}
