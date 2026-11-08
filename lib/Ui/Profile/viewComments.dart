import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:timezone/standalone.dart' as tz;

import '../../App/App.dart';
import '../../Utils/AppSnackBar.dart';
import '../../Utils/SizeConfig.dart';
import '../../Utils/Style.dart';
import '../../data/sharedPreferences/SharedPrefHelper.dart';
import '../../generated/l10n.dart';
import '../../injections.dart';
import 'package:dio/dio.dart';

class ViewComments extends StatefulWidget {
  @override
  _ViewCommentsState createState() => _ViewCommentsState();
}

String selectedLanguage = "ar";

class _ViewCommentsState extends State<ViewComments> {
  bool isLoading = false;
  List<dynamic> data = [];

  @override
  void initState() {
    getQu();
    getLanguage();

    super.initState();
  }

  getLanguage() async {
    selectedLanguage =
        await sl<PrefsHelper>().loadLangFromSharedPref() ?? App.defaultLanguage;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: SizeConfig.h(25),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: SizeConfig.h(24)),
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
                    S.of(context).comments,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  )
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
                : data.isNotEmpty
                    ? Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(SizeConfig.h(16)),
                          child: Container(
                            child: ListView.builder(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: data.length,
                                padding: EdgeInsets.only(
                                    top: SizeConfig.h(5),
                                    bottom: SizeConfig.h(50)),
                                itemBuilder: (context, index) {
                                  final detroit =
                                      tz.getLocation('Europe/Istanbul');
                                  final localizedDt = tz.TZDateTime.from(
                                      DateTime.parse(data[index]["created_at"]),
                                      detroit);

                                  return Flex(
                                    direction: Axis.vertical,
                                    children: [
                                      Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CircleAvatar(
                                              backgroundColor:
                                                  AppStyle.primaryColor,
                                              foregroundColor:
                                                  AppStyle.primaryColor,
                                              radius: SizeConfig.w(20),
                                              backgroundImage: (data[index]
                                                              ["user"]
                                                          ["cover_image"] !=
                                                      null)
                                                  ? NetworkImage(data[index]
                                                      ["user"]["cover_image"])
                                                  : NetworkImage(
                                                      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRBgZbchuTiUtA3Egi1arN4BEQeoTaUtutQ8A&usqp=CAU"),
                                            ),
                                            SizedBox(
                                              width: 16,
                                            ),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    data[index]["user"]["name"],
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  SizedBox(
                                                    height: 6,
                                                  ),
                                                  RatingBar(
                                                    ignoreGestures: true,
                                                    initialRating: data[index]
                                                            ["rate"]
                                                        .toDouble(),
                                                    direction: Axis.horizontal,
                                                    allowHalfRating: false,
                                                    itemCount: 5,
                                                    itemSize: 16,
                                                    ratingWidget: RatingWidget(
                                                      full: Icon(
                                                        Icons.star,
                                                        color: AppStyle
                                                            .yellowColor,
                                                      ),
                                                      half: Icon(Icons.star),
                                                      empty: Icon(
                                                        Icons
                                                            .star_border_outlined,
                                                        color: AppStyle
                                                            .yellowColor
                                                            .withOpacity(0.5),
                                                      ),
                                                    ),
                                                    onRatingUpdate: (rate) {
                                                      //rating = rate.toInt();
                                                    },
                                                  ),
                                                  SizedBox(
                                                    height: 6,
                                                  ),
                                                  Text(
                                                    data[index]["comment"],
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: SizeConfig.h(5)),
                                              child: Text(
                                                "${DateFormatter(Localizations.of(context, String)).getVerboseDateTimeRepresentation(localizedDt)}",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: SizeConfig.h(12)),
                                        child: Divider(
                                          height: 1,
                                          thickness: 0.5,
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                          ),
                        ),
                      )
                    : Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(SizeConfig.h(16)),
                          child: Container(
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
                                    S.of(context).noReviews,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )),
                        ),
                      ),
          ],
        ),
      ),
    );
  }

  getQu() async {
    setState(() {
      isLoading = true;
    });
    try {
      var request = await sl<Dio>().get("api/reviews");
      data = request.data["data"];

      setState(() {
        isLoading = false;
      });
      return true;
    } on DioError catch (e) {
      setState(() {
        isLoading = false;
      });

      AppSnackBar.show(context, S.of(context).code3, ToastType.Error);

      return false;
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      AppSnackBar.show(context, e.toString(), ToastType.Error);

      return false;
    }
  }
}

class DateFormatter {
  DateFormatter(this.localizations);

  Localizations? localizations;

  String getVerboseDateTimeRepresentation(DateTime dateTime) {
    DateTime now = DateTime.now();
    DateTime justNow = now.subtract(Duration(minutes: 1));
    DateTime localDateTime = dateTime.toLocal();

    String roughTimeString = DateFormat('jm').format(dateTime);

    if (localDateTime.day == now.day &&
        localDateTime.month == now.month &&
        localDateTime.year == now.year) {
      return roughTimeString;
    }

    DateTime yesterday = now.subtract(Duration(days: 1));

    if (now.difference(localDateTime).inDays < 4) {
      String weekday =
          DateFormat('EEEE', selectedLanguage).format(localDateTime);

      return '$weekday, $roughTimeString';
    }

    return '${DateFormat('yMd', selectedLanguage).format(dateTime)}, $roughTimeString';
  }
}
