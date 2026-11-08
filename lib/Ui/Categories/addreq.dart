import 'dart:math';

import 'package:CepteATM/App/Widgets/MainButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:progiom_cms/homeSettings.dart';
import '../../Utils/AppSnackBar.dart';
import '../../constants.dart';
import '/Utils/SizeConfig.dart';
import '/Utils/Style.dart';
import '/generated/l10n.dart';
import '../../injections.dart';
import 'custom_marker_with_network_image.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart' as intl;

class AddReq extends StatefulWidget {
  AddReq({Key? key}) : super(key: key);

  @override
  _AddReqState createState() => _AddReqState();
}

class _AddReqState extends State<AddReq> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    getAddress(positionMarker?.longitude.toString() ?? "",
        positionMarker?.latitude.toString() ?? "");
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController!.dispose();
  }

  int indexTab = 0;
  List<dynamic> address = [];
  bool isLoading = false;
  bool isLoadingCreate = false;

  getAddress(String long, String lat) async {
    address = [];
    setState(() {
      isLoading = true;
    });
    try {
      var request = await sl<Dio>().get("api/addresses?long=$long&lat=$lat");
      address = request.data["data"];
      setState(() {
        isLoading = false;
      });
    } on DioError catch (e) {
      var error =
          (e.response?.data['errors'] as Map).values.first?.first.toString();
      AppSnackBar.show(context, error!, ToastType.Error);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      AppSnackBar.show(context, e.toString(), ToastType.Error);
      setState(() {
        isLoading = false;
      });
    }
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  @override
  Widget build(BuildContext context) {
    if (isBuildAdd) {
      isBuildAdd = false;
      getAddress(positionMarker?.longitude.toString() ?? "",
          positionMarker?.latitude.toString() ?? "");
    }
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: SizeConfig.h(24),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.h(16), vertical: 4),
              child: Container(
                height: SizeConfig.h(55),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    5.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0.0, 3.0),
                      blurRadius: 6,
                      color: Colors.black12,
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                  ),
                  onTap: (i) async {
                    setState(() {
                      indexTab = i;
                    });
                  },
                  labelColor: AppStyle.primaryColor,
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    Tab(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 12,
                            child: Center(
                              child: Text(
                                S.of(context).map,
                              ),
                            ),
                          ),
                          if (indexTab == 0)
                            Expanded(
                              child: Container(
                                color: AppStyle.primaryColor,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Tab(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 12,
                            child: Center(
                              child: Text(
                                S.of(context).list,
                              ),
                            ),
                          ),
                          if (indexTab == 1)
                            Expanded(
                              child: Container(
                                color: AppStyle.primaryColor,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                  controller: _tabController,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    isLoading
                        ? Container(
                            width: 50,
                            child: Center(
                                child: CircularProgressIndicator(
                                    color: AppStyle.primaryColor)))
                        : CustomMarkerWithNetworkImage(address: address),
                    isLoading
                        ? Container(
                            width: 50,
                            child: Center(
                                child: CircularProgressIndicator(
                                    color: AppStyle.primaryColor)))
                        : address.isNotEmpty
                            ? Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: SizeConfig.h(16)),
                                child: RefreshIndicator(
                                  onRefresh: () async {
                                    getAddress(
                                        positionMarker?.longitude.toString() ??
                                            "",
                                        positionMarker?.latitude.toString() ??
                                            "");
                                    return Future.delayed(Duration(seconds: 1))
                                        .then((value) {});
                                  },
                                  child: Container(
                                    height: SizeConfig.h(710),
                                    child: ListView.builder(
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        itemCount: address.length,
                                        padding: EdgeInsets.only(
                                            top: SizeConfig.h(5),
                                            bottom: SizeConfig.h(50)),
                                        itemBuilder: (context, index) {
                                          double calculate = calculateDistance(
                                              double.parse(
                                                  address[index]["lat"]),
                                              double.parse(
                                                  address[index]["long"]),
                                              positionMarker?.latitude ?? 0,
                                              positionMarker?.longitude ?? 0);
                                          return Flex(
                                            direction: Axis.vertical,
                                            children: [
                                              SizedBox(
                                                height: 4,
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  _showMyDialog(address[index]);
                                                },
                                                child: Container(
                                                  height: SizeConfig.h(80),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      CircleAvatar(
                                                        backgroundColor:
                                                            AppStyle
                                                                .primaryColor,
                                                        foregroundColor:
                                                            AppStyle
                                                                .primaryColor,
                                                        radius:
                                                            SizeConfig.w(20),
                                                        backgroundImage: (address[
                                                                            index]
                                                                        ["user"]
                                                                    [
                                                                    "cover_image"] !=
                                                                null)
                                                            ? NetworkImage(address[
                                                                        index]
                                                                    ["user"]
                                                                ["cover_image"])
                                                            : NetworkImage(
                                                                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRBgZbchuTiUtA3Egi1arN4BEQeoTaUtutQ8A&usqp=CAU"),
                                                      ),
                                                      SizedBox(
                                                        width: 16,
                                                      ),
                                                      Expanded(
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            RatingBar(
                                                              ignoreGestures:
                                                                  true,
                                                              initialRating: address[
                                                                              index]
                                                                          [
                                                                          "user"]
                                                                      [
                                                                      "user_rating"]
                                                                  .toDouble(),
                                                              direction: Axis
                                                                  .horizontal,
                                                              allowHalfRating:
                                                                  false,
                                                              itemCount: 5,
                                                              itemSize: 16,
                                                              ratingWidget:
                                                                  RatingWidget(
                                                                full: Icon(
                                                                  Icons.star,
                                                                  color: AppStyle
                                                                      .yellowColor,
                                                                ),
                                                                half: Icon(
                                                                    Icons.star),
                                                                empty: Icon(
                                                                  Icons
                                                                      .star_border_outlined,
                                                                  color: AppStyle
                                                                      .yellowColor
                                                                      .withOpacity(
                                                                          0.5),
                                                                ),
                                                              ),
                                                              onRatingUpdate:
                                                                  (rate) {
                                                                //rating = rate.toInt();
                                                              },
                                                            ),
                                                            SizedBox(
                                                              height: 6,
                                                            ),
                                                            Text(
                                                              address[index]
                                                                      ["user"]
                                                                  ["name"],
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            SizedBox(
                                                              height: 6,
                                                            ),
                                                            Text(
                                                              S
                                                                      .of(
                                                                          context)
                                                                      .Distance +
                                                                  " :  " +
                                                                  calculate
                                                                      .toStringAsFixed(
                                                                          2) +
                                                                  " KM",
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontFamily:
                                                                      "Almaria",
                                                                  color: AppStyle
                                                                      .primaryColor),
                                                            ),
                                                            SizedBox(
                                                              height: 6,
                                                            ),
                                                            Text(
                                                              S
                                                                      .of(
                                                                          context)
                                                                      .Available_balance +
                                                                  " :  " +
                                                                  address[index]
                                                                      [
                                                                      "amountText"],
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontFamily:
                                                                      "Almaria",
                                                                  color: AppStyle
                                                                      .primaryColor),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 8,
                                              ),
                                              Divider(
                                                height: 1,
                                                thickness: 0.5,
                                              ),
                                            ],
                                          );
                                        }),
                                  ),
                                ),
                              )
                            : Padding(
                                padding: EdgeInsets.all(SizeConfig.h(16)),
                                child: RefreshIndicator(
                                  onRefresh: () async {
                                    getAddress(
                                        positionMarker?.longitude.toString() ??
                                            "",
                                        positionMarker?.latitude.toString() ??
                                            "");
                                    return Future.delayed(Duration(seconds: 1))
                                        .then((value) {});
                                  },
                                  child: SingleChildScrollView(
                                    physics: AlwaysScrollableScrollPhysics(),
                                    child: Container(
                                      width: double.infinity,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            height: SizeConfig.h(140),
                                          ),
                                          Image.asset(
                                            "assets/noTr.png",
                                            height: SizeConfig.w(148),
                                            width: SizeConfig.w(148),
                                          ),
                                          SizedBox(
                                            height: 28,
                                          ),
                                          Text(
                                            S.of(context).serviceProviders,
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                  ]),
            ),
          ],
        ),
      ),
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
                      if (int.parse(v ?? '0') > data["amount"])
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
                                        '',
                                        context,
                                        data["id"]);
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
      from_user_id, amount, long, lat, date, time, addres, context, id) async {
    try {
      showDialogLoding();
      await sl<Dio>().post("api/money_requests", data: {
        "from_user_id": from_user_id,
        "amount": amount,
        "long": long,
        "lat": lat,
        "date": date,
        "address_details": addres,
        "time": time,
        "address_id": id,
      });
      homePageStateKey.currentState!.refresh();
      Navigator.pushNamedAndRemoveUntil(
          context, '/base', (Route<dynamic> route) => true);
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
