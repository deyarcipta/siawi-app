import 'package:flutter/material.dart';
import 'package:siawi_app/app/models/menu_item.dart';

class MenuItems {
  // static const List<MenuKu> itemFirst = [itemSettings, itemShare];
  static const List<MenuKu> itemFirst = [itemLogout];

  static const itemLogout = MenuKu(
    text: 'Logout',
    icon: Icons.logout,
  );

  static const List<MenuKu> itemSecond = [itemPassword];

  static const itemPassword = MenuKu(
    text: 'Ubah Password',
    icon: Icons.password,
  );
}
