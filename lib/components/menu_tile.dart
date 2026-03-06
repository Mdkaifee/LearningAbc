import 'package:flutter/material.dart';

import '../models/menu_module.dart';
import 'app_asset_image.dart';

class MenuTile extends StatelessWidget {
  const MenuTile({super.key, required this.module, required this.onTap});

  final MenuModule module;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0x29000000),
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: AppAssetImage(module.imageName, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
