import 'package:flutter/material.dart';

class DashboardState {
  final int currentIndex;
  final List<Widget> pages;

  const DashboardState({
    required this.currentIndex,
    required this.pages,
  });

  factory DashboardState.initial() {
    return const DashboardState(
      currentIndex: 0,
      pages: [],
    );
  }

  DashboardState copyWith({
    int? currentIndex,
    List<Widget>? pages,
  }) {
    return DashboardState(
      currentIndex: currentIndex ?? this.currentIndex,
      pages: pages ?? this.pages,
    );
  }
}
