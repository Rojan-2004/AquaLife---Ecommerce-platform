import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aqua_life/features/onboarding/presentation/view_model/onboarding_view_model.dart';
import 'package:aqua_life/app/theme/app_colors.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      "icon": Icons.water_drop,
      "title": "Discover Aquatic Life",
      "description": "Explore a vast collection of fish, plants, and aquarium supplies. Find everything you need for your underwater world.",
    },
    {
      "icon": Icons.explore_outlined,
      "title": "Aquarium Community",
      "description": "Connect with fellow aquarists, share photos, get expert advice, and join aquarium enthusiast communities worldwide.",
    },
    {
      "icon": Icons.shopping_cart_outlined,
      "title": "Shop & Care Guide",
      "description": "Access curated aquariums, equipment, and maintenance guides to keep your aquatic pets thriving.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: cs.surface,
                            border: Border.all(color: cs.primary.withValues(alpha: 0.5), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: cs.primary.withValues(alpha: 0.4),
                                blurRadius: 50,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                _onboardingData[index]["icon"] as IconData,
                                size: 100,
                                color: cs.primary,
                              ),
                              Positioned(
                                top: 40,
                                right: 50,
                                child: Icon(
                                  Icons.bubble_chart,
                                  size: 30,
                                  color: cs.outline,
                                ),
                              ),
                              Positioned(
                                bottom: 50,
                                left: 40,
                                child: Icon(
                                  Icons.bubble_chart,
                                  size: 20,
                                  color: cs.outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 60),
                        Text(
                          _onboardingData[index]["title"]!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _onboardingData[index]["description"]!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: cs.onSurface.withValues(alpha: 0.72),
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _onboardingData.length,
                (index) => buildDot(index, context),
              ),
            ),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   TextButton(
                     onPressed: () {
                       ref.read(onboardingViewModelProvider.notifier).completeOnboarding(context);
                     },
                     child: Text(
                       "Skip",
                       style: TextStyle(color: cs.onSurface.withValues(alpha: 0.72), fontSize: 16),
                     ),
                   ),
                   ElevatedButton(
                     style: ElevatedButton.styleFrom(
                       backgroundColor: cs.tertiary,
                       foregroundColor: cs.primary,
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(12),
                         side: BorderSide(color: cs.outline),
                       ),
                       padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
                     ),
                    onPressed: () {
                      if (_currentPage == _onboardingData.length - 1) {
                        ref.read(onboardingViewModelProvider.notifier).completeOnboarding(context);
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      }
                    },
                    child: Text(
                      _currentPage == _onboardingData.length - 1 ? "Get Started" : "Next",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget buildDot(int index, BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 10,
      width: _currentPage == index ? 30 : 10,
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: _currentPage == index ? cs.primary : cs.outline,
        boxShadow: [
          if (_currentPage == index)
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.5),
              blurRadius: 10,
            ),
        ],
      ),
    );
  }
}