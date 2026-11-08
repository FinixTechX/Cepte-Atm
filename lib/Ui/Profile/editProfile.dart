import 'dart:io';
import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import '/App/Widgets/AppLoader.dart';
import '/Utils/AppSnackBar.dart';
import '/App/Widgets/MainButton.dart';
import '/Utils/SizeConfig.dart';
import '/Utils/Style.dart';
import 'package:image_picker/image_picker.dart';
import '/data/repository/Repository.dart';
import '/generated/l10n.dart';
import '/injections.dart';
import 'package:progiom_cms/auth.dart';
import 'package:progiom_cms/homeSettings.dart';

class EditProfilePage extends StatefulWidget {
  EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

PhoneNumber? phoneNumber;

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController nameController;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
        text: sl<HomesettingsBloc>().settings?.user?.name ?? "");
    if (sl<HomesettingsBloc>().settings?.user?.countryCode != null) {
      final countryCode = CountryPickerUtils.getCountryByPhoneCode(
              sl<HomesettingsBloc>()
                      .settings
                      ?.user
                      ?.countryCode
                      ?.substring(1) ??
                  '')
          .isoCode;
      // print('cc is ${cc.numeric}');
      phoneNumber = PhoneNumber(
          countryISOCode: countryCode,
          countryCode: sl<HomesettingsBloc>().settings?.user?.countryCode ?? '',
          number: sl<HomesettingsBloc>().settings?.user?.mobile ?? '');
    }
    phoneController.text =
        (sl<HomesettingsBloc>().settings?.user?.mobile == null
            ? ''
            : sl<HomesettingsBloc>().settings?.user?.mobile!)!;
  }

  @override
  Widget build(BuildContext context) {
    print(sl<HomesettingsBloc>().settings?.user?.countryCode);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            S.of(context).personalInfo,
            style: TextStyle(
                fontSize: SizeConfig.h(18),
                color: Colors.black,
                fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 0.0),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.h(28),
          ),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                SizedBox(
                  height: SizeConfig.h(40),
                ),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: SizeConfig.h(80),
                      foregroundImage: imageFileList != null
                          ? FileImage(File(imageFileList!.path))
                          : null,
                      backgroundImage:
                          (sl<HomesettingsBloc>().settings?.user?.coverImage !=
                                  null)
                              ? NetworkImage((sl<HomesettingsBloc>()
                                      .settings
                                      ?.user
                                      ?.coverImage) ??
                                  "")
                              : null,
                    ),
                    Positioned(
                      bottom: SizeConfig.h(25),
                      child: Container(
                        height: SizeConfig.h(35),
                        width: SizeConfig.h(35),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white),
                        child: IconButton(
                          onPressed: () {
                            _onImageButtonPressed(
                              ImageSource.gallery,
                              context: context,
                            );
                          },
                          icon: Icon(
                            Icons.add_a_photo_outlined,
                            color: AppStyle.primaryColor,
                            size: SizeConfig.h(21),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: SizeConfig.h(30),
                ),
                Row(
                  children: [
                    Expanded(
                        child: SizedBox(
                      height: SizeConfig.h(46),
                      child: TextFormField(
                        validator: (v) {
                          if (v != null) {
                            if (v.isEmpty) {
                              return S.of(context).nameRequired;
                            }
                          }
                          return null;
                        },
                        controller: nameController,
                        style: AppStyle.vexa14.copyWith(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: S.of(context).fullName,
                          labelStyle: TextStyle(
                            fontSize: SizeConfig.h(18),
                            color: AppStyle.greyColor,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 1,
                                style: BorderStyle.solid,
                                color: AppStyle.greyColor),
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(4),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 1,
                                style: BorderStyle.solid,
                                color: AppStyle.disabledColor),
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(4),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 1,
                                style: BorderStyle.solid,
                                color: AppStyle.greyColor),
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ))
                  ],
                ),
                SizedBox(
                  height: SizeConfig.h(20),
                ),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: IntlPhoneField(
                    enabled: false,
                    initialCountryCode: phoneNumber?.countryISOCode,
                    searchText: S.of(context).searchHere,
                    dropdownTextStyle: TextStyle(fontSize: SizeConfig.w(12)),
                    style: TextStyle(
                        fontSize: SizeConfig.w(12), height: SizeConfig.w(1.3)),
                    dropdownIcon: Icon(
                      Icons.arrow_drop_down,
                      color: AppStyle.greyColor,
                    ),
                    showCountryFlag:
                        phoneNumber?.countryCode == '+963' ? false : true,
                    flagsButtonPadding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.w(12),
                    ),
                    onCountryChanged: (c) {
                      setState(() {
                        phoneNumber?.countryCode = '+' + c.dialCode;
                      });
                    },
                    onChanged: (PhoneNumber phoneNum) {
                      setState(() {
                        phoneNumber = phoneNum;
                        print(phoneNum);
                      });
                    },
                    controller: phoneController,
                    invalidNumberMessage: S.of(context).mobileValidator,
                    decoration: InputDecoration(
                        hintTextDirection: TextDirection.rtl,
                        alignLabelWithHint: true,
                        suffixIcon: Icon(
                          Icons.phone_android,
                          color: AppStyle.greyColor,
                        ),
                        labelText: S.of(context).phone_number,
                        labelStyle: TextStyle(
                            fontSize: SizeConfig.h(18),
                            color: AppStyle.greyColor),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.w(12),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 1,
                              style: BorderStyle.solid,
                              color: AppStyle.greyColor),
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(4),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 1,
                              style: BorderStyle.solid,
                              color: AppStyle.disabledColor),
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(4),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 1,
                              style: BorderStyle.solid,
                              color: AppStyle.greyColor),
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(4),
                          ),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        errorStyle: TextStyle(fontSize: SizeConfig.h(14)),
                        fillColor: Colors.white70),
                  ),
                ),
                SizedBox(
                  height: SizeConfig.h(20),
                ),
                Row(
                  children: [
                    Expanded(
                        child: SizedBox(
                      height: SizeConfig.h(46),
                      child: TextFormField(
                        readOnly: true,
                        initialValue:
                            sl<HomesettingsBloc>().settings?.user?.email ?? "",
                        style: AppStyle.vexa14.copyWith(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: S.of(context).e_mail,
                          labelStyle: TextStyle(
                            fontSize: SizeConfig.h(18),
                            color: AppStyle.greyColor,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 1,
                                style: BorderStyle.solid,
                                color: AppStyle.greyColor),
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(4),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 1,
                                style: BorderStyle.solid,
                                color: AppStyle.disabledColor),
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(4),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 1,
                                style: BorderStyle.solid,
                                color: AppStyle.greyColor),
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ))
                  ],
                ),
                SizedBox(
                  height: SizeConfig.h(50),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLoading)
                      AppLoader()
                    else
                      Expanded(
                          child: MainButton(
                              height: SizeConfig.h(50),
                              isOutlined: false,
                              onTap: () {
                                if (formKey.currentState?.validate() ?? false) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  editData();
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    S.of(context).editProfile,
                                    style: AppStyle.vexa14.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ))),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  final ImagePicker _picker = ImagePicker();

  XFile? imageFileList;
  bool isLoading = false;
  Future<void> _onImageButtonPressed(ImageSource source,
      {BuildContext? context}) async {
    try {
      final XFile? pickedFileList = await _picker.pickImage(source: source);

      setState(() {
        if (pickedFileList != null) imageFileList = pickedFileList;
      });
    } catch (e) {}
  }

  editData() async {
    setState(() {
      isLoading = true;
    });
    var data;
    if (imageFileList == null) {
      data = {
        "name": nameController.text,
        "country_code": phoneNumber?.countryCode,
        "mobile": phoneController.text,
        "image[]": sl<HomesettingsBloc>().settings?.user?.coverImage,
        "bool": false
      };
    } else {
      data = {
        "name": nameController.text,
        "country_code": phoneNumber?.countryCode,
        "mobile": phoneController.text,
        "image[]": File(imageFileList!.path),
        "bool": true
      };
    }

    final result = await UpdateProfile(sl()).call(UpdateProfileParams(data));
    setState(() {
      isLoading = false;
    });
    result.fold((l) {
      AppSnackBar.show(context, l.errorMessage, ToastType.Error);
    }, (r) {
      sl<HomesettingsBloc>().add(GetSettings());
      sl<HomesettingsBloc>().settings?.user?.name = nameController.text;
      AppSnackBar.show(
          context, S.of(context).ProfileSuccessfully, ToastType.Success);
    });
  }
}
