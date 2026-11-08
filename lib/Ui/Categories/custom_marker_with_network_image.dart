import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:progiom_cms/homeSettings.dart';
import '../../App/Widgets/MainButton.dart';
import '../../Utils/AppSnackBar.dart';
import '../../Utils/SizeConfig.dart';
import '../../Utils/Style.dart';
import '../../constants.dart';
import '../../generated/l10n.dart';
import '../../injections.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart' as intl;

class CustomMarkerWithNetworkImage extends StatefulWidget {
  List<dynamic> address = [];

  CustomMarkerWithNetworkImage({Key? key, required this.address})
      : super(key: key);

  @override
  _CustomMarkerWithNetworkImageState createState() =>
      _CustomMarkerWithNetworkImageState();
}

class _CustomMarkerWithNetworkImageState
    extends State<CustomMarkerWithNetworkImage> {
  final Completer<GoogleMapController> _controller = Completer();

  final List<Marker> _markers = <Marker>[];

  Future<Uint8List> getBytesFromAssets(
    String path,
  ) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: 160);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  _getGeoLocation() async {
    Position position = await _getGeoLocationPosition();
    setState(() {
      positionMarker = LatLng(position.latitude, position.longitude);
      kGooglePlex = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 50,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();
    _getGeoLocation();
  }

  Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  loadData() async {
    for (int i = 0; i < widget.address.length; i++) {
      Uint8List? image = await getBytesFromAssets("assets/pngwing.com.png");

      final ui.Codec markerImageCodec = await instantiateImageCodec(
        image.buffer.asUint8List(),
        targetHeight: 150,
        targetWidth: 100,
      );
      final FrameInfo frameInfo = await markerImageCodec.getNextFrame();
      final ByteData? byteData = await frameInfo.image.toByteData(
        format: ImageByteFormat.png,
      );

      final Uint8List resizedMarkerImageBytes = byteData!.buffer.asUint8List();
      _markers.add(Marker(
        markerId: MarkerId(i.toString()),
        position: LatLng(double.parse(widget.address[i]["lat"]),
            double.parse(widget.address[i]["long"])),
        icon: BitmapDescriptor.fromBytes(resizedMarkerImageBytes),
        anchor: Offset(.1, .1),
        infoWindow: InfoWindow(
            title: widget.address[i]["user"]["name"],
            snippet: "[${S.of(context).ClickOrder}]",
            onTap: () {
              _showMyDialog(widget.address[i]);
            }),
      ));
      setState(() {});
    }
  }

  Future<Uint8List?> _loadNetworkImage(String path) async {
    final completer = Completer<ImageInfo>();
    var img = NetworkImage(
      path,
    );
    img
        .resolve(const ImageConfiguration(size: Size.fromHeight(10)))
        .addListener(
            ImageStreamListener((info, _) => completer.complete(info)));
    final imageInfo = await completer.future;
    final byteData = await imageInfo.image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return byteData?.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: kGooglePlex,
      mapType: MapType.normal,
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
      compassEnabled: true,
      tiltGesturesEnabled: false,
      markers: Set<Marker>.of(_markers),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
        controller.setMapStyle(
            '[{"featureType": "poi","stylers": [{"visibility": "off"}]}]');
      },
      onCameraMove: (CameraPosition position) {
        setState(() {
          positionMarker = position.target;
          sizeMarker = 70;
        });
      },
      onCameraIdle: () async {
        print(positionMarker);
        setState(() {
          sizeMarker = 70;
        });
      },
    );
  }

  Future<void> _showMyDialog(data) async {
    final TextEditingController amountRequiredController =
        TextEditingController();
    final TextEditingController dateOfOrderController = TextEditingController();
    final TextEditingController requestTimeController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    formatDate(DateTime date) =>
        intl.DateFormat("yyyy-MM-dd", "en").format(date);
    dateOfOrderController.text = formatDate(DateTime.now());
    var timeOfDay = TimeOfDay.now();
    requestTimeController.text =
        TimeOfDay(hour: timeOfDay.hour + 1, minute: timeOfDay.minute)
            .toString()
            .substring(10, 15);
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: ListBody(
                children: <Widget>[
                  Text(
                    S.of(context).order_details,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: SizeConfig.h(15),
                  ),
                  buildTextField(
                    S.of(context).amountRequired,
                    amountRequiredController,
                    validator: (v) {
                      var balance = sl<HomesettingsBloc>()
                              .settings!
                              .user!
                              .balance
                              ?.split("T")[0]
                              .replaceAll(",", "") ??
                          "0";
                      int max_allowed_balance_to_transfer =
                          sl<HomesettingsBloc>()
                                  .settings
                                  ?.max_allowed_balance_to_transfer ??
                              0;
                      if (v != null && v.isEmpty)
                        return S.of(context).Validator +
                            ' ' +
                            S.of(context).amountRequired;
                      if (int.parse(v ?? '0') > max_allowed_balance_to_transfer)
                        return S.of(context).Exceededlimit;
                      if (int.parse(v ?? '0') > int.parse(balance))
                        return S.of(context).You_don_have_enough_credit;
                      return null;
                    },
                    typeNum: true,
                  ),
                  SizedBox(
                    height: SizeConfig.h(15),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: buildTextField(
                            S.of(context).order_date, dateOfOrderController,
                            validator: (v) {
                          if (v != null && v.isEmpty)
                            return S.of(context).Validator +
                                ' ' +
                                S.of(context).order_date;
                          return null;
                        }, typeNum: true, isDate: true),
                      ),
                      SizedBox(
                        width: SizeConfig.w(12),
                      ),
                      Expanded(
                        child: buildTextField(
                          S.of(context).RequestTime,
                          requestTimeController,
                          validator: (v) {
                            if (v != null && v.isEmpty)
                              return S.of(context).Validator +
                                  ' ' +
                                  S.of(context).RequestTime;
                            return null;
                          },
                          typeNum: true,
                          isTime: true,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: SizeConfig.h(30),
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: GestureDetector(
                              onTap: () async {
                                var balance = sl<HomesettingsBloc>()
                                        .settings!
                                        .user!
                                        .balance
                                        ?.split("T")[0]
                                        .replaceAll(",", "") ??
                                    "0";
                                if (int.parse(balance) > 0) {
                                  if (formKey.currentState?.validate() ??
                                      false) {
                                    createMoneyRequests(
                                        data['user_id'],
                                        amountRequiredController.text,
                                        data["long"],
                                        data['lat'],
                                        dateOfOrderController.text,
                                        requestTimeController.text,
                                        "",
                                        context);
                                  }
                                } else {
                                  AppSnackBar.show(
                                      context,
                                      S.of(context).You_don_have_enough_credit,
                                      ToastType.Info);
                                }
                              },
                              child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(SizeConfig.h(5)),
                                    color: AppStyle.primaryColor,
                                  ),
                                  height: SizeConfig.h(50),
                                  width: SizeConfig.screenWidth,
                                  child: Container(
                                    child: Center(
                                      child: Text(
                                        S.of(context).sendRequest,
                                        style: AppStyle.vexa14.copyWith(
                                            color: AppStyle.whiteColor),
                                      ),
                                    ),
                                  )))),
                      SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        child: MainButton(
                          onTap: () => Navigator.pop(context),
                          height: SizeConfig.h(50),
                          color: AppStyle.redColor,
                          borderRadius: BorderRadius.circular(SizeConfig.h(5)),
                          isOutlined: true,
                          child: Center(
                              child: Text(
                            S.of(context).cancel,
                            style: AppStyle.vexa16
                                .copyWith(color: AppStyle.redColor),
                          )),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
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

  createMoneyRequests(
      from_user_id, amount, long, lat, date, time, addres, context) async {
    try {
      showDialogLoding();
      await sl<Dio>().post("api/money_requests", data: {
        "from_user_id": from_user_id,
        "amount": amount,
        "long": long,
        "lat": lat,
        "date": date,
        "address_details": "",
        "time": time
      });
      homePageStateKey.currentState!.refresh();

      Navigator.pushNamedAndRemoveUntil(
          context, '/base', (Route<dynamic> route) => false);
      AppSnackBar.show(context, S.of(context).Successfully, ToastType.Success);
    } on DioError catch (e) {
      Navigator.pop(
        context,
      );

      var error =
          (e.response?.data['errors'] as Map).values.first?.first.toString();
      AppSnackBar.show(context, error!, ToastType.Error);
    } catch (e) {
      Navigator.pop(
        context,
      );

      AppSnackBar.show(context, e.toString(), ToastType.Error);
    }
  }

  Widget buildTextField(
    String label,
    TextEditingController controller, {
    String? Function(String?)? validator,
    bool? obscureText,
    bool typeNum = false,
    bool isDate = false,
    bool isTime = false,
  }) {
    return SizedBox(
      child: TextFormField(
        validator: validator,
        controller: controller,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        readOnly: isDate ? true : isTime,
        onTap: () async {
          if (isDate) {
            formatDate(DateTime date) =>
                intl.DateFormat("yyyy-MM-dd", "en").format(date);
            var result = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2900));

            if (result != null) {
              controller.text = formatDate(result);
            }
          }
          if (isTime) {
            var result = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
              builder: (BuildContext context, Widget? child) {
                return MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(alwaysUse24HourFormat: true),
                  child: child!,
                );
              },
            );

            if (result != null) {
              controller.text = result.toString().substring(10, 15);
            }
          }
        },
        keyboardType: typeNum ? TextInputType.datetime : TextInputType.name,
        obscureText: obscureText ?? false,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              vertical: SizeConfig.h(2),
              horizontal: SizeConfig.w(12),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                  width: 1,
                  style: BorderStyle.solid,
                  color: AppStyle.greyColor),
              borderRadius: const BorderRadius.all(
                const Radius.circular(5),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  width: 1,
                  style: BorderStyle.solid,
                  color: AppStyle.greyColor),
              borderRadius: const BorderRadius.all(
                const Radius.circular(5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  width: 1,
                  style: BorderStyle.solid,
                  color: AppStyle.greyColor),
              borderRadius: const BorderRadius.all(
                const Radius.circular(5),
              ),
            ),
            labelText: label,
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            labelStyle: TextStyle(
              fontSize: SizeConfig.h(14),
            ),
            errorStyle: TextStyle(fontSize: SizeConfig.h(14)),
            filled: true,
            fillColor: Colors.white),
      ),
    );
  }
}
