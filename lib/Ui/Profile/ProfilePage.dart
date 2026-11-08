import 'dart:io';

import 'package:CepteATM/Ui/Profile/page_view_page.dart';
import 'package:CepteATM/Ui/Profile/viewComments.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:progiom_cms/auth.dart';
import 'package:progiom_cms/core.dart';
import 'package:progiom_cms/homeSettings.dart';
import 'package:progiom_cms/notifications.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '/App/App.dart';
import '/App/Widgets/MainButton.dart';
import '/Utils/AppSnackBar.dart';
import '/Utils/SizeConfig.dart';
import '/Utils/Style.dart';
import '/data/sharedPreferences/SharedPrefHelper.dart';
import '/generated/l10n.dart';
import '../../injections.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'commonQuestions.dart';

part 'widgets/profile_tutorial.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool notificationEnabled = true;
  bool showLanguages = false;
  bool showCurrencies = false;

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
      MaterialState.selected
    };
    if (states.any(interactiveStates.contains)) {
      return AppStyle.primaryColor;
    }
    return AppStyle.disabledColor;
  }

  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool notificationsEnabled = false;
  final debouncer = Debouncer();
  String selectedLanguage = "ar";
  String? selectedCurrency;
  PackageInfo? packageInfo;
  late final String uuid;
  String phone = '';
  @override
  void initState() {
    super.initState();

    getPreferences();
    getLanguage();
    PackageInfo.fromPlatform().then((value) {
      if (mounted)
        setState(() {
          packageInfo = value;
        });
    }).catchError((onError) {});

    phone = (sl<HomesettingsBloc>().settings?.user?.mobile == null
        ? ''
        : sl<HomesettingsBloc>().settings?.user?.mobile!)!;
  }

  Map? preferences;

  getPreferences() async {
    final result = await GetPreferences(sl()).call(NoParams());
    result.fold((l) {
      AppSnackBar.show(context, l.errorMessage, ToastType.Error);
    }, (r) {
      if (mounted)
        setState(() {
          preferences = r;
          notificationsEnabled = preferences!["push_notifications"] == 1;
        });
    });
  }

  getLanguage() async {
    selectedLanguage =
        await sl<PrefsHelper>().loadLangFromSharedPref() ?? App.defaultLanguage;
    selectedCurrency = await sl<PrefsHelper>().loadCurrencyFromSharedPref();
    if (mounted) setState(() {});
  }

  restart(var v) async {
    selectedLanguage = await v;
    await sl<PrefsHelper>().saveLangToSharedPref(v);
    App.setLocale(context, selectedLanguage);
  }

  @override
  Widget build(BuildContext context) {
    final homeModel = sl<HomesettingsBloc>().settings!;
    if (selectedCurrency == null &&
        homeModel.currencies != null &&
        homeModel.currencies!.isNotEmpty)
      selectedCurrency = homeModel.currencies![0].code;
    var unreadNotifications =
        sl<HomesettingsBloc>().settings?.unreadNotifications ?? 0;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              S.of(context).settings,
              style: TextStyle(
                  fontSize: SizeConfig.h(18),
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            elevation: 0.0),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: SizeConfig.w(20),
              right: SizeConfig.w(20),
            ),
            child: Container(
              height: SizeConfig.screenHeight,
              child: ListView(
                children: [
                  SizedBox(
                    height: SizeConfig.h(14),
                  ),
                  buildSubSection(
                    S.of(context).notifications,
                    () {},
                    svgSize: 18,
                    icon: Icons.notifications,
                    trailing: Transform.scale(
                        scale: 0.7,
                        child: Switch(
                            value: notificationEnabled,
                            thumbColor:
                                MaterialStateProperty.resolveWith(getColor),
                            inactiveThumbColor: AppStyle.disabledColor,
                            inactiveTrackColor: AppStyle.disabledColor,
                            activeColor: AppStyle.primaryColor,
                            onChanged: (v) {
                              setState(() {
                                notificationsEnabled = v;
                              });
                              debouncer.run(() {
                                DisableEnableNotification(sl()).call(
                                    DisableEnableNotificationParams(
                                        enable: notificationsEnabled));
                              });
                            })),
                  ),
                  SizedBox(
                    height: SizeConfig.h(14),
                  ),
                  buildSubSection(
                    S.of(context).technicalSupport,
                    () {
                      if (preferences != null)
                        sendMessageToWhatsapp(preferences!["support_phone"],
                            "مرحبا انا ${sl<HomesettingsBloc>().settings?.user?.name ?? ""} ");
                    },
                    svgSize: 18,
                    svgAsset: "assets/support.svg",
                    trailing: IconButton(
                      icon: Icon(Icons.arrow_forward_ios_sharp,
                          size: SizeConfig.h(18)),
                      onPressed: () {
                        if (preferences != null)
                          sendMessageToWhatsapp(preferences!["support_phone"],
                              "مرحبا انا ${sl<HomesettingsBloc>().settings?.user?.name ?? ""} ");
                      },
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.h(14),
                  ),
                  buildSubSection(
                    S.of(context).shareApp,
                    () {
                      shareApp();
                    },
                    icon: Icons.share_outlined,
                    trailing: IconButton(
                      icon: Icon(Icons.arrow_forward_ios_sharp,
                          size: SizeConfig.h(18)),
                      onPressed: () {
                        shareApp();
                      },
                    ),
                  ),
                  Column(children: [
                    for (PageModel page in homeModel.pages ?? [])
                      Column(
                        children: [
                          SizedBox(
                            height: SizeConfig.h(14),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (_) => PageViewScreen(page.id)));
                            },
                            child: Container(
                              padding: EdgeInsets.only(bottom: SizeConfig.h(8)),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.black12, width: 0.5))),
                              child: Row(
                                children: [
                                  Image.network(
                                    page.coverImage ?? "",
                                    fit: BoxFit.fill,
                                    color: AppStyle.primaryColor,
                                    height: SizeConfig.h(24),
                                    width: SizeConfig.h(24),
                                  ),
                                  SizedBox(
                                    width: SizeConfig.h(16),
                                  ),
                                  Text(
                                    page.title,
                                    style: AppStyle.vexa14.copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  Spacer(),
                                  IconButton(
                                    icon: Icon(Icons.arrow_forward_ios_sharp,
                                        size: SizeConfig.h(18)),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                              builder: (_) =>
                                                  PageViewScreen(page.id)));
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                  ]),
                  SizedBox(
                    height: SizeConfig.h(14),
                  ),
                  buildSubSection(S.of(context).language, () {
                    setState(() {
                      showLanguages = !showLanguages;
                    });
                  },
                      svgSize: 18,
                      icon: Icons.language,
                      trailing: SizedBox(
                        height: SizeConfig.h(50),
                        child: IconButton(
                          icon: Icon(Icons.arrow_forward_ios_sharp,
                              size: SizeConfig.h(18)),
                          onPressed: () {
                            setState(() {
                              showLanguages = !showLanguages;
                            });
                          },
                        ),
                      )),
                  if (showLanguages)
                    Column(
                      children: [
                        if (isLanguageActive("ar", homeModel))
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  child: RadioListTile<String>(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text(S.of(context).arabic,
                                          style: AppStyle.vexaLight12),
                                      activeColor: AppStyle.primaryColor,
                                      value: "ar",
                                      groupValue: selectedLanguage,
                                      onChanged: (dynamic v) async {
                                        await restart(v);
                                        // Restart.restartApp();
                                      }),
                                ),
                              )
                            ],
                          ),
                        if (isLanguageActive("en", homeModel))
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  child: RadioListTile<String>(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text(S.of(context).english,
                                          style: AppStyle.vexaLight12),
                                      activeColor: AppStyle.primaryColor,
                                      value: "en",
                                      groupValue: selectedLanguage,
                                      onChanged: (dynamic v) async {
                                        await restart(v);
                                        //   Restart.restartApp();
                                      }),
                                ),
                              )
                            ],
                          ),
                        if (isLanguageActive("tr", homeModel))
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  child: RadioListTile<String>(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text(S.of(context).turkish,
                                          style: AppStyle.vexaLight12),
                                      activeColor: AppStyle.primaryColor,
                                      value: "tr",
                                      groupValue: selectedLanguage,
                                      onChanged: (v) {
                                        setState(() {
                                          selectedLanguage = v!;
                                          sl<PrefsHelper>()
                                              .saveLangToSharedPref(v);
                                          App.setLocale(
                                              context, selectedLanguage);
                                        });
                                      }),
                                ),
                              )
                            ],
                          )
                      ],
                    ),
                  SizedBox(
                    height: SizeConfig.h(14),
                  ),
                  buildSubSection(
                    S.of(context).View_comments,
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ViewComments(),
                        ),
                      );
                    },
                    icon: Icons.comment,
                    trailing: IconButton(
                      icon: Icon(Icons.arrow_forward_ios_sharp,
                          size: SizeConfig.h(18)),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ViewComments(),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.h(14),
                  ),
                  buildSubSection(
                    S.of(context).commonQuestions,
                    () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CommonQuestions(),
                        ),
                      );
                    },
                    icon: Icons.question_answer_outlined,
                    trailing: IconButton(
                      icon: Icon(Icons.arrow_forward_ios_sharp,
                          size: SizeConfig.h(18)),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CommonQuestions(),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.h(40),
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: SizeConfig.h(24),
                      ),
                      Expanded(
                          child: GestureDetector(
                        onTap: () async {
                          sl<AuthBloc>().add(LogoutEvent());
                          sl<HomesettingsBloc>().settings?.user = null;
                          Navigator.pushReplacementNamed(context, "/login",
                              arguments: false);
                        },
                        child: SizedBox(
                          height: SizeConfig.h(44),
                          child: MainButton(
                            color: AppStyle.redColor,
                            isOutlined: true,
                            child: Center(
                                child: Text(
                              S.of(context).signOut,
                              style: AppStyle.vexa16
                                  .copyWith(color: AppStyle.redColor),
                            )),
                          ),
                        ),
                      )),
                      SizedBox(
                        width: SizeConfig.h(24),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: SizeConfig.h(180),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSubSection(
    String title,
    Function onTap, {
    IconData? icon,
    String? svgAsset,
    double? svgSize,
    Widget? trailing,
    GlobalKey? key,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        onTap();
      },
      child: Container(
        padding: EdgeInsets.only(bottom: SizeConfig.h(8)),
        width: double.infinity,
        decoration: BoxDecoration(
            border:
                Border(bottom: BorderSide(color: Colors.black12, width: 0.5))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          key: key,
          children: [
            icon != null
                ? Icon(
                    icon,
                    color: AppStyle.primaryColor,
                    size: SizeConfig.h(24),
                  )
                : SvgPicture.asset(
                    svgAsset!,
                    height: SizeConfig.h(svgSize!),
                    width: SizeConfig.h(svgSize),
                    color: AppStyle.primaryColor,
                  ),
            SizedBox(
              width: SizeConfig.h(16),
            ),
            Text(
              title,
              style: AppStyle.vexa14
                  .copyWith(color: Colors.black, fontWeight: FontWeight.w700),
            ),
            if (trailing != null) Spacer(),
            if (trailing != null) trailing
          ],
        ),
      ),
    );
  }

  Widget buildTextField(
      String label, IconData icon, TextEditingController controller) {
    return SizedBox(
      height: SizeConfig.h(50),
      child: TextField(
        readOnly: true,
        controller: controller,
        decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(
                  width: 1,
                  style: BorderStyle.solid,
                  color: AppStyle.primaryColor),
              borderRadius: const BorderRadius.all(
                const Radius.circular(10),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  width: 1,
                  style: BorderStyle.solid,
                  color: AppStyle.disabledColor),
              borderRadius: const BorderRadius.all(
                const Radius.circular(10),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  width: 1,
                  style: BorderStyle.solid,
                  color: AppStyle.primaryColor),
              borderRadius: const BorderRadius.all(
                const Radius.circular(10),
              ),
            ),
            prefixIcon: Icon(
              icon,
            ),
            labelText: label,
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            labelStyle: TextStyle(fontSize: SizeConfig.h(14)),
            fillColor: Colors.white70),
      ),
    );
  }
}

void shareApp() {
  if (Platform.isIOS)
    actionShare("https://apps.apple.com/us/app", SizeConfig.screenWidth);
  else
    actionShare(
        "https://play.google.com/store/apps/details", SizeConfig.screenWidth);
}

bool isLanguageActive(String slug, homeModel) {
  return (homeModel.languages.contains(Languages(slug: slug)));
}
