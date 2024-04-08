import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MaterialApp(home: MyHome()));

class MyHome extends StatelessWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Demo Home Page')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const QRViewExample(),
            ));
          },
          child: const Text('qrView'),
        ),
      ),
    );
  }
}

class QRViewExample extends StatefulWidget {
  const QRViewExample({super.key});

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: _buildQrView(context),
          ),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (result != null)
                    Text(
                        'Barcode Type: ${describeEnum(result!.format)} Data: ${result!.code}')
                  else
                    const Text('Scan a code'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                            onPressed: () async {
                              await controller?.toggleFlash();
                              setState(() {
                                // Navigator.of(context).push(MaterialPageRoute(
                                //   builder: (context) {
                                //     return const ResponsceOfQrCodeApi();
                                //   },
                                // ));
                              });
                            },
                            child: FutureBuilder(
                              future: controller?.getFlashStatus(),
                              builder: (context, snapshot) {
                                return Text('Flash: ${snapshot.data}');
                              },
                            )),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                            onPressed: () async {
                              await controller?.flipCamera();
                              setState(() {});
                            },
                            child: FutureBuilder(
                              future: controller?.getCameraInfo(),
                              builder: (context, snapshot) {
                                if (snapshot.data != null) {
                                  return Text(
                                      'Camera facing ${describeEnum(snapshot.data!)}');
                                } else {
                                  return const Text('loading');
                                }
                              },
                            )),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            await controller?.pauseCamera();
                          },
                          child: const Text('pause',
                              style: TextStyle(fontSize: 20)),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            await controller?.resumeCamera();
                          },
                          child: const Text('resume',
                              style: TextStyle(fontSize: 20)),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: const Color.fromARGB(255, 40, 94, 242),
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),

    );
  }

  void _onQRViewCreated(QRViewController controller) async {
  setState(() {
    this.controller = controller;
  });
  bool isFunctionCalled = false;
  
  controller.scannedDataStream.listen((scanData) async {
    setState(() {
      result = scanData;
    });
    if (result != null && !isFunctionCalled) {
      isFunctionCalled = true;

      // Call the fetchQrData function to fetch data from the API
      await fetchQrData();

      // After fetching data from the API, navigate to the next page
    var nextPage= Navigator.of(context).push(MaterialPageRoute(
        builder: (context) {
          return const ResponsceOfQrCodeApi();
        },
        
      ));
       if (nextPage == null) {
        isFunctionCalled = false;
        
      }
      // Cancel the subscription to stop further scans
      // scanSubscription.cancel();
    }
  });
}



  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

//++++++++++++++++++++================================= fetch data from api++++++++++++++++++++++=========+++++===============

class ResponsceOfQrCodeApi extends StatefulWidget {
  const ResponsceOfQrCodeApi({super.key});

  @override
  State<ResponsceOfQrCodeApi> createState() => _ResponsceOfQrCodeState();
}

class _ResponsceOfQrCodeState extends State<ResponsceOfQrCodeApi> {
  @override
  void initState() {
    super.initState();
    // fetchQrData();
  }

  // Future<void> fetchQrData() async {
  //   String apiUrl = "https://staging.simmpli.com/api/v1/companies/1/get_all_profile_event_data";
  //   Map<String, String> headers = {
  //     'Authorization':
  //         'Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyIjoyLCJ0aW1lIjoxNzEyNTcwMjg3fQ.4EYb8m4eLTgxDSbkd_wkR3kh-6UHfL6j8VZjc2khBn0 ',
  //   };

  //   try {
  //     final res = await http.get(
  //       Uri.parse(apiUrl),
  //       headers: headers,
  //     );
  //     print("responsce of API ${res}");
  //     print("responsce of API ${res.body}");
  //   } catch (e) {
  //     debugPrint(
  //       "Error on Fetching Qrdata",
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Text("Data of User"),
      ),
    );
  }
}

Future<void> fetchQrData() async {
  String apiUrl =
      "https://staging.simmpli.com/api/v1/companies/1/get_all_profile_event_data";
  Map<String, String> headers = {
    'Authorization':
        'Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyIjoyLCJ0aW1lIjoxNzEyNTcwMjg3fQ.4EYb8m4eLTgxDSbkd_wkR3kh-6UHfL6j8VZjc2khBn0 ',
  };

  try {
    final res = await http.get(
      Uri.parse(apiUrl),
      headers: headers,
    );
    print("responsce of API ${res}");
    print("responsce of API ${res.body}");
  
  } catch (e) {
    debugPrint(
      "Error on Fetching Qrdata",
    );
  }
}
