import 'package:CepteATM/Ui/BasePage/BasePage.dart';
import 'package:CepteATM/Ui/Home/BalanceWithdrawal.dart';
import 'package:CepteATM/Ui/Home/DepositBalance.dart';
import 'package:CepteATM/Ui/Home/pay_now_page.dart';
import 'package:CepteATM/constants.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:progiom_cms/auth.dart';
import 'package:progiom_cms/core.dart';
import 'package:progiom_cms/homeSettings.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../App/App.dart';
import '../../App/Widgets/LoginDialoge.dart';
import '../../App/Widgets/MainButton.dart';
import '../../Utils/AppSnackBar.dart';
import '../../data/sharedPreferences/SharedPrefHelper.dart';
import '/generated/l10n.dart';
import 'package:dio/dio.dart';
import './/Utils/SizeConfig.dart';
import './/Utils/Style.dart';
import '../../injections.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

Map<String, dynamic> getReportType = {};
List<String> getReportTypeString = [];
Map<String, dynamic> reportRequest = {};
String dropdownValueReport = '';
String selectedLanguage = "ar";

class HomePageState extends State<HomePage> {
  int currentCarouselIndex = 0;
  bool isOpen = false;
  List<dynamic> moneyRequests = [];
  bool isLoadingMoneyRequests = false;
  bool isLoadingMoneyRequestsPagination = false;

  bool isViewPagination = true;

  int? page;
  ScrollController scrollcontroller = ScrollController();
  bool isLoading = false;
  bool av = false;
  int unreadNotifications = 0;
  bool showedBaseTour = false;
  @override
  void initState() {
    getOpen();
    getLanguage();
    unreadNotification(
        sl<HomesettingsBloc>().settings?.unreadNotifications ?? 0);
    super.initState();
    getMoneyRequests();
    page = 1;
    sl<HomesettingsBloc>().add(GetSettings());

    scrollcontroller.addListener(pagination);
    UniLinks.initDynamicLinks((id) {}, (id) {
      Navigator.pushNamed(context, "/productDetails", arguments: {"id": id});
    });
  }

