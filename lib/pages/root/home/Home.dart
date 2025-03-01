import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:tradingapp/pages/root/home/components/FlChart.dart';
import 'package:tradingapp/pages/root/home/components/HomeButtons.dart';
import 'package:tradingapp/pages/services/constants/constants.dart';
import 'package:tradingapp/theme/theme.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 10),
        children: [
          SizedBox(height: 25),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
            ),
             tileColor: Theme.of(context).listTileTheme.tileColor,
            leading: Icon(Icons.verified),
            title: Text("Apply for verification"),
            trailing: OutlinedButton(onPressed: (){}, child: Text("Apply", style: TextStyle(color: Theme.of(context).listTileTheme.leadingAndTrailingTextStyle!.color)),
          )),
          SizedBox(height: 10),
          Text("Metrics", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Homebuttons(onTap: (){}, icon: Icons.money_sharp, isActive: true, text: "Payments",),
              Homebuttons(onTap: (){}, icon: Icons.arrow_forward,  text: "Send",),
              Homebuttons(onTap: (){}, icon: Icons.people,  text: "Peers",),
              Homebuttons(onTap: (){}, icon: Icons.more_horiz_outlined, text: "More",)
            ],
          ),
          SizedBox(height: 10,),
          LineChartSample2()
        ],
      ),
      appBar: AppBar(title: Text(AppConstants.appName),centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Badge(
            child: Icon(Icons.notifications_none_outlined),
          ),
        )
      ]),
    );
  }
}
