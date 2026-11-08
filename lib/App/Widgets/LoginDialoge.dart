import 'package:flutter/material.dart';
import '/Utils/SizeConfig.dart';
import '/Utils/Style.dart';
import '/generated/l10n.dart';

showLoginDialoge(context) {
  showDialog(
      context: context,
      builder: (context) => Center(
            child: SizedBox(
              height: SizeConfig.h(275),
              width: SizeConfig.h(350),
              child: Material(
                borderRadius: BorderRadius.circular(15),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/logo.png",
                            height: SizeConfig.h(100),
                            width: SizeConfig.h(100),
                          ),
                        ],
                      ),
                      Spacer(flex: 1),
                      Text(
                        S.of(context).not_loggedin_content,
                        style: AppStyle.vexa20.copyWith(color: Colors.black),
                      ),
                      SizedBox(
                        height: SizeConfig.h(12),
                      ),
                      Text(
                        S.of(context).by_login_dialoge,
                        style:
                            AppStyle.vexa16.copyWith(color: AppStyle.greyColor),
                      ),
                      Spacer(
                        flex: 2,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                S.of(context).back,
                                style: AppStyle.vexa14
                                    .copyWith(color: AppStyle.greyColor),
                              )),
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pushNamed(context, "/login",
                                    arguments: true);
                              },
                              child: Text(
                                S.of(context).login,
                                style: AppStyle.vexa14
                                    .copyWith(color: Colors.black),
                              ))
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ));
}
