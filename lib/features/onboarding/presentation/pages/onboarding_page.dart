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
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
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
                            color: const Color(0xFF0D1F35),
                            border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.5), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryBlue.withValues(alpha: 0.4),
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
                                color: AppColors.primaryBlue,
                              ),
                              Positioned(
                                top: 40,
                                right: 50,
                                child: Icon(
                                  Icons.bubble_chart,
                                  size: 30,
                                  color: const Color(0xFF1E3A5C),
                                ),
                              ),
                              Positioned(
                                bottom: 50,
                                left: 40,
                                child: Icon(
                                  Icons.bubble_chart,
                                  size: 20,
                                  color: const Color(0xFF1E3A5C),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 60),
                        Text(
                          _onboardingData[index]["title"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _onboardingData[index]["description"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF7AB8CC),
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
                    child: const Text(
                      "Skip",
                      style: TextStyle(color: Color(0xFF7AB8CC), fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A3A5C),
                      foregroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFF1E3A5C)),
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 10,
      width: _currentPage == index ? 30 : 10,
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: _currentPage == index ? AppColors.primaryBlue : const Color(0xFF1E3A5C),
        boxShadow: [
          if (_currentPage == index)
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.5),
              blurRadius: 10,
            ),
        ],
      ),
    );
  }
}