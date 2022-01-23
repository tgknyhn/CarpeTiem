import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_code/pages/qr/qr_edit.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';

class ListCarpets extends StatefulWidget {
  final String customerID;

  const ListCarpets({Key? key, required this.customerID}) : super(key: key);

  @override
  _ListCarpetsState createState() => _ListCarpetsState();
}

class _ListCarpetsState extends State<ListCarpets> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Müşteri Halıları", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _carpetCards(context),
    );
  }

  Widget _carpetCards(BuildContext context) {
    CollectionReference<Map<String, dynamic>> carpets = FirebaseFirestore.instance.collection('carpets');

    return FutureBuilder<QuerySnapshot>(
      future: carpets.where("customer_id", isEqualTo: widget.customerID).get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text("Bir şeyler yanlış gitti.");
        }
        if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
          int size = snapshot.data!.docs.length;

          return ListView.builder(
            itemCount: size,
            itemBuilder: (context, index) {
              String cost = snapshot.data!.docs[index]['cost'];
              String area = snapshot.data!.docs[index]['area'];
              String status = snapshot.data!.docs[index]['status'];
              String type = snapshot.data!.docs[index]['type'];
              String carpetID = snapshot.data!.docs[index].id;
              return _singleCard(context, index, Carpet(cost, area, status, type, carpetID));
            },
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _singleCard(BuildContext context, int index, Carpet carpet) {
    ScreenshotController screenshotController = ScreenshotController();

    return InkWell(
      child: Card(
        color: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: Row(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        height: 1.5,
                      ),
                      children: <TextSpan>[
                        TextSpan(text: " Halı Fiyatı\n", style: TextStyle(color: Colors.white)),
                        TextSpan(text: " Halı Ölçüsü\n", style: TextStyle(color: Colors.white)),
                        TextSpan(text: " Halı Tipi\n", style: TextStyle(color: Colors.white)),
                        TextSpan(text: " Halı Durumu", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                )
              ],
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        height: 1.5,
                      ),
                      children: <TextSpan>[
                        TextSpan(text: ": ${carpet.cost} ₺\n", style: const TextStyle(color: Colors.white)),
                        TextSpan(text: ": ${carpet.area} m²\n", style: const TextStyle(color: Colors.white)),
                        TextSpan(text: ": ${carpet.type}\n", style: const TextStyle(color: Colors.white)),
                        TextSpan(text: ": ${carpet.status}", style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                )
              ],
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
            const Spacer(),
            SizedBox(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: ElevatedButton(
                  child: Screenshot(
                    controller: screenshotController,
                    child: QrImage(
                      data: carpet.carpetID,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    _takeScreenshot(screenshotController);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.black),
                  ),
                ),
              ),
              width: 140,
              height: 140,
            ),
          ],
        ),
      ),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => QrEdit(qrID: carpet.carpetID))).then((_) {
          setState(() {});
        });
      },
    );
  }

  void _takeScreenshot(ScreenshotController screenshotController) async {
    final uint8List = await screenshotController.capture();
    String tempPath = (await getTemporaryDirectory()).path;
    File file = File('$tempPath/image.png');
    await file.writeAsBytes(uint8List!);
    await Share.shareFiles([file.path]);
  }
}

class Carpet {
  late String cost;
  late String area;
  late String status;
  late String type;
  late String carpetID;

  Carpet(newCost, newArea, newStatus, newType, newCarpetID) {
    cost = newCost;
    area = newArea;
    status = newStatus;
    type = newType;
    carpetID = newCarpetID;
  }
}
