import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:progiom_cms/auth.dart';
import 'package:progiom_cms/core.dart';
import './/Utils/AppSnackBar.dart';
import './/Utils/SizeConfig.dart';
import './/Utils/Style.dart';
import './/data/repository/Repository.dart';
import './/generated/l10n.dart';
import './/injections.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ComplatSignup extends StatefulWidget {
  Map<String, dynamic> data;

  ComplatSignup({Key? key, required this.data}) : super(key: key);

  @override
  _ComplatSignupState createState() => _ComplatSignupState();
}

class _ComplatSignupState extends State<ComplatSignup>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isSignUp = false;
  final TextEditingController amountRequiredController =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formKey,
        child: ListView(
          children: [
            SizedBox(
              height: SizeConfig.h(150),
            ),
            Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                    text: S.of(context).complete_account + "\n",
                    style: AppStyle.welcome20.copyWith(
                        fontFamily: "Almaria",
                        fontWeight: FontWeight.bold,
                        fontSize: SizeConfig.h(20),
                        color: Colors.black),
                    children: [
                      TextSpan(
                          text: S.of(context).complete_account2,
                          style: TextStyle(
                              fontSize: SizeConfig.h(14),
                              color: Colors.black,
                              fontWeight: FontWeight.w100))
                    ]),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: SizeConfig.h(24)),
              child: SizedBox(
                height: SizeConfig.h(650),
                child: Column(
                  children: [
                    SizedBox(
                      height: SizeConfig.h(40),
                    ),
                    buildSignUpDialoge(),
                    SizedBox(
                      height: SizeConfig.h(120),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          if (formKey.currentState?.validate() ?? false) {
                            sl<AuthBloc>().add(SignUpEvent({
                              "name": nameController.text,
                              "email": emailController.text == ''
                                  ? null
                                  : emailController.text,
                              "country_code": widget.data['countryCode'],
                              "mobile": widget.data['mobile'],
                              "otpCode": widget.data['otp_code'],
                            }));
                          }
                        },
                        child: Container(
                          child: BlocConsumer(
                              bloc: sl<AuthBloc>(),
                              listener: (context, state) {
                                if (state is ErrorInLogin) {
                                  AppSnackBar.show(
                                      context,
                                      S.of(context).emailOrPasswordWrong,
                                      ToastType.Error);
                                }
                                if (state is ErrorSignUp) {
                                  AppSnackBar.show(
                                      context, state.error, ToastType.Error);
                                }
                                if (state is LoginSuccess) {
                                  sl<Repository>().setFcmToken();
                                  Navigator.pushNamedAndRemoveUntil(context,
                                      '/base', (Route<dynamic> route) => false);
                                }
                                if (state is SignUpSuccess) {
                                  sl<Repository>().setFcmToken();
                                  Navigator.pushNamedAndRemoveUntil(context,
                                      '/base', (Route<dynamic> route) => false);
                                }
                              },
                              builder: (context, state) {
                                if (state is LoadingLogin ||
                                    state is LoadingSignUp)
                                  return CircularProgressIndicator();
                                return Container(
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
                                            S.of(context).singup,
                                            style: AppStyle.vexa14.copyWith(
                                                color: AppStyle.whiteColor),
                                          ),
                                        ),
                                      ),
                                    ));
                              }),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.h(32),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  bool isLoading = false;
  validationCode() async {
    // try {
    //   setState(() {
    //     isLoading = true;
    //   });
    //   await sl<Dio>().get(
    //     "api/otp/send-code?mobile=${mobile!}",
    //   );
    //   setState(() {
    //     isLoading = false;
    //   });
    //   isDriver
    //       ? Navigator.of(context).push(
    //           MaterialPageRoute(
    //               builder: (context) => OtpDriverPage(
    //                     data: {
    //                       "name": nameController.text,
    //                       "email": null,
    //                       "country_code": countryCode,
    //                       "mobile": mobile,
    //                     },
    //                   )),
    //         )
    //       : Navigator.of(context).push(
    //           MaterialPageRoute(
    //               builder: (context) => OtpPage(
    //                     data: {
    //                       "name": nameController.text,
    //                       "email": null,
    //                       "country_code": countryCode,
    //                       "mobile": mobile,
    //                     },
    //                   )),
    //         );
    // } on DioError catch (e) {
    //   setState(() {
    //     isLoading = false;
    //   });
    //   var error =
    //       (e.response?.data['errors'] as Map).values.first?.first.toString();
    //   AppSnackBar.show(context, error!, ToastType.Error);
    // } catch (e) {
    //   setState(() {
    //     isLoading = false;
    //   });
    //   AppSnackBar.show(context, e.toString(), ToastType.Error);
    // }
  }

  Widget buildSignUpDialoge() {
    return Column(
      children: [
        SizedBox(
          height: SizeConfig.h(4),
        ),
        buildTextField(
            S.of(context).fullName, Icons.person_outline, nameController,
            validator: (v) {
          if (v != null && v.isEmpty) return S.of(context).nameRequired;
          return null;
        }),
        SizedBox(
          height: SizeConfig.h(15),
        ),
        buildTextField(
            S.of(context).e_mail, Icons.email_outlined, emailController,
            validator: (v) {
          if (v != null && v.isEmpty) {
            if (!validEmail(v) && v != '') {
              return S.of(context).emailValidator;
            }
          }
          if (v == '') {
            return S.of(context).emailValidator;
          }
          return null;
        }),
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
        controller: controller,
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
            prefixIcon: Icon(
              icon,
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

class AppleButton extends StatelessWidget {
  const AppleButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await sl<Repository>().logInByApple();
        result.fold((l) {
          AppSnackBar.show(context, l.errorMessage, ToastType.Error);
        }, (r) {
          sl<AuthBloc>().add(
              LoginSocialEvent(provider: SocialLoginProvider.apple, token: r));
        });
      },
      child: Container(
        width: SizeConfig.screenWidth * 0.6,
        height: SizeConfig.h(50),
        margin: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  offset: Offset(0.0, 3.0),
                  blurRadius: 6,
                  color: Colors.black.withOpacity(0.2)),
            ],
            borderRadius: BorderRadius.circular(SizeConfig.h(5))),
        child: Row(
          children: [
            Row(
              children: [
                SizedBox(
                  width: SizeConfig.h(17),
                ),
                Icon(FontAwesomeIcons.apple)
              ],
            ),
            SizedBox(
              width: SizeConfig.h(5),
            ),
            Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(S.of(context).sign_with_apple, style: AppStyle.vexa12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
