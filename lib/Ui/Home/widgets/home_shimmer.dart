import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '/App/Widgets/ShimmerProductCard.dart';
import './/Utils/SizeConfig.dart';

class HomePageShimmer extends StatelessWidget {
  const HomePageShimmer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: double.infinity,
            height: SizeConfig.h(100),
            color: Colors.grey,
          ),
        ),
        SizedBox(
          height: SizeConfig.h(23),
        ),
        Center(
          child: Container(
            height: SizeConfig.h(620),
            width: double.infinity,
            child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: SizeConfig.h(3)),
                scrollDirection: Axis.vertical,
                itemCount: 9,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: double.infinity,
                        height: SizeConfig.h(100),
                        color: Colors.grey,
                      ),
                    ),
                  );
                }),
          ),
        ),
      ],
    );
  }
}
