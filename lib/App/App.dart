import 'dart:async';
import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:progiom_cms/auth.dart';
import 'package:progiom_cms/core.dart';
import 'package:progiom_cms/homeSettings.dart';
import '../constants.dart';
import '/Ui/Notifications/NotificationsPage.dart';
import '/Ui/Splash/SplashPage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/Utils/Style.dart';
import '/data/sharedPreferences/SharedPrefHelper.dart';
import '/generated/l10n.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../injections.dart';
import '../router.dart';

class App extends StatefulWidget {
  static String defaultLanguage = "ar";
  static String defaultCurrency = "USD";

  @override
  _AppState createState() => _AppState();

  static void setLocale(BuildContext context, String newLocale) {
    _AppState state = context.findAncestorStateOfType()!;
    state.setState(() {
      state.locale = Locale(newLocale);
    });
    sl<PrefsHelper>().saveLangToSharedPref(newLocale);
  }
}

GlobalKey<NavigatorState> navigatorKey = GlobalKey();

class _AppState extends State<App> {
  Locale? locale;
  String? deviceLanguageCode, backUpLanguageCode;

  FlutterLocalNotificationsPlugin? fltrNotification;

  Future _showNotification(
      String title, String body, var id, var image, var name) async {
    var androidDetails = new AndroidNotificationDetails(
      'channel_id_5',
      'dbfood 2',
      'CHANNEL DESCRIPTION',
      priority: Priority.high,
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('noti'),
    );
    var iSODetails = new IOSNotificationDetails();
    var generalNotificationDetails =
        new NotificationDetails(android: androidDetails, iOS: iSODetails);

    BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      body,
      htmlFormatBigText: true,
      contentTitle: title,
      htmlFormatContentTitle: true,
    );

    await fltrNotification!
        .show(0, title, body, generalNotificationDetails, payload: '');
  }

  onSelectNotification(notificationResponse) async {
    Navigator.of(navigatorKey.currentContext!)
        .push(MaterialPageRoute(builder: (context) => NotificationsPage()));
  }

  initFirebaseMessaging() async {
    await Firebase.initializeApp();
    var androidInitilize =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOSinitilize = new IOSInitializationSettings();
    var initilizationsSettings = new InitializationSettings(
        android: androidInitilize, iOS: iOSinitilize);
    fltrNotification = new FlutterLocalNotificationsPlugin();
    fltrNotification?.initialize(initilizationsSettings,
        onSelectNotification: (payload) => onSelectNotification(payload));

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      log('Message data: ${message.data}');

      if (message.notification != null) {
        if (message.data["not_type"] ==
                "App\\Notifications\\NotifyUserForMoneyRequest" ||
            message.data["not_type"] ==
                "App\\Notifications\\NotifyUserForAcceptedMoneyRequest" ||
            message.data["not_type"] ==
                "App\\Notifications\\NotifyUserForExpiredMoneyRequest") {
          homePageStateKey.currentState!.refresh();
        }
        if (message.data["not_type"] ==
            "App\\Notifications\\NotifyUsersForFinishMoneyRequest") {
          homePageStateKey.currentState!.refreshIsOpen();
        }
        homePageStateKey.currentState!.unreadNotification(
            sl<HomesettingsBloc>().settings?.unreadNotifications ?? 0 + 1);

        _showNotification(message.data['title'], message.data['title'],
            message.data['id'], message.data['image'], message.data['name']);
      }
    });
    await FirebaseMessaging.onMessageOpenedApp.listen((event) {
      print("hanlde message" + (event.data.toString()));
      handleFCMNotification(event.data, false, context);
    });

    await FirebaseMessaging.instance.getInitialMessage().then((value) {
      if (value != null) {
        print("hanlde message" + (value.data.toString()));
        handleFCMNotification(value.data, true, context);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // deviceLanguageCode = Platform.localeName.split('_')[0];
    // if (deviceLanguageCode!.toLowerCase() == 'en' ||
    //     deviceLanguageCode!.toLowerCase() == 'ar' ||
    //     deviceLanguageCode!.toLowerCase() == 'tr') {
    //   backUpLanguageCode = deviceLanguageCode;
    // }
    // else {
    backUpLanguageCode = App.defaultLanguage;
    // }
    sl<PrefsHelper>().loadLangFromSharedPref().then((lang) {
      setState(() {
        locale = Locale(lang ?? backUpLanguageCode);
      });
    });
    initFirebaseMessaging();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      restorationScopeId: 'app',
      onGenerateRoute: AppRouter.generateRoute,
      theme: ThemeData(
          fontFamily: locale?.languageCode == "ar" ? "Almaria" : null,
          primarySwatch: AppStyle.primaryMaterial,
          primaryColor: AppStyle.primaryColor,
          textSelectionTheme:
              TextSelectionThemeData(cursorColor: AppStyle.primaryColor)),
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: this.locale,
      supportedLocales: [Locale("ar"), Locale("en"), Locale("tr")],
      builder: (context, child) {
        return ConnectivityBuilder(
            connectedCallback: () {
              if (AppRouter.currentRoute == "/")
                sl<AuthBloc>().add(InitToken(isAfterLogout: false));
            },
            noInternetString: S.of(context).noInternet,
            tryAgainString: S.of(context).tryAgain,
            child: Directionality(
                textDirection: locale!.languageCode != "ar"
                    ? TextDirection.ltr
                    : TextDirection.rtl,
                child: child!));
      },
      initialRoute: "/",
      home: SplashPage(),
    );
  }
}

void handleFCMNotification(
    Map<String, dynamic> message, bool isLaunch, BuildContext context) {
  Timer.periodic(Duration(seconds: 1), (timer) async {
    print(AppRouter.currentRoute);
    if (AppRouter.currentRoute != "/") {
      timer.cancel();

      await Navigator.pushNamed(context, "/notifications");
    }
  });
}
