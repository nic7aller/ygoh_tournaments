import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

class BottomNavBar extends StatefulWidget {
  BottomNavBar({Key key, @required this.controller, @required this.index}) : super(key: key);
  final SwiperController controller;
  int index;

  @override
  BottomNavBarState createState() => new BottomNavBarState();
}

class BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          title: Text('Home'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group),
          title: Text('Members'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.casino),
          title: Text('Event Types'),
        ),

      ],
      currentIndex: widget.index,
      fixedColor: Colors.red[900],
      onTap: (index) {
        widget.controller.move(index);
      },
      type: BottomNavigationBarType.shifting, // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void updateIndex(int index) {
    setState(() {
      widget.index = index;
    });
  }
}