import 'package:flutter/material.dart';
import 'package:aqua_life/features/catalogue/presentation/view/catalogue_screen.dart';

class PlantsScreen extends StatelessWidget {
  const PlantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CatalogueScreen(initialCategory: 'Plants');
  }
}
