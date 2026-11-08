import 'package:flutter/material.dart';
import 'package:progiom_cms/auth.dart';
import 'package:progiom_cms/core.dart';
import 'package:progiom_cms/homeSettings.dart';
import '../../Utils/AppSnackBar.dart';
import '../../Utils/SizeConfig.dart';
import '../../Utils/Style.dart';
import 'package:badges/badges.dart';

import '../../injections.dart';
import 'LoginDialoge.dart';

final GlobalKey searchNavKey = GlobalKey();

class CustomAppBar extends StatefulWidget {
  const CustomAppBar({Key? key, required this.isCustom, this.child})
      : assert(isCustom ? child != null : true,
            "child is null while isCustom is true!");

  final bool isCustom;
  final Widget? child;

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  Map? preferences;
  getPreferences() async {
    final result = await GetPreferences(sl()).call(NoParams());
    result.fold((l) {
      AppSnackBar.show(context, l.errorMessage, ToastType.Error);
    }, (r) {
      if (mounted)
        setState(() {
          preferences = r;
        });
    });
  }

  @override
  void initState() {
    getPreferences();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var topPadding = MediaQuery.of(context).padding.top;
    var unreadNotifications =
        sl<HomesettingsBloc>().settings?.unreadNotifications ?? 0;
    return Container(
      padding: EdgeInsets.only(top: topPadding),
      width: double.infinity,
      height: SizeConfig.h(70 + topPadding),
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [AppStyle.secondaryDark, AppStyle.secondaryLight],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight)),
      child: !widget.isCustom
          ? Row(
              children: [
                unreadNotifications == 0
                    ? IconButton(
                        icon: Icon(
                          Icons.notifications,
                          color: AppStyle.primaryColor,
                          size: SizeConfig.h(24),
                        ),
                        onPressed: () {
                          if (sl<AuthBloc>().isGuest) {
                            showLoginDialoge(context);
                          } else {
                            unreadNotifications = 0;
                            sl<HomesettingsBloc>()
                                .settings
                                ?.unreadNotifications = 0;

                            Navigator.pushNamed(context, "/notifications");
                          }
                        })
                    : Badge(
                        position: BadgePosition.topStart(
                          start: SizeConfig.h(5),
                          top: SizeConfig.h(1),
                        ),
                        badgeContent: Text(
                          unreadNotifications.toString(),
                          style: TextStyle(
                              color: Colors.white, fontSize: SizeConfig.h(11)),
                        ),
                        child: IconButton(
                            icon: Icon(
                              Icons.notifications,
                              color: AppStyle.primaryColor,
                              size: SizeConfig.h(24),
                            ),
                            onPressed: () {
                              if (sl<AuthBloc>().isGuest) {
                                showLoginDialoge(context);
                              } else {
                                unreadNotifications = 0;
                                sl<HomesettingsBloc>()
                                    .settings
                                    ?.unreadNotifications = 0;

                                Navigator.pushNamed(context, "/notifications");
                              }
                            })),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Image.asset(
                    "assets/logo.png",
                    color: Colors.white,
                    width: SizeConfig.h(150),
                    height: SizeConfig.h(150),
                  ),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.all(11),
                  child: Row(
                    children: [
                      if (preferences != null)
                        GestureDetector(
                          onTap: () {
                            if (preferences != null)
                              openWhatsapp(preferences!["support_phone"]);
                          },
                          child: Image.asset(
                            "assets/whatsapp.png",
                            color: AppStyle.primaryColor,
                            height: SizeConfig.w(20),
                            width: SizeConfig.w(20),
                          ),
                        ),
                      SizedBox(width: 15),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, "/search");
                        },
                        child: Icon(
                          Icons.search,
                          color: AppStyle.primaryColor,
                          size: SizeConfig.w(20),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : widget.child,
    );
  }
}