  getLanguage() async {
    selectedLanguage =
        await sl<PrefsHelper>().loadLangFromSharedPref() ?? App.defaultLanguage;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var settings = sl<HomesettingsBloc>().settings!;
    if (isBuildHome) {
      unreadNotification(
          sl<HomesettingsBloc>().settings?.unreadNotifications ?? 0);

      isBuildHome = false;
      sl<HomesettingsBloc>().add(GetSettings());
      getOpen();
      getMoneyRequests();
      page = 1;
      isViewPagination = true;
    }
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () {
          sl<HomesettingsBloc>().add(GetSettings());
          getOpen();
          unreadNotification(
              sl<HomesettingsBloc>().settings?.unreadNotifications ?? 0);
          getMoneyRequests();
          page = 1;
          isViewPagination = true;
          return Future.delayed(Duration(seconds: 1)).then((value) {});
        },
        child: BlocConsumer<HomesettingsBloc, HomesettingsState>(
          bloc: sl<HomesettingsBloc>(),
          listener: (context, state) {
            print(';;;;;;;;;;;;;;;;;;;;;');
            print(state);
            print(';;;;;;;;;;;;;;;;;;;;;');
            if (state is HomeSettingsReady) {
              unreadNotification(
                  sl<HomesettingsBloc>().settings?.unreadNotifications ?? 0);
            } else {
              unreadNotification(0);
            }
          },
          builder: (context, state) {
            settings = sl<HomesettingsBloc>().settings!;
            return SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Stack(children: [
                SizedBox(
                  width: double.infinity,
                  child: Image.asset(
                    'assets/homeBg.png',
                    height: SizeConfig.h(235),
                    width: SizeConfig.screenWidth,
                    fit: BoxFit.cover,
                  ),
                ),
                unreadNotifications == 0
                    ? Positioned(
                        top: SizeConfig.h(80),
                        right: SizeConfig.w(10),
                        child: InkWell(
                          onTap: () {
                            if (sl<AuthBloc>().isGuest) {
                              showLoginDialoge(context);
                            } else {
                              unreadNotifications = 0;
                              sl<HomesettingsBloc>()
                                  .settings
                                  ?.unreadNotifications = 0;
                              setState(() {});
                              Navigator.pushNamed(context, "/notifications");
                            }
                          },
                          child: Container(
                            child: Column(children: [
                              Image.asset("assets/note.png", height: 24),
                            ]),
                          ),
                        ),
                      )
                    : Positioned(
                        top: SizeConfig.h(80),
                        right: SizeConfig.w(10),
                        child: Badge(
                          position: BadgePosition.topStart(
                            start: -SizeConfig.h(6),
                            top: -SizeConfig.h(10),
                          ),
                          badgeColor: Colors.red,
                          badgeContent: Text(
                            unreadNotifications.toString(),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: SizeConfig.h(11)),
                          ),
                          elevation: 0,
                          child: InkWell(
                            onTap: () {
                              setState(() {});
                              if (sl<AuthBloc>().isGuest) {
                                showLoginDialoge(context);
                              } else {
                                unreadNotifications = 0;
                                sl<HomesettingsBloc>()
                                    .settings
                                    ?.unreadNotifications = 0;
                                Navigator.pushNamed(context, "/notifications");
                              }
                            },
                            child: Container(
                              child: Column(children: [
                                Image.asset("assets/note.png", height: 24),
                              ]),
                            ),
                          ),
                        ),
                      ),
                Positioned(
                  top: SizeConfig.h(60),
                  right: SizeConfig.w(10),
                  left: SizeConfig.w(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: SizeConfig.h(50),
                        width: SizeConfig.w(50),
                        child: CircleAvatar(
                          backgroundColor: AppStyle.primaryColor,
                          foregroundColor: AppStyle.primaryColor,
                          radius: SizeConfig.h(50),
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
                        height: 8,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            S.of(context).welcome,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppStyle.whiteColor, fontSize: 12),
                          ),
                          Text(
                            sl<HomesettingsBloc>().settings?.user?.name ??
                                S.of(context).new_user,
                            style: TextStyle(
                                color: AppStyle.whiteColor,
                                fontSize: 20,
                                overflow: TextOverflow.ellipsis,
                                fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                    top: SizeConfig.h(65),
                    left: SizeConfig.w(51),
                    key: open,
                    child: Switch(
                        value: av,
                        thumbColor: MaterialStateProperty.resolveWith(getColor),
                        inactiveThumbColor: AppStyle.disabledColor,
                        inactiveTrackColor: AppStyle.disabledColor,
                        activeColor: Color.fromARGB(255, 66, 236, 89),
                        onChanged: (v) {
                          av ? deleteAddress() : _getGeoLocation();
                          showDialogLoding();
                        })),
                Positioned(
                    top: SizeConfig.h(82),
                    left: SizeConfig.w(20),
                    child: Text(
                      S.of(context).available,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    )),
                Padding(
                  padding: EdgeInsets.only(top: SizeConfig.h(210)),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    height: SizeConfig.h(600),
                    width: SizeConfig.screenWidth,
                  ),
                ),
                Positioned(
                  top: SizeConfig.h(175),
                  left: SizeConfig.w(25),
                  right: SizeConfig.w(25),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0.0, 3.0),
                          blurRadius: 6,
                          color: Colors.black12,
                        ),
                      ],
                    ),
                    height: SizeConfig.h(80),
                    width: SizeConfig.w(340),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 12,
                        ),
                        Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  S.of(context).Available_balance,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppStyle.primaryColor),
                                ),
                                SizedBox(
                                  height: SizeConfig.h(16),
                                ),
                                FittedBox(
                                  child: Text(
                                    sl<HomesettingsBloc>()
                                            .settings!
                                            .user!
                                            .balance ??
                                        "",
                                    style: TextStyle(
                                        fontSize: 24,
                                        color: AppStyle.primaryColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              ],
                            )),
                        Expanded(
                            child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                                color: AppStyle.primaryColor, width: 0.5),
                            color: Colors.white,
                          ),
                          height: 60,
                          width: 60,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RotationTransition(
                                  turns: new AlwaysStoppedAnimation(310 / 360),
                                  child: Icon(Icons.arrow_upward_rounded,
                                      color: AppStyle.primaryColor)),
                              Text(
                                S.of(context).outgoing,
                                style: TextStyle(
                                    fontSize: 12, color: AppStyle.greyColor),
                              ),
                              SizedBox(
                                height: SizeConfig.h(4),
                              ),
                              FittedBox(
                                child: Text(
                                  sl<HomesettingsBloc>()
                                          .settings!
                                          .user!
                                          .total_outcomes ??
                                      "",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: AppStyle.primaryColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          ),
                        )),
                        SizedBox(
                          width: 12,
                        ),
                        Expanded(
                            child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                                color: AppStyle.primaryColor, width: 0.5),
                            color: Colors.white,
                          ),
                          height: 60,
                          width: 60,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RotationTransition(
                                  turns: new AlwaysStoppedAnimation(310 / 360),
                                  child: Icon(Icons.arrow_downward_rounded,
                                      color: AppStyle.primaryColor)),
                              Text(
                                S.of(context).incoming,
                                style: TextStyle(
                                    fontSize: 12, color: AppStyle.greyColor),
                              ),
                              SizedBox(
                                height: SizeConfig.h(4),
                              ),
                              FittedBox(
                                child: Text(
                                  sl<HomesettingsBloc>()
                                          .settings!
                                          .user!
                                          .total_incomes ??
                                      "",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: AppStyle.primaryColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          ),
                        )),
                        SizedBox(
                          width: 12,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: SizeConfig.h(275),
                  left: SizeConfig.w(25),
                  right: SizeConfig.w(25),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                          child: InkWell(
                        key: deposit,
                        onTap: () async {
                          var isSccs = await Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => DepositBalance()),
                          );
                          if (isSccs == "true") {
                            sl<HomesettingsBloc>().add(GetSettings());
                            getOpen();
                            getMoneyRequests();
                            page = 1;
                            isViewPagination = true;
                            AppSnackBar.show(context,
                                S.of(context).Successfully, ToastType.Success);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                                color: AppStyle.primaryColor, width: 0.5),
                            color: Color(0xffF5F7FE),
                          ),
                          height: 60,
                          width: 60,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 8,
                              ),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      S.of(context).DepositBalance,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: AppStyle.primaryColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      S.of(context).deposit,
                                      textAlign: TextAlign.start,
                                      maxLines: 2,
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: AppStyle.greyColor),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                  flex: 2,
                                  child: Image.asset(
                                    "assets/outgoing.png",
                                    height: SizeConfig.w(46),
                                    width: SizeConfig.w(46),
                                  )),
                            ],
                          ),
                        ),
                      )),
                      SizedBox(
                        width: 12,
                      ),
                      Expanded(
                          child: InkWell(
                        key: balance,
                        onTap: () async {
                          var isSccs = await Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => BalanceWithdrawal()),
                          );
                          if (isSccs == "true") {
                            sl<HomesettingsBloc>().add(GetSettings());
                            getOpen();
                            getMoneyRequests();
                            page = 1;
                            isViewPagination = true;
                            AppSnackBar.show(context,
                                S.of(context).Successfully, ToastType.Success);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                                color: AppStyle.primaryColor, width: 0.5),
                            color: Color(0xffF5F7FE),
                          ),
                          height: 60,
                          width: 60,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 8,
                              ),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      S.of(context).Balance_withdrawal,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: AppStyle.primaryColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      S.of(context).withdraw,
                                      textAlign: TextAlign.start,
                                      maxLines: 2,
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: AppStyle.greyColor),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                  flex: 2,
                                  child: Image.asset(
                                    "assets/incoming.png",
                                    height: SizeConfig.w(46),
                                    width: SizeConfig.w(46),
                                  )),
                            ],
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
                Positioned(
                    top: SizeConfig.h(350),
                    left: SizeConfig.w(25),
                    right: SizeConfig.w(25),
                    child: Column(
                        key: record,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            S.of(context).Operationslog,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                          ),
                          isLoadingMoneyRequests
                              ? Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                      height: SizeConfig.h(350),
                                      child: Center(
                                          child: CircularProgressIndicator(
                                              color: AppStyle.primaryColor))),
                                )
                              : listTran(moneyRequests),
                        ]))
              ]),
            );
          },
        ),
      ),
    );
  }

  getOpen() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    av = await prefs.getBool('open') ?? false;
  }

  setOpen(open) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setBool('open', open);
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
      MaterialState.selected
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.green;
    }
    return AppStyle.disabledColor;
  }

  unreadNotification(unread) {
    setState(() {
      unreadNotifications = unread;
    });
  }

  refresh() {
    sl<HomesettingsBloc>().add(GetSettings());
    getOpen();
    unreadNotification(
        sl<HomesettingsBloc>().settings?.unreadNotifications ?? 0);
    getMoneyRequests();
    page = 1;
    isViewPagination = true;
    Future.delayed(Duration(seconds: 1)).then((value) {});
  }

  refreshIsOpen() {
    if (isOpen) {
      Navigator.of(context).pop();
      sl<HomesettingsBloc>().add(GetSettings());
      getOpen();
      unreadNotification(
          sl<HomesettingsBloc>().settings?.unreadNotifications ?? 0);
      getMoneyRequests();
      page = 1;
      isViewPagination = true;
      Future.delayed(Duration(seconds: 1)).then((value) {});
    } else {
      sl<HomesettingsBloc>().add(GetSettings());
      getOpen();
      unreadNotification(
          sl<HomesettingsBloc>().settings?.unreadNotifications ?? 0);
      getMoneyRequests();
      page = 1;
      isViewPagination = true;
      Future.delayed(Duration(seconds: 1)).then((value) {});
    }
  }

  addAddress(String long, String lat, String amount) async {
    try {
      setState(() {
        isLoading = true;
      });
      await sl<Dio>().post("api/addresses",
          data: {"long": long, "lat": lat, "amount": amount});
      setState(() {
        isLoading = false;
        av = !av;
        setOpen(av);
      });
      Navigator.pop(
        context,
      );
    } on DioError catch (e) {
      setState(() {
        isLoading = false;
      });
      Navigator.pop(
        context,
      );
      var error =
          (e.response?.data['errors'] as Map).values.first?.first.toString();
      AppSnackBar.show(context, error!, ToastType.Error);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Navigator.pop(
        context,
      );
      AppSnackBar.show(context, e.toString(), ToastType.Error);
    }
  }

  deleteAddress() async {
    try {
      setState(() {
        isLoading = true;
      });
      await sl<Dio>().post("api/addresses/1", data: {
        "_method": "DELETE",
      });
      setState(() {
        isLoading = false;
        av = !av;
        setOpen(av);
      });
      Navigator.pop(
        context,
      );
    } on DioError catch (e) {
      setState(() {
        isLoading = false;
      });
      Navigator.pop(
        context,
      );
      var error =
          (e.response?.data['errors'] as Map).values.first?.first.toString();
      AppSnackBar.show(context, error!, ToastType.Error);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Navigator.pop(
        context,
      );
      AppSnackBar.show(context, e.toString(), ToastType.Error);
    }
  }

  _getGeoLocation() async {
    Position position = await _getGeoLocationPosition();
    Navigator.pop(
      context,
    );
    showMyOpenDialog(position);
    positionMarker = LatLng(position.latitude, position.longitude);
    kGooglePlex = CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 15,
    );
  }

  Future<void> showMyOpenDialog(position) async {
    final TextEditingController amountRequiredController =
        TextEditingController();
    final GlobalKey<FormState> formKey2 = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Form(
              key: formKey2,
              child: ListBody(
                children: <Widget>[
                  Text(
                    S.of(context).cash1,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: SizeConfig.h(15),
                  ),
                  buildTextField2(S.of(context).cash2, amountRequiredController,
                      validator: (v) {
                    if (v != null && v.isEmpty) return S.of(context).cash2;
                    return null;
                  }),
                  SizedBox(
                    height: SizeConfig.h(30),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: MainButton(
                          onTap: () {
                            Navigator.pop(
                              context,
                            );
                          },
                          height: SizeConfig.h(40),
                          color: AppStyle.redColor,
                          isOutlined: true,
                          borderRadius: BorderRadius.circular(SizeConfig.h(5)),
                          child: Center(
                              child: Text(
                            S.of(context).cancel,
                            style: AppStyle.vexa16
                                .copyWith(color: AppStyle.redColor),
                          )),
                        ),
                      ),
                      SizedBox(
                        width: SizeConfig.w(6),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            if (formKey2.currentState?.validate() ?? false) {
                              addAddress(
                                  position.longitude.toString(),
                                  position.latitude.toString(),
                                  amountRequiredController.text);
                              Navigator.pop(
                                context,
                              );
                              showDialogLoding();
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(SizeConfig.h(5)),
                              color: AppStyle.primaryColor,
                            ),
                            height: SizeConfig.h(40),
                            width: SizeConfig.screenWidth,
                            child: Container(
                              child: Center(
                                child: Text(
                                  S.of(context).sendRequest,
                                  style: AppStyle.vexa14
                                      .copyWith(color: AppStyle.whiteColor),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: SizeConfig.h(15),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Navigator.pop(
        context,
      );
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

  listTran(List<dynamic> data) {
    return data.isNotEmpty
        ? Container(
            height: SizeConfig.h(380),
            child: RefreshIndicator(
              onRefresh: () {
                unreadNotification(
                    sl<HomesettingsBloc>().settings?.unreadNotifications ?? 0);
                sl<HomesettingsBloc>().add(GetSettings());
                getOpen();
                getMoneyRequests();
                page = 1;
                isViewPagination = true;
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
                        ? isLoadingMoneyRequestsPagination
                            ? Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: new CircularProgressIndicator(
                                    color: AppStyle.primaryColor,
                                  ),
                                ),
                              )
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
                                                  fontSize: 13,
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 48,
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            ));
  }

  Future<void> showDialogQr(data) async {
    isOpen = true;
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
    ).then((value) => isOpen = false);
  }

  Future<void> showMyDialog(data) async {
    final TextEditingController amountRequiredController =
        TextEditingController();
    final TextEditingController dateOfOrderController = TextEditingController();
    final TextEditingController requestTimeController = TextEditingController();
    final TextEditingController order_number = TextEditingController();
    order_number.text = data["uuid"] ?? "";

    amountRequiredController.text = data["amount"].toString();
    dateOfOrderController.text = data["date"];
    requestTimeController.text =
        (data["time"].substring(0, data["time"].length - 3) ?? "");
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
      {String? Function(String?)? validator, bool coment = false}) {
    return SizedBox(
      child: TextFormField(
        readOnly: coment ? false : true,
        validator: validator,
        controller: controller,
        obscureText: false,
        maxLines: coment ? 4 : 1,
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

  Widget buildTextField2(String label, TextEditingController controller,
      {String? Function(String?)? validator, bool coment = false}) {
    return SizedBox(
      child: TextFormField(
        validator: validator,
        controller: controller,
        obscureText: false,
        keyboardType: TextInputType.number,
        maxLines: 1,
        inputFormatters: [
          LengthLimitingTextInputFormatter(6),
        ],
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
      isLoadingMoneyRequests = true;
    });
    try {
      var request = await sl<Dio>().get("api/money_requests");
      moneyRequests = request.data["data"];
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

  getMoneyRequestspagination(int page) async {
    setState(() {
      isLoadingMoneyRequestsPagination = true;
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
        isLoadingMoneyRequestsPagination = false;
      });
    } on DioError catch (e) {
      var error =
          (e.response?.data['errors'] as Map).values.first?.first.toString();
      AppSnackBar.show(context, error!, ToastType.Error);
      setState(() {
        isLoadingMoneyRequestsPagination = false;
      });
    } catch (e) {
      AppSnackBar.show(context, e.toString(), ToastType.Error);
      setState(() {
        isLoadingMoneyRequestsPagination = false;
      });
    }
  }

  void pagination() {
    final maxScroll = scrollcontroller.position.maxScrollExtent;
    final currentScroll = scrollcontroller.position.pixels;

    if (maxScroll - currentScroll <= 50 &&
        !isLoadingMoneyRequests &&
        isViewPagination) {
      page = page! + 1;
      getMoneyRequestspagination(page!);
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
      await getMoneyRequests();

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
      await getMoneyRequests();

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
      await getMoneyRequests();

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
