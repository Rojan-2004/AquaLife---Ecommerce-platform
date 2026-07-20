import 'package:flutter/material.dart';
import 'package:aqua_life/features/catalogue/presentation/view/catalogue_screen.dart';

class FishScreen extends StatelessWidget {
  const FishScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CatalogueScreen(initialCategory: 'Fish');
  }
}
