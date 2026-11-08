import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:progiom_cms/core.dart';
import 'package:progiom_cms/homeSettings.dart';
import 'package:progiom_cms/notifications.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../App/App.dart';
import '../../App/Widgets/MainButton.dart';
import '../../Utils/AppSnackBar.dart';
import '../../data/sharedPreferences/SharedPrefHelper.dart';
import '/App/Widgets/AppErrorWidget.dart';
import '/App/Widgets/AppLoader.dart';
import 'package:dio/dio.dart';
import '/App/Widgets/EmptyPlacholder.dart';
import '/Ui/Notifications/bloc/notifications_bloc.dart';
import '/Utils/SizeConfig.dart';
import '/Utils/Style.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/generated/l10n.dart';

import '../../injections.dart';

class NotificationsPage extends StatefulWidget {
  NotificationsPage({Key? key}) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

Map<String, dynamic> getReportType = {};
List<String> getReportTypeString = [];
Map<String, dynamic> reportRequest = {};
String dropdownValueReport = '';
String selectedLanguage = "ar";

class _NotificationsPageState extends State<NotificationsPage> {
  final Color unReadColor = const Color(0xFFEAEAEA);
  final NotificationsBLoc bloc = NotificationsBLoc();
  getLanguage() async {
    selectedLanguage =
        await sl<PrefsHelper>().loadLangFromSharedPref() ?? App.defaultLanguage;
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    bloc.add(LoadEvent(""));
    getLanguage();
    super.initState();
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  List<bool> notIisRead = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(
            height: SizeConfig.h(50),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: SizeConfig.h(18)),
            child: Row(
              children: [
                InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.arrow_back)),
                SizedBox(
                  width: SizeConfig.w(20),
                ),
                Text(
                  S.of(context).notifications,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder(
              bloc: bloc,
              builder: (context, state) {
                if (state is ErrorState) {
                  return AppErrorWidget(text: state.error);
                }
                if (state is LoadingState) {
                  return AppLoader();
                }
                if (state is SuccessState<List<ServerNotification>>) {
                  if (state.items.isEmpty) {
                    return EmptyPlacholder(
                      title: S.of(context).no_notifications,
                      imageName: "assets/noNotifications.png",
                      subtitle: S.of(context).no_notifications_subtitle,
                    );
                  }
                  return ListView.builder(
                      controller: bloc.scrollController,
                      padding: EdgeInsets.only(top: SizeConfig.h(5)),
                      itemCount: state.hasReachedMax
                          ? state.items.length
                          : state.items.length + 1,
                      itemBuilder: (context, index) {
                        if (index >= state.items.length)
                          return Center(
                            child: AppLoader(),
                          );
                        final noti = state.items[index];
                        notIisRead.add(noti.isRead);
                        final color = noti.notificationType == "danger"
                            ? AppStyle.redColor
                            : noti.notificationType == "info"
                                ? AppStyle.secondaryColor
                                : noti.notificationType == "success"
                                    ? AppStyle.greenColor
                                    : AppStyle.warningColor;
                        final color2 = noti.notificationType == "danger"
                            ? Color(0xffFFF1F1)
                            : noti.notificationType == "info"
                                ? Color(0xffF5F7FE)
                                : noti.notificationType == "success"
                                    ? Color(0xffF5F7FE)
                                    : Color(0xffFEFFF1);
                        return GestureDetector(
                          onTap: () {
                            if (!notIisRead[index]) {
                              SetNotificationAsRead(sl()).call(
                                  SetNotificationAsReadParams(
                                      notificationId: noti.id));
                              setState(() {
                                notIisRead[index] = true;
                              });
                            }

                            if (noti.entityType == "moneyRequest") {
                              showMonyReq(noti.data!["moneyRequest"]["id"]);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: SizeConfig.h(24),
                                vertical: SizeConfig.h(14)),
                            width: SizeConfig.screenWidth,
                            color: !notIisRead[index]
                                ? unReadColor
                                : AppStyle.whiteColor,
                            margin:
                                EdgeInsets.symmetric(vertical: SizeConfig.h(5)),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          noti.notificationTitle,
                                          style: AppStyle.vexa14.copyWith(
                                              color: AppStyle.secondaryColor),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              alignment: Alignment.center,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: SizeConfig.h(15),
                                                  vertical: SizeConfig.h(5)),
                                              child: Text(
                                                noti.notificationType ==
                                                        "danger"
                                                    ? S.of(context).danger
                                                    : noti.notificationType ==
                                                            "info"
                                                        ? S.of(context).info
                                                        : noti.notificationType ==
                                                                "success"
                                                            ? S
                                                                .of(context)
                                                                .success
                                                            : S
                                                                .of(context)
                                                                .warning,
                                                style: AppStyle.vexaLight12
                                                    .copyWith(
                                                        color: color,
                                                        fontSize:
                                                            SizeConfig.h(10)),
                                              ),
                                              decoration: BoxDecoration(
                                                  color: color2,
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  border: Border.all(
                                                      color: color2)),
                                              height: SizeConfig.h(36),
                                              width: SizeConfig.w(100),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: SizeConfig.h(8),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        noti.notificationText,
                                        style: AppStyle.vexaLight12.copyWith(
                                          fontSize: SizeConfig.h(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                }
                return Container();
              },
            ),
          ),
        ],
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
        obscureText: obscureText ?? false,
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

  Future<void> showMyDialog(data) async {
    final TextEditingController amountRequiredController =
        TextEditingController();
    final TextEditingController dateOfOrderController = TextEditingController();
    final TextEditingController requestTimeController = TextEditingController();
    amountRequiredController.text = data["amount"].toString();
    dateOfOrderController.text = data["date"];
    requestTimeController.text = data["time"];
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
                if (data["status_text"] == "in_progress")
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
                if (data["status_text"] == "done")
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
                if (data["status_text"] == "pending")
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
      bloc.add(LoadEvent(""));

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
      bloc.add(LoadEvent(""));

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
      bloc.add(LoadEvent(""));

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

  showMonyReq(int id) async {
    try {
      showDialogLoding();
      var requests = await sl<Dio>().get(
        "api/money_requests/$id",
      );
      var data = requests.data;
      Navigator.pop(
        context,
      );
      if (data["status_text"] == "pending") {
        sl<HomesettingsBloc>().settings!.user!.id != data["user_id"]
            ? showDialogWating(data)
            : showMyDialog(data);
      } else if (data["status_text"] == "in_progress") {
        if (sl<HomesettingsBloc>().settings!.user!.id == data["user_id"]) {
          showDialogQr(data);
        }
      } else {
        showMyDialog(data);
      }
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
                SizedBox(
                  height: SizeConfig.h(24),
                ),
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
