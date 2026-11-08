import 'dart:io';
import 'package:dio/dio.dart';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:progiom_cms/auth.dart';
import 'package:progiom_cms/core.dart';
import './/Utils/AppSnackBar.dart';
import './/Utils/SizeConfig.dart';
import './/Utils/Style.dart';
import './/data/repository/Repository.dart';
import './/generated/l10n.dart';
import './/injections.dart';

class BalanceWithdrawal extends StatefulWidget {
  BalanceWithdrawal({Key? key}) : super(key: key);

  @override
  _BalanceWithdrawalState createState() => _BalanceWithdrawalState();
}

List<String> banksDrRequest = [];
Data? bankRequest;
List<Data> banksRequest = [];

class _BalanceWithdrawalState extends State<BalanceWithdrawal>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isSignUp = false;
  final TextEditingController amountRequiredController =
      TextEditingController();
  final TextEditingController accountOwnerController = TextEditingController();
  final TextEditingController iBANController = TextEditingController();
  bool isLoadingWithDateBank = false;
  bool isLoading = false;

  @override
  void initState() {
    getBank();
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
                    S.of(context).Balance_withdrawal,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            isLoadingWithDateBank
                ? Container(
                    height: SizeConfig.h(650),
                    width: 50,
                    child: Center(
                        child: CircularProgressIndicator(
                            color: AppStyle.primaryColor)))
                : Padding(
                    padding: EdgeInsets.symmetric(horizontal: SizeConfig.h(24)),
                    child: SizedBox(
                      height: SizeConfig.h(650),
                      child: Column(
                        children: [
                          SizedBox(
                            height: SizeConfig.h(120),
                          ),
                          buildSignUpDialoge(),
                          SizedBox(
                            height: SizeConfig.h(35),
                          ),
                          isLoading
                              ? Container(
                                  width: 50,
                                  child: Center(
                                      child: CircularProgressIndicator(
                                          color: AppStyle.primaryColor)))
                              : Align(
                                  alignment: Alignment.bottomCenter,
                                  child: GestureDetector(
                                    onTap: isLoading
                                        ? () {}
                                        : () {
                                            FocusScope.of(context).unfocus();

                                            if (formKey.currentState
                                                    ?.validate() ??
                                                false) {
                                              withdrawals();
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
                                                S.of(context).sendRequest,
                                                style: AppStyle.vexa14.copyWith(
                                                    color: AppStyle.whiteColor),
                                              ),
                                            ),
                                          ),
                                        )),
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

  getBank() async {
    banksRequest = [];
    banksDrRequest = [];
    bankRequest = Data();
    setState(() {
      isLoadingWithDateBank = true;
    });
    try {
      var request = await sl<Dio>().get("api/banks");
      setState(() {
        isLoadingWithDateBank = false;
        banksRequest = getBankModel.fromJson(request.data).data ?? [];
        banksRequest.forEach((element) {
          banksDrRequest.add(element.title ?? "");
        });
        bankRequest = banksRequest[0];
      });
    } on DioError catch (e) {
      var error =
          (e.response?.data['errors'] as Map).values.first?.first.toString();
      AppSnackBar.show(context, error!, ToastType.Error);
      setState(() {
        isLoadingWithDateBank = false;
      });
    } catch (e) {
      AppSnackBar.show(context, e.toString(), ToastType.Error);
      setState(() {
        isLoadingWithDateBank = false;
      });
    }
  }

  withdrawals() async {
    try {
      setState(() {
        isLoading = true;
      });
      await sl<Dio>().post("api/withdrawals", data: {
        "amount": int.parse(amountRequiredController.text),
        "account_owner_name": accountOwnerController.text,
        "iban": iBANController.text,
        "bank_id": bankRequest?.id ?? 0,
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

  Widget buildSignUpDialoge() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: [
          SizedBox(
            height: SizeConfig.h(4),
          ),
          buildTextField(
            S.of(context).amountRequired,
            amountRequiredController,
            validator: (v) {
              if (v != null && v.isEmpty)
                return S.of(context).Validator +
                    ' ' +
                    S.of(context).amountRequired;
              return null;
            },
          ),
          SizedBox(
            height: SizeConfig.h(15),
          ),
          buildTextField(S.of(context).accountOwner, accountOwnerController,
              isNum: true, validator: (v) {
            if (v != null && v.isEmpty)
              return S.of(context).Validator + ' ' + S.of(context).accountOwner;
            return null;
          }),
          SizedBox(
            height: SizeConfig.h(15),
          ),
          Container(
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
              padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(15)),
              child: DropdownBank(),
            ),
          ),
          SizedBox(
            height: SizeConfig.h(15),
          ),
          buildTextField(S.of(context).IBAN, iBANController, validator: (v) {
            if (v != null && v.isEmpty)
              return S.of(context).Validator + ' ' + S.of(context).IBAN;
            return null;
          }),
          SizedBox(
            height: SizeConfig.h(15),
          ),
        ],
      ),
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
            labelStyle:
                TextStyle(fontSize: SizeConfig.h(14), fontFamily: "Almaria"),
            errorStyle: TextStyle(fontSize: SizeConfig.h(14)),
            filled: true,
            fillColor: Colors.white),
      ),
    );
  }
}

class DropdownBank extends StatefulWidget {
  const DropdownBank();

  @override
  State<DropdownBank> createState() => _DropdownBankState();
}

class _DropdownBankState extends State<DropdownBank> {
  String dropdownValue = banksDrRequest.first;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: Padding(
        padding: EdgeInsets.only(left: SizeConfig.w(225)),
        child: const Icon(
          Icons.arrow_drop_down,
          size: 35,
        ),
      ),
      elevation: 16,
      style: TextStyle(
        color: Color.fromARGB(255, 101, 101, 101),
        fontSize: SizeConfig.h(18),
        fontWeight: FontWeight.w500,
      ),
      onChanged: (String? value) {
        setState(() {
          bankRequest =
              banksRequest.where((element) => element.title == value) as Data;
          dropdownValue = value!;
        });
      },
      items: banksDrRequest.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}

class getBankModel {
  List<Data>? data;

  getBankModel({this.data});

  getBankModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? title;

  Data({this.id, this.title});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    return data;
  }
}
