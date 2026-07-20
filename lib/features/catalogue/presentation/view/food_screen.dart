import 'package:flutter/material.dart';
import 'package:aqua_life/features/catalogue/presentation/view/catalogue_screen.dart';

class FoodScreen extends StatelessWidget {
  const FoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CatalogueScreen(initialCategory: 'Food');
  }
}
