import 'package:flutter/material.dart';

import '../../Utils/AppSnackBar.dart';
import '../../Utils/SizeConfig.dart';
import '../../Utils/Style.dart';
import '../../generated/l10n.dart';
import '../../injections.dart';
import 'package:dio/dio.dart';

class CommonQuestions extends StatefulWidget {
  @override
  _CommonQuestionsState createState() => _CommonQuestionsState();
}

class _CommonQuestionsState extends State<CommonQuestions> {
  bool isLoading = false;
  List<dynamic> data = [];
  List<ItemModel> itemData = <ItemModel>[];
  @override
  void initState() {
    getQu();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: SizeConfig.h(25),
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
                    S.of(context).commonQuestions,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            isLoading
                ? Container(
                    height: SizeConfig.h(650),
                    width: 50,
                    child: Center(
                        child: CircularProgressIndicator(
                            color: AppStyle.primaryColor)))
                : Expanded(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: ListView.builder(
                        itemCount: itemData.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: ExpansionPanelList(
                              animationDuration: Duration(milliseconds: 700),
                              elevation: 2,
                              children: [
                                ExpansionPanel(
                                  body: Container(
                                    padding: EdgeInsets.all(10),
                                    child: Text(
                                      itemData[index].discription,
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 15,
                                          letterSpacing: 0.3,
                                          height: 1.3),
                                    ),
                                  ),
                                  headerBuilder:
                                      (BuildContext context, bool isExpanded) {
                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          itemData[index].expanded =
                                              !itemData[index].expanded;
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        child: Text(
                                          itemData[index].headerItem,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    );
                                  },
                                  isExpanded: itemData[index].expanded,
                                )
                              ],
                              expansionCallback: (int item, bool status) {
                                setState(() {
                                  itemData[index].expanded =
                                      !itemData[index].expanded;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  getQu() async {
    setState(() {
      isLoading = true;
    });
    try {
      var request = await sl<Dio>().get("api/faqs");
      data = request.data["data"];
      data.forEach((element) {
        itemData.add(ItemModel(
            headerItem: element["title"], discription: element["description"]));
      });
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

class ItemModel {
  bool expanded;
  String headerItem;
  String discription;

  ItemModel({
    this.expanded: false,
    required this.headerItem,
    required this.discription,
  });
}
