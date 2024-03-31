import 'package:flutter/material.dart';
import 'package:siawi_app/app/models/menu_item.dart';

class MenuItems {
  // static const List<MenuKu> itemFirst = [itemSettings, itemShare];
  static const List<MenuKu> itemSecond = [itemLogout];

  // static const itemSettings = MenuKu(
  //   text: 'Profile',
  //   icon: Icons.person,
  // );

  // static const itemShare = MenuKu(
  //   text: 'Setting',
  //   icon: Icons.settings,
  // );

  static const itemLogout = MenuKu(
    text: 'Logout',
    icon: Icons.logout,
  );
}
