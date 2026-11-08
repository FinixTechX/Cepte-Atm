import 'package:flutter/material.dart';
import 'package:progiom_cms/auth.dart';
import '../../data/repository/Repository.dart';
import '/Utils/AppSnackBar.dart';
import '/Utils/SizeConfig.dart';
import '/Utils/Style.dart';
import '/generated/l10n.dart';
import 'package:dio/dio.dart';
import 'package:pinput/pinput.dart';
import '../../../injections.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OtpLoginPage extends StatefulWidget {
  Map<String, dynamic> data;
  OtpLoginPage({Key? key, required this.data}) : super(key: key);

  @override
  _OtpLoginPageState createState() => _OtpLoginPageState();
}

AnimationController? _controller;

class _OtpLoginPageState extends State<OtpLoginPage>
    with TickerProviderStateMixin {
  bool isLoading = false;

  final TextEditingController code = TextEditingController();
  Map<String, dynamic> data = {};
  int levelClock = 60;

  @override
  void initState() {
    data = widget.data;
    _controller = AnimationController(
        vsync: this, duration: Duration(seconds: levelClock));
    Future.delayed(const Duration(milliseconds: 50), () {
      _controller!.forward();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
          child: Stack(
            children: [
              Positioned(
                top: SizeConfig.h(200),
                left: SizeConfig.w(20),
                right: SizeConfig.w(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      S.of(context).validation_code,
                      textAlign: TextAlign.center,
                      style: AppStyle.welcome20.copyWith(
                          fontFamily: "Almaria",
                          fontWeight: FontWeight.bold,
                          fontSize: SizeConfig.h(20),
                          color: Colors.black),
                    ),
                    SizedBox(
                      height: SizeConfig.h(27),
                    ),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                            text: S.of(context).validation_code2 + "   ",
                            style: TextStyle(
                              fontSize: SizeConfig.h(14),
                              color: Colors.black,
                              fontFamily: "Almaria",
                            ),
                            children: [
                              TextSpan(
                                  text: "00",
                                  style: TextStyle(
                                      fontSize: SizeConfig.h(14),
                                      color: AppStyle.primaryColor)),
                              TextSpan(
                                  text: (widget.data['countryCode']
                                      .toString()
                                      .substring(1)),
                                  style: TextStyle(
                                      fontSize: SizeConfig.h(14),
                                      color: AppStyle.primaryColor)),
                              TextSpan(
                                  text: widget.data['mobile'],
                                  style: TextStyle(
                                      fontSize: SizeConfig.h(14),
                                      color: AppStyle.primaryColor)),
                            ]),
                      ),
                    ),
                    SizedBox(
                      height: SizeConfig.h(53),
                    ),
                    Container(
                        child: Column(children: [
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Row(
                          children: [
                            Expanded(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Pinput(
                                      length: 4,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      errorPinTheme: PinTheme(
                                        height: 60.0,
                                        width: 60.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Colors.red,
                                            width: 1.0,
                                          ),
                                        ),
                                      ),
                                      submittedPinTheme: PinTheme(
                                        height: 60.0,
                                        width: 60.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Colors.black,
                                            width: 1.0,
                                          ),
                                        ),
                                      ),
                                      disabledPinTheme: PinTheme(
                                        height: 60.0,
                                        width: 60.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Colors.black,
                                            width: 1.0,
                                          ),
                                        ),
                                      ),
                                      defaultPinTheme: PinTheme(
                                        height: 60.0,
                                        width: 60.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Colors.black,
                                            width: 1.0,
                                          ),
                                        ),
                                      ),
                                      focusedPinTheme: PinTheme(
                                        height: 60.0,
                                        width: 60.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Colors.red,
                                            width: 1.0,
                                          ),
                                        ),
                                      ),
                                      followingPinTheme: PinTheme(
                                        height: 60.0,
                                        width: 60.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Colors.black,
                                            width: 1.0,
                                          ),
                                        ),
                                      ),
                                      controller: code,
                                      validator: (v) {
                                        print(v);
                                        if (v!.length != 4) {
                                          return S.of(context).validation_code2;
                                        } else {
                                          return null;
                                        }
                                      },
                                      errorTextStyle: TextStyle(
                                          fontSize: 12, color: Colors.red),
                                    ),
                                  ),
                                ),
                              ],
                            ))
                          ],
                        ),
                      ),
                    ])),
                    SizedBox(
                      height: SizeConfig.h(42),
                    ),
                    BlocConsumer(
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
                            Navigator.pushNamedAndRemoveUntil(context, '/base',
                                (Route<dynamic> route) => false);
                          }
                          if (state is SignUpSuccess) {
                            sl<Repository>().setFcmToken();
                            Navigator.pushNamedAndRemoveUntil(context, '/base',
                                (Route<dynamic> route) => false);
                          }
                        },
                        builder: (context, state) {
                          if (state is LoadingLogin || state is LoadingSignUp)
                            return Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                  width: 50,
                                  child: Center(
                                      child: CircularProgressIndicator(
                                          color: AppStyle.primaryColor))),
                            );
                          return isLoading
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
                                      onTap: () async {
                                        FocusScope.of(context).unfocus();
                                        if (formKey.currentState?.validate() ??
                                            false) {
                                          bool val = await validationCode();
                                          if (val) {
                                            sl<AuthBloc>().add(LoginEvent(
                                                phone: widget.data["mobile"],
                                                otpCode: code.text,
                                                countryCode: widget
                                                    .data['countryCode']));
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
                                            child: Center(
                                              child: Text(
                                                S.of(context).continuee,
                                                style: AppStyle.vexa14.copyWith(
                                                    color: AppStyle.whiteColor),
                                              ),
                                            ),
                                          ))));
                        }),
                    SizedBox(
                      height: SizeConfig.h(16),
                    ),
                    Center(
                        child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        S.of(context).change_number,
                        style: TextStyle(
                            color: AppStyle.primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
                    Countdown(
                      animation: StepTween(
                        begin: levelClock, // THIS IS A USER ENTERED NUMBER
                        end: 0,
                      ).animate(_controller!),
                      mobile: data['mobile'],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> validationCode() async {
    setState(() {
      isLoading = true;
    });
    try {
      await sl<Dio>().get(
          "api/otp/check-code?mobile=${widget.data['mobile']}&code=${code.text}");
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

class Countdown extends AnimatedWidget {
  Countdown({required this.animation, required this.mobile})
      : super(listenable: animation);
  Animation<int> animation;
  var mobile;
  @override
  build(BuildContext context) {
    Duration clockTimer = Duration(seconds: animation.value);

    String timerText =
        '${clockTimer.inMinutes.remainder(60).toString()}:${clockTimer.inSeconds.remainder(60).toString().padLeft(2, '0')}';

    return Column(
      children: [
        SizedBox(
          height: SizeConfig.h(42),
        ),
        Container(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "$timerText",
                style: AppStyle.vexa14.copyWith(
                    fontWeight: FontWeight.w700, color: AppStyle.redColor),
              ),
              TextButton(
                  onPressed: () async {
                    if (animation.isCompleted) {
                      try {
                        await sl<Dio>().get(
                          "api/otp/send-code?mobile=${mobile}",
                        );

                        _controller!.reset();
                        _controller!.forward();
                      } on DioError catch (e) {
                        if (e.response!.statusCode == 403) {
                          _controller!.reset();
                          _controller!.forward();
                        } else {
                          AppSnackBar.show(
                              context,
                              (e.response?.data["error"]["message"]) ?? (e),
                              ToastType.Error);
                        }
                      } catch (e) {
                        AppSnackBar.show(
                            context, e.toString(), ToastType.Error);
                      }
                    }
                  },
                  child: Text(
                    S.of(context).resend_code,
                    style: animation.isCompleted
                        ? AppStyle.vexa14.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppStyle.primaryColor)
                        : AppStyle.vexa14.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppStyle.greyColor),
                  ))
            ],
          ),
        ),
      ],
    );
  }
}
