import 'dart:io';
import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:progiom_cms/auth.dart';
import './/Utils/AppSnackBar.dart';
import './/Utils/SizeConfig.dart';
import './/Utils/Style.dart';
import './/data/repository/Repository.dart';
import './/generated/l10n.dart';
import './/injections.dart';
import 'package:CepteATM/Utils/Style.dart';
import 'package:CepteATM/generated/l10n.dart';
import 'package:flutter_credit_card/credit_card_brand.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

class DepositBalance extends StatefulWidget {
  DepositBalance({Key? key}) : super(key: key);

  @override
  _DepositBalanceState createState() => _DepositBalanceState();
}

class _DepositBalanceState extends State<DepositBalance>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> formKey2 = GlobalKey<FormState>();

  bool isSignUp = false;
  final TextEditingController amountRequiredController =
      TextEditingController();
  final TextEditingController accountOwnerController = TextEditingController();
  final TextEditingController card_numberController = TextEditingController();
  final TextEditingController Expiry_dateController = TextEditingController();
  final TextEditingController secret_codeController = TextEditingController();

  @override
  void initState() {
    border = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey.withOpacity(0.7),
        width: 2.0,
      ),
    );
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
              height: SizeConfig.h(32),
            ),
            Container(
              child: Padding(
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
                      S.of(context).DepositBalance,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: SizeConfig.h(12)),
              child: SizedBox(
                height: SizeConfig.h(730),
                child: Column(
                  children: [
                    buildSignUpDialoge(),
                    SizedBox(
                      height: SizeConfig.h(4),
                    ),
                    isLoading
                        ? Container(
                            width: 50,
                            child: Center(
                                child: CircularProgressIndicator(
                                    color: AppStyle.primaryColor)))
                        : Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: GestureDetector(
                                onTap: isLoading
                                    ? () {}
                                    : () {
                                        FocusScope.of(context).unfocus();

                                        if (formKey.currentState?.validate() ??
                                            false) {
                                          if (formKey2.currentState
                                                  ?.validate() ??
                                              false) {
                                            deposits();
                                          }
                                        } else if ((formKey2.currentState
                                                ?.validate() ??
                                            false)) {}
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
                                            S.of(context).balance_deposit,
                                            style: AppStyle.vexa14.copyWith(
                                                color: AppStyle.whiteColor),
                                          ),
                                        ),
                                      ),
                                    )),
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
  deposits() async {
    try {
      setState(() {
        isLoading = true;
      });
      await sl<Dio>().post("api/deposits", data: {
        "amount": int.parse(amountRequiredController.text),
        "account_owner_name": accountOwnerController.text,
        "card_number": card_numberController.text,
        "expire_date": Expiry_dateController.text,
        "secret_code": secret_codeController.text,
        "currency_id": 1
      });
      setState(() {
        isLoading = false;
      });
      Navigator.pop(context, "true");
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

  void onCreditCardModelChange(CreditCardModel? creditCardModel) {
    setState(() {
      card_numberController.text = creditCardModel!.cardNumber;
      Expiry_dateController.text = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      secret_codeController.text = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

  String cardHolderName = '';
  bool isCvvFocused = false;
  bool useGlassMorphism = false;
  bool useBackgroundImage = false;
  OutlineInputBorder? border;
  Widget buildSignUpDialoge() {
    return Column(
      children: [
        Directionality(
          textDirection: TextDirection.ltr,
          child: CreditCardWidget(
            glassmorphismConfig:
                useGlassMorphism ? Glassmorphism.defaultConfig() : null,
            cardNumber: card_numberController.text,
            expiryDate: Expiry_dateController.text,
            cardHolderName: cardHolderName,
            cvvCode: secret_codeController.text,
            bankName: S.of(context).bank,
            frontCardBorder:
                !useGlassMorphism ? Border.all(color: Colors.grey) : null,
            backCardBorder:
                !useGlassMorphism ? Border.all(color: Colors.grey) : null,
            showBackView: isCvvFocused,
            obscureCardNumber: true,
            obscureCardCvv: true,
            isHolderNameVisible: true,
            cardBgColor: AppStyle.primaryColor,
            backgroundImage: useBackgroundImage ? 'assets/card_bg.png' : null,
            isSwipeGestureEnabled: true,
            onCreditCardWidgetChange: (CreditCardBrand creditCardBrand) {},
            customCardTypeIcons: <CustomCardTypeIcon>[
              CustomCardTypeIcon(
                cardType: CardType.mastercard,
                cardImage: Image.asset(
                  'assets/mastercard.png',
                  height: 48,
                  width: 48,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: SizeConfig.h(20),
        ),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: buildTextField(
                S.of(context).amountRequired, amountRequiredController,
                isNum: true, validator: (v) {
              if (v != null && v.isEmpty)
                return S.of(context).Validator +
                    ' ' +
                    S.of(context).amountRequired;
              return null;
            }),
          ),
        ),
        SizedBox(
          height: SizeConfig.h(15),
        ),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: buildTextField(
                S.of(context).accountOwner, accountOwnerController,
                validator: (v) {
              if (v != null && v.isEmpty)
                return S.of(context).Validator +
                    ' ' +
                    S.of(context).accountOwner;
              return null;
            }),
          ),
        ),
        Directionality(
          textDirection: TextDirection.ltr,
          child: CreditCardForm(
            formKey: formKey2,
            obscureCvv: true,
            obscureNumber: false,
            cardNumber: card_numberController.text,
            cvvCode: secret_codeController.text,
            isHolderNameVisible: false,
            isCardNumberVisible: true,
            isExpiryDateVisible: true,
            cardHolderName: cardHolderName,
            expiryDate: Expiry_dateController.text,
            themeColor: AppStyle.greyColor,
            textColor: AppStyle.greyColor,
            cardNumberValidator: (String? value) {
              if (value!.isEmpty || value.length < 16) {
                return S.of(context).Validator +
                    ' ' +
                    S.of(context).card_number;
              }
              return null;
            },
            dateValidationMessage:
                S.of(context).Validator + ' ' + S.of(context).Expiry_date,
            cvvValidationMessage:
                S.of(context).Validator + ' ' + S.of(context).secret_code,
            cardNumberDecoration: InputDecoration(
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
                labelText: S.of(context).card_number,
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                labelStyle: TextStyle(
                  fontSize: SizeConfig.h(14),
                  fontFamily: "Almaria",
                ),
                errorStyle: TextStyle(fontSize: SizeConfig.h(14)),
                filled: true,
                fillColor: Colors.white),
            expiryDateDecoration: InputDecoration(
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
                labelText: S.of(context).Expiry_date,
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                labelStyle: TextStyle(
                  fontSize: SizeConfig.h(14),
                  fontFamily: "Almaria",
                ),
                errorStyle: TextStyle(fontSize: SizeConfig.h(14)),
                filled: true,
                fillColor: Colors.white),
            cvvCodeDecoration: InputDecoration(
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
                labelText: S.of(context).secret_code,
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                labelStyle: TextStyle(
                  fontSize: SizeConfig.h(14),
                  fontFamily: "Almaria",
                ),
                errorStyle: TextStyle(fontSize: SizeConfig.h(14)),
                filled: true,
                fillColor: Colors.white),
            onCreditCardModelChange: onCreditCardModelChange,
          ),
        ),
        SizedBox(
          height: SizeConfig.h(15),
        ),
      ],
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      {String? Function(String?)? validator, bool? obscureText, bool? isNum}) {
    return SizedBox(
      child: TextFormField(
        validator: validator,
        controller: controller,
        keyboardType: isNum ?? false ? TextInputType.number : null,
        obscureText: obscureText ?? false,
        inputFormatters: [
          !(isNum ?? false)
              ? LengthLimitingTextInputFormatter(50)
              : LengthLimitingTextInputFormatter(6),
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
              fontFamily: "Almaria",
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
