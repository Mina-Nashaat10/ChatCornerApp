import 'package:chat_corner/constants/colors.dart';
import 'package:chat_corner/constants/sizes.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class SliderPage extends StatelessWidget {
  late String image;
  late String title;
  late String description;
  SliderPage({
    Key? key,
    required this.image,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Column(
        children: [
          Image(
            image: AssetImage(
              this.image,
            ),
            fit: BoxFit.cover,
            height: ScreenSize.getHeightScreen(context) * 0.55,
            width: ScreenSize.getWidthtScreen(context) * 0.9,
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            this.title,
            style: TextStyle(
              fontSize: 20,
              color: MyColor.blueGrotto,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: Text(
              this.description,
              style: TextStyle(
                fontSize: 17,
                color: MyColor.navyBlue,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ),
          SizedBox(
            height: 40,
          ),
        ],
      ),
    );
  }
}
