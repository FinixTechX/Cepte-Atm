import 'dart:convert';
import 'dart:io';
import 'package:CepteATM/Utils/Style.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../../Utils/AppSnackBar.dart';
import '../../Utils/SizeConfig.dart';
import '../../generated/l10n.dart';
import '../../injections.dart';
import 'package:dio/dio.dart';

class PayNowPage extends StatefulWidget {
  const PayNowPage({Key? key}) : super(key: key);

  @override
  _PayNowPageState createState() => _PayNowPageState();
}

bool didInitiLinks = false;

class _PayNowPageState extends State<PayNowPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

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
      appBar: AppBar(
        backgroundColor: Color(0xffEBEEFD),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      backgroundColor: Color(0xffEBEEFD),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(16)),
                  child: Text(
                    S.of(context).warningTherefore,
                    style: TextStyle(
                        fontFamily: "Almaria",
                        color: Color.fromARGB(255, 189, 139, 0)),
                  ),
                ),
                Container(
                  height: SizeConfig.h(550),
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(
                      horizontal: SizeConfig.w(12), vertical: SizeConfig.h(23)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.black,
                  ),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: _buildQrView(context)),
                ),
              ],
            ),
            Positioned(
              top: SizeConfig.h(180),
              left: SizeConfig.screenWidth * 0.75,
              child: FutureBuilder<bool?>(
                future: controller?.getFlashStatus(),
                builder: (context, snapshot) {
                  return IconButton(
                      onPressed: () async {
                        await controller
                            ?.toggleFlash()
                            .catchError((onError) {});
                        setState(() {});
                      },
                      icon: Icon(
                        (snapshot.data ?? false)
                            ? Icons.flashlight_on
                            : Icons.flashlight_off,
                        color: AppStyle.whiteColor,
                        size: SizeConfig.h(24),
                      ));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: AppStyle.whiteColor,
          borderRadius: 15,
          borderLength: 40,
          borderWidth: 7,
          cutOutSize: SizeConfig.h(250)),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  bool locked = false;
  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    if (!locked) {
      controller.scannedDataStream.listen((scanData) {
        locked = true;
        controller.pauseCamera();
        if (scanData.code != null) {
          try {
            final json = jsonDecode(scanData.code!);

            finish(json, context);
          } catch (e) {
            AppSnackBar.show(context, S.of(context).Qr_code, ToastType.Error);
            locked = false;
            controller.stopCamera();
            controller.resumeCamera();
          }
        }
      });
    }
    controller.pauseCamera();
    controller.resumeCamera();
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      print("no permission");
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> showDialogLoding() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return Container(
            height: SizeConfig.h(650),
            width: 50,
            child: Center(
                child:
                    CircularProgressIndicator(color: AppStyle.primaryColor)));
      },
    );
  }

  finish(
    id,
    context,
  ) async {
    try {
      showDialogLoding();
      await sl<Dio>().post(
        "api/money_requests/$id/finish",
      );

      Navigator.pop(context, "true");
      Navigator.pop(context, "true");

      AppSnackBar.show(context, S.of(context).Successfully, ToastType.Success);
    } on DioError catch (e) {
      Navigator.pop(
        context,
      );
      controller!.stopCamera();
      controller!.resumeCamera();
      AppSnackBar.show(context, S.of(context).Qr_code, ToastType.Error);
    } catch (e) {
      Navigator.pop(
        context,
      );
      controller!.stopCamera();
      controller!.resumeCamera();

      AppSnackBar.show(context, S.of(context).Qr_code, ToastType.Error);
    }
  }
}
