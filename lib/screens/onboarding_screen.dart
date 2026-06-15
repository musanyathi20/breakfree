import 'package:flutter/material.dart';
import 'package:breakfree/services/simple_storage.dart';
import 'package:breakfree/utils/constants.dart';
import 'package:breakfree/themes/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final TextEditingController _nameController = TextEditingController();

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Welcome to BreakFree',
      description:
          'Your personal companion to break bad habits and build a better life.',
      icon: Icons.celebration,
      color: AppTheme.deepPurple,
    ),
    OnboardingData(
      title: 'Track Your Habits',
      description:
          'Add habits you want to quit, track your progress, and watch your streaks grow.',
      icon: Icons.track_changes,
      color: AppTheme.purpleAccent,
    ),
    OnboardingData(
      title: 'Save Money',
      description:
          'See how much you\'re saving in Rands every day, week, and month.',
      icon: Icons.savings,
      color: Colors.green,
    ),
    OnboardingData(
      title: 'Stay Motivated',
      description:
          'Get daily motivation, track your achievements, and celebrate your wins!',
      icon: Icons.emoji_events,
      color: Colors.orange,
    ),
    OnboardingData(
      title: 'What\'s Your Name?',
      description: 'Personalize your experience',
      icon: Icons.person,
      color: AppTheme.deepPurple,
      isNameScreen: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.deepPurple,
              AppTheme.purpleAccent,
            ],
          ),
        ),
        child: SafeArea(
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
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return OnboardingPage(
                      data: page,
                      nameController: _nameController,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => _completeOnboarding(),
                      child: const Text(
                        'Skip',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    Row(
                      children: List.generate(
                        _pages.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == index
                                ? Colors.white
                                : Colors.white38,
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_currentPage == _pages.length - 1) {
                          _completeOnboarding();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'Get Started'
                            : 'Next',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _completeOnboarding() async {
    String userName = _nameController.text.trim();
    if (userName.isEmpty) {
      userName = 'Friend';
    }

    await SimpleStorage.saveString(AppConstants.userNameKey, userName);
    await SimpleStorage.saveBool(AppConstants.hasSeenOnboardingKey, true);

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isNameScreen;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isNameScreen = false,
  });
}

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;
  final TextEditingController? nameController;

  const OnboardingPage({
    super.key,
    required this.data,
    this.nameController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              data.icon,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            data.description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          if (data.isNameScreen) ...[
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: nameController,
                style: const TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  prefixIcon:
                      const Icon(Icons.person, color: AppTheme.deepPurple),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
