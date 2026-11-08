import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:progiom_cms/core.dart';
import './/Utils/AppSnackBar.dart';
import './/Utils/SizeConfig.dart';
import './/Utils/Style.dart';
import './/generated/l10n.dart';
import './/injections.dart';

import 'OtpLoginPage.dart';
import 'OtpSignupPage.dart';

class SignupPage extends StatefulWidget {
  SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isSignUp = false;
  late TabController _controller;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? countryCode = '';
  String? mobile = '';
  bool mobileVal = false;

  @override
  void initState() {
    _controller = TabController(length: 2, vsync: this);
    tapGestureRecognizer = TapGestureRecognizer()..onTap = _goToRegister;

    super.initState();
    _controller.addListener(() {
      if (_controller.indexIsChanging) {
        if (_controller.index == 0) {
          setState(() {
            isSignUp = false;
          });
        } else {
          setState(() {
            isSignUp = true;
          });
        }
      }
    });
  }

  TapGestureRecognizer? tapGestureRecognizer;

  void _goToRegister() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    tapGestureRecognizer?.dispose();

    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formKey,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/bg.png'),
              fit: BoxFit.fill,
            ),
          ),
          child: ListView(
            children: [
              SizedBox(
                height: SizeConfig.h(32),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: SizeConfig.h(24)),
                child: SizedBox(
                  height: SizeConfig.h(630),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Center(
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                    text: S.of(context).signupTitle + "\n",
                                    style: AppStyle.welcome20.copyWith(
                                        fontFamily: "Almaria",
                                        fontWeight: FontWeight.bold,
                                        fontSize: SizeConfig.h(20),
                                        color: Colors.black),
                                    children: [
                                      TextSpan(
                                          text: S.of(context).signupTitle2,
                                          style: TextStyle(
                                              fontSize: SizeConfig.h(14),
                                              color: Colors.black,
                                              fontWeight: FontWeight.w100))
                                    ]),
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: SizeConfig.h(35),
                      ),
                      buildLoginDialoge(),
                      isLoading
                          ? Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                  width: 50,
                                  child: Center(
                                      child: CircularProgressIndicator(
                                          color: AppStyle.primaryColor))),
                            )
                          : Align(
                              alignment: Alignment.bottomCenter,
                              child: GestureDetector(
                                onTap: isLoading
                                    ? () {}
                                    : () async {
                                        FocusScope.of(context).unfocus();
                                        if (formKey.currentState?.validate() ??
                                            false) {
                                          if (mobile != '' && mobile != null) {
                                            await sendCode();
                                          } else {
                                            setState(() {
                                              mobileVal = true;
                                            });
                                          }
                                        }
                                      },
                                child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          SizeConfig.h(5)),
                                      color: AppStyle.primaryColor,
                                    ),
                                    height: SizeConfig.h(50),
                                    width: SizeConfig.screenWidth,
                                    child: Container(
                                      height: SizeConfig.h(50),
                                      width: SizeConfig.screenWidth - 50,
                                      child: Container(
                                        child: Center(
                                          child: Text(
                                            S.of(context).continuee,
                                            style: AppStyle.vexa14.copyWith(
                                                color: AppStyle.whiteColor),
                                          ),
                                        ),
                                      ),
                                    )),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  _goToRegister();
                },
                child: Padding(
                  padding: EdgeInsets.only(top: SizeConfig.h(40)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                          text: TextSpan(
                              text: S.of(context).have_account,
                              style: TextStyle(
                                      color: Colors.black,
                                      fontSize: SizeConfig.h(14))
                                  .copyWith(fontFamily: "Almaria"),
                              children: [
                            TextSpan(
                                text: " " + S.of(context).login + " ",
                                style: TextStyle(
                                        color: AppStyle.primaryColor,
                                        fontWeight: FontWeight.bold)
                                    .copyWith(
                                        fontFamily: "Almaria",
                                        fontSize: SizeConfig.h(14)),
                                recognizer: tapGestureRecognizer),
                          ])),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Column buildLoginDialoge() {
    return Column(
      children: [
        SizedBox(
          height: SizeConfig.h(4),
        ),
        Stack(children: [
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: new BorderRadius.circular(8.0),
            ),
          ),
          Directionality(
            textDirection: TextDirection.ltr,
            child: IntlPhoneField(
              searchText: S.of(context).searchHere,
              initialCountryCode: 'TR',
              dropdownTextStyle: TextStyle(fontSize: SizeConfig.w(12)),
              style: TextStyle(fontSize: SizeConfig.w(12)),
              showCountryFlag: countryCode == '+963' ? false : true,
              onCountryChanged: (c) {
                setState(() {
                  countryCode = '+' + c.dialCode;
                });
              },
              onChanged: (PhoneNumber phoneNumber) {
                setState(() {
                  mobileVal = false;

                  countryCode = phoneNumber.countryCode;
                  mobile = phoneNumber.number;
                });
              },
              controller: phoneController,
              invalidNumberMessage: S.of(context).mobileValidator,
              validator: (v) {
                if (v != null) {
                  if (!validPhoneNumber(mobile)) {
                    return S.of(context).mobileValidator;
                  }
                }
                return null;
              },
              decoration: InputDecoration(
                  hintTextDirection: TextDirection.rtl,
                  alignLabelWithHint: true,
                  suffixIcon: Icon(
                    Icons.phone_android,
                    color: AppStyle.secondaryColor,
                  ),
                  labelText: S.of(context).phone_number,
                  contentPadding: EdgeInsets.symmetric(
                    // vertical: SizeConfig.h(2),
                    horizontal: SizeConfig.w(10),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                        width: 1,
                        style: BorderStyle.solid,
                        color: AppStyle.primaryColor),
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        width: 1,
                        style: BorderStyle.solid,
                        color: AppStyle.disabledColor),
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        width: 1,
                        style: BorderStyle.solid,
                        color: AppStyle.primaryColor),
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(5),
                    ),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  labelStyle: TextStyle(
                    fontSize: SizeConfig.h(14),
                  ),
                  errorStyle: TextStyle(fontSize: SizeConfig.h(14)),
                  fillColor: Colors.white70),
            ),
          ),
          if (mobileVal)
            Positioned(
              top: SizeConfig.h(55),
              left: 8,
              child: Text(
                S.of(context).mobileValidator,
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),
        ]),
        SizedBox(
          height: SizeConfig.h(15),
        ),
      ],
    );
  }

  Widget buildTextField(
      String label, IconData icon, TextEditingController controller,
      {String? Function(String?)? validator, bool? obscureText}) {
    return SizedBox(
      // height: SizeConfig.h(50),
      child: TextFormField(
        validator: validator,
        inputFormatters: [
          new LengthLimitingTextInputFormatter(4),
        ],
        controller: controller,
        keyboardType: TextInputType.number,
        obscureText: obscureText ?? false,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(
            vertical: SizeConfig.h(2),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(
                width: 1,
                style: BorderStyle.solid,
                color: AppStyle.primaryColor),
            borderRadius: const BorderRadius.all(
              const Radius.circular(5),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                width: 1,
                style: BorderStyle.solid,
                color: AppStyle.disabledColor),
            borderRadius: const BorderRadius.all(
              const Radius.circular(5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                width: 1,
                style: BorderStyle.solid,
                color: AppStyle.primaryColor),
            borderRadius: const BorderRadius.all(
              const Radius.circular(5),
            ),
          ),
          prefixIcon: Icon(
            icon,
            color: AppStyle.secondaryColor,
          ),
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          labelStyle: TextStyle(
            fontSize: SizeConfig.h(14),
          ),
          errorStyle: TextStyle(fontSize: SizeConfig.h(14)),
        ),
      ),
    );
  }

  bool isLoading = false;

  sendCode() async {
    try {
      setState(() {
        isLoading = true;
      });
      await sl<Dio>().get(
        "api/otp/send-code?mobile=${mobile!}",
      );
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => OtpSignupPage(
                  data: {"mobile": mobile, "countryCode": countryCode},
                )),
      );
    } on DioError catch (e) {
      setState(() {
        isLoading = false;
      });
      var error =
          (e.response?.data['errors'] as Map).values.first?.first.toString();
      AppSnackBar.show(context, error!, ToastType.Error);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      AppSnackBar.show(context, e.toString(), ToastType.Error);
    }
  }
}
