import 'package:CepteATM/constants.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';
import 'package:progiom_cms/core.dart';
import 'package:progiom_cms/homeSettings.dart';
import '../../App/App.dart';
import '../../App/Widgets/MainButton.dart';
import '../../Utils/AppSnackBar.dart';
import '../../data/sharedPreferences/SharedPrefHelper.dart';
import '../Home/pay_now_page.dart';
import '/Utils/SizeConfig.dart';
import '/Utils/Style.dart';
import '/generated/l10n.dart';
import 'package:dio/dio.dart';
import '../../injections.dart';

class CategoriesPage extends StatefulWidget {
  CategoriesPage() : super();

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

Map<String, dynamic> getReportType = {};
List<String> getReportTypeString = [];
Map<String, dynamic> reportRequest = {};
String dropdownValueReport = '';
String selectedLanguage = "ar";

class _CategoriesPageState extends State<CategoriesPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  int indexTab = 0;
  List<dynamic> moneyRequests = [];
  bool isLoading = false;
  bool isLoadingMoneyRequests = false;
  bool isLoadingMoneyRequestsincomes = false;
  bool isLoadingMoneyRequestsoutcomes = false;
  bool isViewPagination = true;

  int? page;
  var scrollcontroller = ScrollController();
  getLanguage() async {
    selectedLanguage =
        await sl<PrefsHelper>().loadLangFromSharedPref() ?? App.defaultLanguage;
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getMoneyRequests();
    getLanguage();

    page = 1;

    scrollcontroller.addListener(pagination);

    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = sl<HomesettingsBloc>().settings!;
    if (isBuildHis) {
      isBuildHis = false;

      isViewPagination = true;
      page = 1;

      if (indexTab == 0) {
        getMoneyRequests();
      } else if (indexTab == 2) {
        getMoneyRequestsincomes();
      } else {
        getMoneyRequestsoutcomes();
      }
    }
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              isViewPagination = true;
              page = 1;
            });
            if (indexTab == 0) {
              await getMoneyRequests();
            } else if (indexTab == 2) {
              await getMoneyRequestsincomes();
            } else {
              await getMoneyRequestsoutcomes();
            }
            return Future.delayed(Duration(seconds: 1)).then((value) {});
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: SizeConfig.h(710),
              child: Padding(
                padding: EdgeInsets.all(SizeConfig.h(16)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).Operationslog,
                      style: AppStyle.welcome20.copyWith(
                          fontFamily: "Almaria",
                          fontWeight: FontWeight.bold,
                          fontSize: SizeConfig.h(20),
                          color: Colors.black),
                    ),
                    SizedBox(
                      height: SizeConfig.h(24),
                    ),
                    Container(
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
                            isViewPagination = true;
                            page = 1;
                          });
                          if (i == 0) {
                            await getMoneyRequests();
                          } else if (i == 2) {
                            await getMoneyRequestsincomes();
                          } else {
                            await getMoneyRequestsoutcomes();
                          }
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
                                      S.of(context).All_operations,
                                      style:
                                          TextStyle(fontSize: SizeConfig.w(12)),
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
                                      S.of(context).outgoing,
                                      style:
                                          TextStyle(fontSize: SizeConfig.w(12)),
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
                          Tab(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 12,
                                  child: Center(
                                    child: Text(
                                      S.of(context).incoming,
                                      style:
                                          TextStyle(fontSize: SizeConfig.w(12)),
                                    ),
                                  ),
                                ),
                                if (indexTab == 2)
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
                    isLoading
                        ? Expanded(
                            child: Container(
                                child: Center(
                                    child: CircularProgressIndicator(
                                        color: AppStyle.primaryColor))),
                          )
                        : Expanded(
                            child: TabBarView(
                                controller: _tabController,
                                physics: NeverScrollableScrollPhysics(),
                                children: [
                                  listTran(moneyRequests),
                                  listTran(moneyRequests),
                                  listTran(moneyRequests)
                                ]),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  listTran(List<dynamic> data) {
    return data.isNotEmpty
        ? Container(
            height: SizeConfig.h(380),
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  isViewPagination = true;
                  page = 1;
                });
                if (indexTab == 0) {
                  await getMoneyRequests();
                } else if (indexTab == 2) {
                  await getMoneyRequestsincomes();
                } else {
                  await getMoneyRequestsoutcomes();
                }
                return Future.delayed(Duration(seconds: 1)).then((value) {});
              },
              child: ListView.builder(
                  controller: scrollcontroller,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: data.length + 1,
                  padding: EdgeInsets.only(
                      top: SizeConfig.h(5), bottom: SizeConfig.h(50)),
                  itemBuilder: (context, index) {
                    return index == data.length
                        ? indexTab == 0
                            ? isLoadingMoneyRequests
                                ? Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: Center(
                                      child: new CircularProgressIndicator(
                                        color: AppStyle.primaryColor,
                                      ),
                                    ),
                                  )
                                : indexTab == 1
                                    ? isLoadingMoneyRequestsoutcomes
                                        ? Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 80),
                                            child: Center(
                                              child:
                                                  new CircularProgressIndicator(
                                                color: AppStyle.primaryColor,
                                              ),
                                            ),
                                          )
                                        : indexTab == 2
                                            ? isLoadingMoneyRequestsincomes
                                                ? Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 80),
                                                    child: Center(
                                                      child:
                                                          new CircularProgressIndicator(
                                                        color: AppStyle
                                                            .primaryColor,
                                                      ),
                                                    ),
                                                  )
                                                : Container()
                                            : Container()
                                    : Container()
                            : Container()
                        : Padding(
                            padding: EdgeInsets.only(
                              top: SizeConfig.h(8),
                            ),
                            child: InkWell(
                              onTap: () {
                                if (data[index]["status"] == "pending") {
                                  sl<HomesettingsBloc>().settings!.user!.id !=
                                          data[index]["user_id"]
                                      ? showDialogWating(data[index])
                                      : showMyDialog(data[index]);
                                } else if (data[index]["status"] ==
                                    "cancelled") {
                                } else if (data[index]["status"] == "refused") {
                                } else {
                                  showMyDialog(data[index]);
                                }
                              },
                              child: Flex(direction: Axis.vertical, children: [
                                Container(
                                  height: 60,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      sl<HomesettingsBloc>()
                                                  .settings!
                                                  .user!
                                                  .id ==
                                              data[index]["user_id"]
                                          ? Image.asset(
                                              "assets/arrow2.png",
                                              height: SizeConfig.w(30),
                                              width: SizeConfig.w(30),
                                            )
                                          : Image.asset(
                                              "assets/arrow.png",
                                              height: SizeConfig.w(30),
                                              width: SizeConfig.w(30),
                                            ),
                                      SizedBox(
                                        width: 12,
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              sl<HomesettingsBloc>()
                                                          .settings!
                                                          .user!
                                                          .id !=
                                                      data[index]["user_id"]
                                                  ? data[index]["user"]["name"]
                                                  : data[index]["from_user"]
                                                      ["name"],
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              (data[index]["time"].substring(
                                                          0,
                                                          data[index]["time"]
                                                                  .length -
                                                              3) ??
                                                      "") +
                                                  " " +
                                                  (data[index]["date"] ?? ""),
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: AppStyle.greyColor),
                                            )
                                          ],
                                        ),
                                      ),
                                      data[index]["status"] == "pending"
                                          ? Text(
                                              S.of(context).waitings,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.red,
                                              ),
                                            )
                                          : data[index]["status"] == "cancelled"
                                              ? Text(
                                                  S.of(context).canceled,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.red,
                                                  ),
                                                )
                                              : data[index]["status"] ==
                                                      "refused"
                                                  ? Text(
                                                      S.of(context).reject,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.red,
                                                      ),
                                                    )
                                                  : data[index]["status"] ==
                                                          "in_progress"
                                                      ? sl<HomesettingsBloc>()
                                                                  .settings!
                                                                  .user!
                                                                  .id !=
                                                              data[index]
                                                                  ["user_id"]
                                                          ? Row(
                                                              children: [
                                                                InkWell(
                                                                  onTap: () {
                                                                    sl<HomesettingsBloc>().settings!.user!.id ==
                                                                            data[index][
                                                                                "user_id"]
                                                                        ? sendMessageToWhatsapp(
                                                                            '${data[index]["from_user"]["full_mobile"]}',
                                                                            "مرحبا انا ${sl<HomesettingsBloc>().settings?.user?.name ?? ""} ")
                                                                        : sendMessageToWhatsapp(
                                                                            '${data[index]["user"]["full_mobile"]}',
                                                                            "مرحبا انا ${sl<HomesettingsBloc>().settings?.user?.name ?? ""} ");
                                                                  },
                                                                  child: Image
                                                                      .asset(
                                                                    'assets/wathsapp.png',
                                                                    width: 25,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 24,
                                                                ),
                                                                InkWell(
                                                                  onTap:
                                                                      () async {
                                                                    var payNow =
                                                                        await Navigator.of(context)
                                                                            .push(
                                                                      MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              PayNowPage()),
                                                                    );

                                                                    if (payNow ==
                                                                        "true") {
                                                                      if (index ==
                                                                          0) {
                                                                        await getMoneyRequests();
                                                                      } else if (index ==
                                                                          2) {
                                                                        await getMoneyRequestsincomes();
                                                                      } else {
                                                                        await getMoneyRequestsoutcomes();
                                                                      }
                                                                    }
                                                                  },
                                                                  child: Icon(
                                                                    Icons
                                                                        .camera_alt,
                                                                    color: AppStyle
                                                                        .primaryColor,
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          : sl<HomesettingsBloc>()
                                                                      .settings!
                                                                      .user!
                                                                      .id ==
                                                                  data[index][
                                                                      "user_id"]
                                                              ? Row(
                                                                  children: [
                                                                    InkWell(
                                                                      onTap:
                                                                          () {
                                                                        sl<HomesettingsBloc>().settings!.user!.id == data[index]["user_id"]
                                                                            ? sendMessageToWhatsapp('${data[index]["from_user"]["full_mobile"]}',
                                                                                "مرحبا انا ${sl<HomesettingsBloc>().settings?.user?.name ?? ""} ")
                                                                            : sendMessageToWhatsapp('${data[index]["user"]["full_mobile"]}',
                                                                                "مرحبا انا ${sl<HomesettingsBloc>().settings?.user?.name ?? ""} ");
                                                                      },
                                                                      child: Image
                                                                          .asset(
                                                                        'assets/wathsapp.png',
                                                                        width:
                                                                            25,
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width: 24,
                                                                    ),
                                                                    InkWell(
                                                                      onTap:
                                                                          () {
                                                                        showDialogQr(
                                                                            data[index]);
                                                                      },
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .qr_code,
                                                                        color: AppStyle
                                                                            .primaryColor,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )
                                                              : Text(
                                                                  '${data[index]["amount"]} TL',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                )
                                                      : Text(
                                                          '${data[index]["amount"]} TL',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.black,
                                                          ),
                                                        )
                                    ],
                                  ),
                                ),
                                Divider(
                                  height: 1,
                                  thickness: 0.5,
                                ),
                              ]),
                            ),
                          );
                  }),
            ),
          )
        : Container(
            width: double.infinity,
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  isViewPagination = true;
                  page = 1;
                });
                if (indexTab == 0) {
                  await getMoneyRequests();
                } else if (indexTab == 2) {
                  await getMoneyRequestsincomes();
                } else {
                  await getMoneyRequestsoutcomes();
                }
                return Future.delayed(Duration(seconds: 1)).then((value) {});
              },
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                      S.of(context).donot_have_any_transactions,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      S.of(context).nearest_service,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: AppStyle.greyColor),
                    )
                  ],
                ),
              ),
            ));
  }

  Future<void> showDialogQr(data) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Center(
                  child: Text(
                    S.of(context).order_details,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: SizeConfig.h(15),
                ),
                Center(
                  child: SizedBox(
                    height: SizeConfig.w(126),
                    width: SizeConfig.w(126),
                    child: QrImage(
                      data: data["id"].toString(),
                      version: QrVersions.auto,
                      size: SizeConfig.w(126),
                    ),
                  ),
                ),
                SizedBox(
                  height: SizeConfig.h(15),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.w(16),
                  ),
                  child: Text(
                    S.of(context).warningTherefore,
                    style: TextStyle(
                      fontFamily: "Almaria",
                      color: Color.fromARGB(255, 189, 139, 0),
                      fontSize: SizeConfig.w(12),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: SizeConfig.h(24),
                  ),
                  child: Container(
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            height: SizeConfig.h(40),
                            width: SizeConfig.w(40),
                            child: CircleAvatar(
                              backgroundColor: AppStyle.primaryColor,
                              foregroundColor: AppStyle.primaryColor,
                              radius: SizeConfig.h(40),
                              backgroundImage: (NetworkImage(
                                  data["from_user"]["cover_image"])),
                            )),
                        SizedBox(
                          width: 16,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                S.of(context).sendername,
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                data["from_user"]["name"] ?? "",
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 0.5,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: SizeConfig.h(12),
                  ),
                  child: Container(
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: SizeConfig.h(40),
                          width: SizeConfig.w(40),
                          child: CircleAvatar(
                            backgroundColor: AppStyle.primaryColor,
                            foregroundColor: AppStyle.primaryColor,
                            radius: SizeConfig.h(40),
                            backgroundImage: (sl<HomesettingsBloc>()
                                        .settings
                                        ?.user
                                        ?.coverImage !=
                                    null)
                                ? NetworkImage(
                                    (sl<HomesettingsBloc>()
                                            .settings
                                            ?.user
                                            ?.coverImage) ??
                                        "https://e7.pngegg.com/pngimages/146/551/png-clipart-user-login-mobile-phones-password-user-miscellaneous-blue-thumbnail.png",
                                  )
                                : NetworkImage(
                                    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRBgZbchuTiUtA3Egi1arN4BEQeoTaUtutQ8A&usqp=CAU"),
                          ),
                        ),
                        SizedBox(
                          width: 16,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                S.of(context).FutureName,
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                sl<HomesettingsBloc>().settings?.user?.name ??
                                    "",
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 0.5,
                ),
                SizedBox(
                  height: SizeConfig.h(30),
                ),
                Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(SizeConfig.h(5)),
                      color: Color(0xffEBEEFD),
                    ),
                    height: SizeConfig.h(50),
                    width: SizeConfig.screenWidth,
                    child: Container(
                      child: Center(
                        child: Text(
                          S.of(context).amountRequired +
                              "       ${data["amount"]} TL",
                          style: AppStyle.vexa14
                              .copyWith(color: AppStyle.primaryColor),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> showMyDialog(data) async {
    final TextEditingController amountRequiredController =
        TextEditingController();
    final TextEditingController dateOfOrderController = TextEditingController();
    final TextEditingController requestTimeController = TextEditingController();
    amountRequiredController.text = data["amount"].toString();
    dateOfOrderController.text = data["date"];
    requestTimeController.text =
        (data["time"].substring(0, data["time"].length - 3) ?? "");
    final TextEditingController order_number = TextEditingController();
    order_number.text = data["uuid"] ?? "";
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
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
                  S.of(context).order_number,
                  order_number,
                ),
                SizedBox(
                  height: SizeConfig.h(15),
                ),
                buildTextField(
                    S.of(context).amountRequired, amountRequiredController,
                    validator: (v) {
                  if (v != null && v.isEmpty)
                    return S.of(context).Validator +
                        ' ' +
                        S.of(context).amountRequired;
                  return null;
                }),
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
                      }),
                    ),
                    SizedBox(
                      width: SizeConfig.w(12),
                    ),
                    Expanded(
                      child: buildTextField(
                          S.of(context).RequestTime, requestTimeController,
                          validator: (v) {
                        if (v != null && v.isEmpty)
                          return S.of(context).Validator +
                              ' ' +
                              S.of(context).RequestTime;
                        return null;
                      }),
                    ),
                  ],
                ),
                SizedBox(
                  height: SizeConfig.h(30),
                ),
                if (data["status"] == "in_progress")
                  Row(
                    children: [
                      Expanded(
                          child: GestureDetector(
                              onTap: () async {
                                sl<HomesettingsBloc>().settings!.user!.id ==
                                        data["user_id"]
                                    ? sendMessageToWhatsapp(
                                        '${data["from_user"]["full_mobile"]}',
                                        "مرحبا انا ${sl<HomesettingsBloc>().settings?.user?.name ?? ""} ")
                                    : sendMessageToWhatsapp(
                                        '${data["user"]["full_mobile"]}',
                                        "مرحبا انا ${sl<HomesettingsBloc>().settings?.user?.name ?? ""} ");
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
                                        S.of(context).CommunicationWhatsApp,
                                        style: AppStyle.vexa14.copyWith(
                                            color: AppStyle.whiteColor,
                                            fontSize: SizeConfig.w(12)),
                                      ),
                                    ),
                                  )))),
                      SizedBox(
                        width: SizeConfig.h(12),
                      ),
                      Expanded(
                        child: MainButton(
                          onTap: () {
                            getReport(data["id"]);
                          },
                          height: SizeConfig.h(50),
                          color: AppStyle.redColor,
                          isOutlined: true,
                          borderRadius: BorderRadius.circular(SizeConfig.h(5)),
                          child: Center(
                              child: Text(
                            S.of(context).report,
                            style: AppStyle.vexa16.copyWith(
                                color: AppStyle.redColor,
                                fontSize: SizeConfig.w(12)),
                          )),
                        ),
                      ),
                    ],
                  ),
                if (data["status"] == "done")
                  Row(
                    children: [
                      Expanded(
                        child: MainButton(
                          onTap: () {
                            showMyDialogRating(data["from_user"]["id"]);
                          },
                          height: SizeConfig.h(50),
                          color: AppStyle.warningColor,
                          isOutlined: true,
                          borderRadius: BorderRadius.circular(SizeConfig.h(5)),
                          child: Center(
                              child: Text(
                            S.of(context).rateOrder,
                            style: AppStyle.vexa16.copyWith(
                                color: AppStyle.warningColor,
                                fontSize: SizeConfig.w(12)),
                          )),
                        ),
                      ),
                      SizedBox(
                        width: SizeConfig.h(12),
                      ),
                      Expanded(
                        child: MainButton(
                          onTap: () {
                            getReport(data["id"]);
                          },
                          height: SizeConfig.h(50),
                          color: AppStyle.redColor,
                          isOutlined: true,
                          borderRadius: BorderRadius.circular(SizeConfig.h(5)),
                          child: Center(
                              child: Text(
                            S.of(context).report,
                            style: AppStyle.vexa16.copyWith(
                                color: AppStyle.redColor,
                                fontSize: SizeConfig.w(12)),
                          )),
                        ),
                      ),
                    ],
                  ),
                if (data["status"] == "pending")
                  if (sl<HomesettingsBloc>().settings?.user?.id ==
                      data["user_id"])
                    Row(
                      children: [
                        Expanded(
                          child: MainButton(
                            onTap: () {
                              cancel(data["id"], context);
                            },
                            height: SizeConfig.h(40),
                            color: AppStyle.redColor,
                            isOutlined: true,
                            borderRadius:
                                BorderRadius.circular(SizeConfig.h(5)),
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
        );
      },
    );
  }

  getReport(item_id) async {
    getReportType = {};
    getReportTypeString = [];
    dropdownValueReport = '';
    reportRequest = {};
    showDialogLoding();
    try {
      var request = await sl<Dio>().get("api/report_types");
      setState(() {
        getReportType = request.data;
        getReportType['data'].forEach((element) {
          getReportTypeString.add(element['title'] ?? "");
        });
        dropdownValueReport = getReportTypeString[0];
        reportRequest = getReportType['data'][0];
      });
      print(dropdownValueReport);
      print(getReportTypeString);
      Navigator.pop(
        context,
      );
      showMyDialogReport(item_id);
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

  postReport(item_id, comment, report_type_id) async {
    showDialogLoding();
    try {
      var request = await sl<Dio>().post("api/reports", data: {
        "item_id": item_id,
        "comment": comment,
        "report_type_id": report_type_id,
        "item_type": "money_requests"
      });
      setState(() {
        getReportType = request.data;
      });
      Navigator.pop(
        context,
      );
      Navigator.pop(
        context,
      );
    } on DioError catch (e) {
      Navigator.pop(
        context,
      );
      Navigator.pop(
        context,
      );
      var error = e.response?.data['message'].toString();

      AppSnackBar.show(context, error!, ToastType.Error);
    } catch (e) {
      Navigator.pop(
        context,
      );
      AppSnackBar.show(context, e.toString(), ToastType.Error);
    }
  }

  Future<void> showMyDialogReport(item_id) async {
    final TextEditingController commentReport = TextEditingController();
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  S.of(context).report,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: SizeConfig.h(15),
                ),
                Expanded(
                  child: Container(
                    height: SizeConfig.h(50),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: AppStyle.greyColor,
                        style: BorderStyle.solid,
                        width: 1.0,
                      ),
                    ),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: SizeConfig.w(15)),
                      child: DropdownReport(),
                    ),
                  ),
                ),
                SizedBox(
                  height: SizeConfig.h(15),
                ),
                buildTextField(S.of(context).comment, commentReport,
                    coment: true),
                SizedBox(
                  height: SizeConfig.h(30),
                ),
                Row(
                  children: [
                    Expanded(
                        child: GestureDetector(
                            onTap: () async {
                              postReport(item_id, commentReport.text,
                                  reportRequest['id']);
                            },
                            child: Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(SizeConfig.h(5)),
                                  color: AppStyle.redColor,
                                ),
                                height: SizeConfig.h(50),
                                width: SizeConfig.screenWidth,
                                child: Container(
                                  child: Center(
                                    child: Text(
                                      S.of(context).report,
                                      style: AppStyle.vexa14
                                          .copyWith(color: AppStyle.whiteColor),
                                    ),
                                  ),
                                )))),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> showDialogWating(data) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Center(
                  child: Text(
                    S.of(context).order_details,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: SizeConfig.h(30),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: SizeConfig.h(12),
                  ),
                  child: Container(
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: SizeConfig.h(40),
                          width: SizeConfig.w(40),
                          child: CircleAvatar(
                            backgroundColor: AppStyle.primaryColor,
                            foregroundColor: AppStyle.primaryColor,
                            radius: SizeConfig.h(40),
                            backgroundImage: (sl<HomesettingsBloc>()
                                        .settings
                                        ?.user
                                        ?.coverImage !=
                                    null)
                                ? NetworkImage(
                                    (sl<HomesettingsBloc>()
                                            .settings
                                            ?.user
                                            ?.coverImage) ??
                                        "https://e7.pngegg.com/pngimages/146/551/png-clipart-user-login-mobile-phones-password-user-miscellaneous-blue-thumbnail.png",
                                  )
                                : NetworkImage(
                                    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRBgZbchuTiUtA3Egi1arN4BEQeoTaUtutQ8A&usqp=CAU"),
                          ),
                        ),
                        SizedBox(
                          width: 16,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                S.of(context).sendername,
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                sl<HomesettingsBloc>().settings?.user?.name ??
                                    "",
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 0.5,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: SizeConfig.h(12),
                  ),
                  child: Container(
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            height: SizeConfig.h(40),
                            width: SizeConfig.w(40),
                            child: CircleAvatar(
                              backgroundColor: AppStyle.primaryColor,
                              foregroundColor: AppStyle.primaryColor,
                              radius: SizeConfig.h(40),
                              backgroundImage:
                                  (NetworkImage(data["user"]["cover_image"])),
                            )),
                        SizedBox(
                          width: 16,
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                S.of(context).FutureName,
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(
                                data["user"]["name"] ?? "",
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 0.5,
                ),
                SizedBox(
                  height: SizeConfig.h(30),
                ),
                Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(SizeConfig.h(5)),
                      color: Color(0xffEBEEFD),
                    ),
                    height: SizeConfig.h(50),
                    width: SizeConfig.screenWidth,
                    child: Container(
                      child: Center(
                        child: Text(
                          S.of(context).amountRequired +
                              "       ${data["amount"]} TL",
                          style: AppStyle.vexa14
                              .copyWith(color: AppStyle.primaryColor),
                        ),
                      ),
                    )),
                SizedBox(
                  height: SizeConfig.h(15),
                ),
                Row(
                  children: [
                    Expanded(
                        child: GestureDetector(
                            onTap: () async {
                              accept(data["id"], context);
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
                                      S.of(context).Acceptance,
                                      style: AppStyle.vexa14
                                          .copyWith(color: AppStyle.whiteColor),
                                    ),
                                  ),
                                )))),
                    SizedBox(
                      width: 16,
                    ),
                    Expanded(
                      child: MainButton(
                        onTap: () => accept(data["id"], context),
                        height: SizeConfig.h(50),
                        color: AppStyle.redColor,
                        isOutlined: true,
                        borderRadius: BorderRadius.circular(SizeConfig.h(5)),
                        child: Center(
                            child: Text(
                          S.of(context).reject,
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
        );
      },
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      {String? Function(String?)? validator,
      bool? obscureText,
      bool coment = false}) {
    return SizedBox(
      child: TextFormField(
        readOnly: !coment,
        validator: validator,
        controller: controller,
        maxLines: coment ? 4 : 1,
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

  Future<void> showMyDialogRating(userId) async {
    final TextEditingController comment = TextEditingController();
    int rating = 0;
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  S.of(context).rate,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: SizeConfig.h(15),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RatingBar(
                        initialRating: 0,
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        itemCount: 5,
                        itemSize: SizeConfig.w(50),
                        ratingWidget: RatingWidget(
                          full: Icon(
                            Icons.star,
                            color: AppStyle.yellowColor,
                          ),
                          half: Icon(Icons.star),
                          empty: Icon(
                            Icons.star_border_outlined,
                            color: AppStyle.yellowColor.withOpacity(0.5),
                          ),
                        ),
                        onRatingUpdate: (rate) {
                          rating = rate.toInt();
                        },
                      ),
                      SizedBox(
                        height: 6,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: SizeConfig.h(15),
                ),
                buildTextField(S.of(context).comment, comment, coment: true),
                SizedBox(
                  height: SizeConfig.h(30),
                ),
                Row(
                  children: [
                    Expanded(
                        child: GestureDetector(
                            onTap: () async {
                              review(userId, rating, comment, context);
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
                                      S.of(context).rateIt,
                                      style: AppStyle.vexa14
                                          .copyWith(color: AppStyle.whiteColor),
                                    ),
                                  ),
                                )))),
                  ],
                ),
              ],
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

  getMoneyRequests() async {
    moneyRequests = [];
    setState(() {
      isLoading = true;
    });
    try {
      var request = await sl<Dio>().get("api/money_requests");
      moneyRequests = request.data["data"];
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

  getMoneyRequestsincomes() async {
    moneyRequests = [];
    setState(() {
      isLoading = true;
    });
    try {
      var request = await sl<Dio>().get("api/money_requests?type=incomes");
      moneyRequests = request.data["data"];
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

  getMoneyRequestsoutcomes() async {
    moneyRequests = [];
    setState(() {
      isLoading = true;
    });
    try {
      var request = await sl<Dio>().get("api/money_requests?type=outcomes");
      moneyRequests = request.data["data"];
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

  getMoneyRequestspagination(int page) async {
    setState(() {
      isLoadingMoneyRequests = true;
    });
    try {
      var request = await sl<Dio>().get("api/money_requests?page=$page");
      if (request.data["data"].isEmpty) {
        isViewPagination = false;
      }
      if (request.data["data"].isNotEmpty) {
        request.data["data"].forEach((element) {
          moneyRequests.add(element);
        });
      }

      setState(() {
        isLoadingMoneyRequests = false;
      });
    } on DioError catch (e) {
      var error =
          (e.response?.data['errors'] as Map).values.first?.first.toString();
      AppSnackBar.show(context, error!, ToastType.Error);
      setState(() {
        isLoadingMoneyRequests = false;
      });
    } catch (e) {
      AppSnackBar.show(context, e.toString(), ToastType.Error);
      setState(() {
        isLoadingMoneyRequests = false;
      });
    }
  }

  getMoneyRequestsincomespagination(int page) async {
    setState(() {
      isLoadingMoneyRequestsincomes = true;
    });
    try {
      var request =
          await sl<Dio>().get("api/money_requests?type=incomes&page=$page");
      if (request.data["data"].isEmpty) {
        isViewPagination = false;
      }
      if (request.data["data"].isNotEmpty) {
        request.data["data"].forEach((element) {
          moneyRequests.add(element);
        });
      }
      setState(() {
        isLoadingMoneyRequestsincomes = false;
      });
    } on DioError catch (e) {
      var error =
          (e.response?.data['errors'] as Map).values.first?.first.toString();
      AppSnackBar.show(context, error!, ToastType.Error);
      setState(() {
        isLoadingMoneyRequestsincomes = false;
      });
    } catch (e) {
      AppSnackBar.show(context, e.toString(), ToastType.Error);
      setState(() {
        isLoadingMoneyRequestsincomes = false;
      });
    }
  }

  getMoneyRequestsoutcomespagination(int page) async {
    setState(() {
      isLoadingMoneyRequestsoutcomes = true;
    });
    try {
      var request =
          await sl<Dio>().get("api/money_requests?type=outcomes&page=$page");
      if (request.data["data"].isEmpty) {
        isViewPagination = false;
      }
      if (request.data["data"].isNotEmpty) {
        request.data["data"].forEach((element) {
          moneyRequests.add(element);
        });
      }
      setState(() {
        isLoadingMoneyRequestsoutcomes = false;
      });
    } on DioError catch (e) {
      var error =
          (e.response?.data['errors'] as Map).values.first?.first.toString();
      AppSnackBar.show(context, error!, ToastType.Error);
      setState(() {
        isLoadingMoneyRequestsoutcomes = false;
      });
    } catch (e) {
      AppSnackBar.show(context, e.toString(), ToastType.Error);
      setState(() {
        isLoadingMoneyRequestsoutcomes = false;
      });
    }
  }

  void pagination() {
    final maxScroll = scrollcontroller.position.maxScrollExtent;
    final currentScroll = scrollcontroller.position.pixels;
    if (indexTab == 0) {
      if (maxScroll - currentScroll <= 50 &&
          !isLoadingMoneyRequests &&
          isViewPagination) {
        page = page! + 1;
        getMoneyRequestspagination(page!);
      }
    }
    if (indexTab == 1) {
      if (maxScroll - currentScroll <= 50 &&
          !isLoadingMoneyRequestsoutcomes &&
          isViewPagination) {
        page = page! + 1;
        getMoneyRequestsoutcomespagination(page!);
      }
    }
    if (indexTab == 2) {
      if (maxScroll - currentScroll <= 50 &&
          !isLoadingMoneyRequestsincomes &&
          isViewPagination) {
        page = page! + 1;
        getMoneyRequestsincomespagination(page!);
      }
    }
  }

  cancel(id, context) async {
    try {
      showDialogLoding();
      await sl<Dio>().post(
        "api/money_requests/$id/cancel",
      );

      Navigator.pop(
        context,
      );
      Navigator.pop(
        context,
      );
      if (indexTab == 0) {
        await getMoneyRequests();
      } else if (indexTab == 2) {
        await getMoneyRequestsincomes();
      } else {
        await getMoneyRequestsoutcomes();
      }
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

  accept(id, context) async {
    try {
      showDialogLoding();
      await sl<Dio>().post(
        "api/money_requests/$id/accept",
      );

      Navigator.pop(
        context,
      );
      Navigator.pop(
        context,
      );
      if (indexTab == 0) {
        await getMoneyRequests();
      } else if (indexTab == 2) {
        await getMoneyRequestsincomes();
      } else {
        await getMoneyRequestsoutcomes();
      }
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

  review(id, rate, comment, context) async {
    try {
      showDialogLoding();
      await sl<Dio>().post("api/reviews", data: {
        "item_type": "User",
        "item_id": "$id",
        "rate": "$rate",
        "comment": "$comment"
      });

      Navigator.pop(
        context,
      );
      Navigator.pop(
        context,
      );
      Navigator.pop(
        context,
      );

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

  refuse(id, context) async {
    try {
      showDialogLoding();
      await sl<Dio>().post(
        "api/money_requests/$id/refuse",
      );

      Navigator.pop(
        context,
      );
      Navigator.pop(
        context,
      );
      if (indexTab == 0) {
        await getMoneyRequests();
      } else if (indexTab == 2) {
        await getMoneyRequestsincomes();
      } else {
        await getMoneyRequestsoutcomes();
      }
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
}

class DropdownReport extends StatefulWidget {
  const DropdownReport();

  @override
  State<DropdownReport> createState() => _DropdownReportState();
}

class _DropdownReportState extends State<DropdownReport> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValueReport,
      icon: Padding(
        padding: selectedLanguage == "ar"
            ? EdgeInsets.only(right: SizeConfig.w(60))
            : EdgeInsets.only(left: SizeConfig.w(60)),
        child: const Icon(
          Icons.arrow_drop_down,
          size: 35,
        ),
      ),
      elevation: 2,
      style: TextStyle(
        color: Color.fromARGB(255, 101, 101, 101),
        fontSize: SizeConfig.h(18),
        fontWeight: FontWeight.w500,
      ),
      onChanged: (String? value) {
        setState(() {
          reportRequest = getReportType['data']
              .where((element) => element["title"] == value);
          dropdownValueReport = value!;
        });
      },
      items: getReportTypeString.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
