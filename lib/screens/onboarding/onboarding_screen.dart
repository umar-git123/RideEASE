import 'package:flutter/material.dart';
import '../auth/login_screen.dart';
import '../../widgets/custom_button.dart';
import '../../core/theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Book a Ride',
      'description': 'Request a ride instantly and get picked up by a nearby driver.',
      'icon': Icons.local_taxi_rounded,
    },
    {
      'title': 'Drive & Earn',
      'description': 'Register as a driver to start earning money on your own schedule.',
      'icon': Icons.attach_money_rounded,
    },
    {
      'title': 'Track in Real Time',
      'description': 'Watch your driver arrive in real-time on the map.',
      'icon': Icons.map_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final bool isLandscape = size.height < size.width;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Page View with scrolling items
            Positioned.fill(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final bool isSmallHeight = constraints.maxHeight < 400;
                      
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: constraints.maxHeight),
                          child: IntrinsicHeight(
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: 32, 
                                right: 32, 
                                top: isSmallHeight ? 60 : 80,
                                bottom: isSmallHeight ? 120 : 160,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(isSmallHeight ? 24 : 32),
                                    decoration: BoxDecoration(
                                      gradient: AppTheme.primaryGradient,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.primaryColor.withOpacity(0.5),
                                          blurRadius: isSmallHeight ? 30 : 50,
                                          spreadRadius: isSmallHeight ? 5 : 10,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      _pages[index]['icon'] as IconData,
                                      size: isSmallHeight ? 60 : 100,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: isSmallHeight ? 24 : 48),
                                  Text(
                                    _pages[index]['title']! as String,
                                    style: (isSmallHeight 
                                      ? theme.textTheme.headlineSmall 
                                      : theme.textTheme.headlineMedium)?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _pages[index]['description']! as String,
                                    textAlign: TextAlign.center,
                                    style: (isSmallHeight 
                                      ? theme.textTheme.bodyMedium 
                                      : theme.textTheme.bodyLarge)?.copyWith(
                                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Removed Skip button from here as requested

            // Bottom controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 24, 
                  vertical: isLandscape ? 12 : 24
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.scaffoldBackgroundColor.withOpacity(0),
                      theme.scaffoldBackgroundColor.withOpacity(0.9),
                      theme.scaffoldBackgroundColor,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index 
                                ? theme.primaryColor 
                                : theme.disabledColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: isLandscape ? 16 : 32),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: CustomButton(
                        text: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                        onPressed: () {
                          if (_currentPage < _pages.length - 1) {
                            _controller.nextPage(
                              duration: const Duration(milliseconds: 300), 
                              curve: Curves.easeInOut
                            );
                          } else {
                            _goToLogin();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (_) => const LoginScreen())
    );
  }
}
