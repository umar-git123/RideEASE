import 'package:flutter/material.dart';
import '../../core/theme.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  int _expandedIndex = -1;

  final List<FAQItem> _faqItems = [
    FAQItem(
      question: 'How do I request a ride?',
      answer: 'Tap on "Where to?" on the home screen, enter your destination, '
          'confirm your pickup location, and then tap "Request Ride". '
          'You\'ll be matched with a nearby driver.',
    ),
    FAQItem(
      question: 'How is the fare calculated?',
      answer: 'Fares are calculated based on distance, estimated time, '
          'current demand, and any applicable surge pricing. '
          'You\'ll see the estimated fare before confirming your ride.',
    ),
    FAQItem(
      question: 'What payment methods are accepted?',
      answer: 'We accept credit/debit cards, digital wallets, and cash in select areas. '
          'You can manage your payment methods in Settings.',
    ),
    FAQItem(
      question: 'How do I become a driver?',
      answer: 'Sign up as a driver through the app, submit required documents '
          '(driver\'s license, vehicle registration, insurance), '
          'pass background check, and complete orientation.',
    ),
    FAQItem(
      question: 'What if I left something in the car?',
      answer: 'Go to Ride History, select the trip, and tap "I lost an item". '
          'We\'ll help you contact the driver to retrieve your belongings.',
    ),
    FAQItem(
      question: 'How do I cancel a ride?',
      answer: 'You can cancel a ride any time before the driver arrives. '
          'Note that cancellation fees may apply if cancelled after 2 minutes '
          'or if the driver is already on the way.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Actions
            Container(
              decoration: AppTheme.glassDecoration(),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickAction(
                          icon: Icons.chat_bubble_outline,
                          label: 'Live Chat',
                          color: AppTheme.primaryColor,
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickAction(
                          icon: Icons.call_outlined,
                          label: 'Call Us',
                          color: AppTheme.successColor,
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickAction(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          color: AppTheme.infoColor,
                          onTap: () {},
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickAction(
                          icon: Icons.report_problem_outlined,
                          label: 'Report',
                          color: AppTheme.warningColor,
                          onTap: () => _showReportDialog(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 28),
            
            // FAQ Section
            Text(
              'Frequently Asked Questions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Container(
              decoration: AppTheme.cardDecoration(),
              child: Column(
                children: _faqItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final faq = entry.value;
                  final isExpanded = _expandedIndex == index;
                  
                  return Column(
                    children: [
                      if (index > 0)
                        Divider(
                          height: 1,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _expandedIndex = isExpanded ? -1 : index;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      faq.question,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  AnimatedRotation(
                                    turns: isExpanded ? 0.5 : 0,
                                    duration: const Duration(milliseconds: 200),
                                    child: const Icon(
                                      Icons.keyboard_arrow_down,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                              AnimatedCrossFade(
                                firstChild: const SizedBox.shrink(),
                                secondChild: Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(
                                    faq.answer,
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                                crossFadeState: isExpanded
                                    ? CrossFadeState.showSecond
                                    : CrossFadeState.showFirst,
                                duration: const Duration(milliseconds: 200),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 28),
            
            // Safety Guidelines
            Text(
              'Safety Guidelines',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Container(
              decoration: AppTheme.cardDecoration(),
              child: Column(
                children: [
                  _buildSafetyTile(
                    icon: Icons.verified_user,
                    title: 'Verify Your Driver',
                    subtitle: 'Always check driver\'s photo, name, and car details',
                  ),
                  Divider(height: 1, color: Colors.white.withOpacity(0.05)),
                  _buildSafetyTile(
                    icon: Icons.share_location,
                    title: 'Share Your Ride',
                    subtitle: 'Share trip details with friends or family',
                  ),
                  Divider(height: 1, color: Colors.white.withOpacity(0.05)),
                  _buildSafetyTile(
                    icon: Icons.shield,
                    title: 'Emergency Button',
                    subtitle: 'Quick access to emergency services',
                  ),
                  Divider(height: 1, color: Colors.white.withOpacity(0.05)),
                  _buildSafetyTile(
                    icon: Icons.star,
                    title: 'Rate Your Experience',
                    subtitle: 'Help us maintain quality and safety',
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

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.successColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: AppTheme.successColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppTheme.textMuted,
          fontSize: 12,
        ),
      ),
    );
  }

  void _showReportDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.backgroundCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Report an Issue',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Describe your issue...',
                  hintStyle: TextStyle(color: AppTheme.textMuted),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Report submitted successfully'),
                        backgroundColor: AppTheme.successColor,
                      ),
                    );
                  },
                  child: const Text('Submit Report'),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}
