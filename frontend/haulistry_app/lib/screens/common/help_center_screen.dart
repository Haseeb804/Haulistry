import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  String _selectedCategory = 'all';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _faqCategories = [
    {'id': 'all', 'name': 'All', 'icon': Icons.apps},
    {'id': 'booking', 'name': 'Bookings', 'icon': Icons.book_online},
    {'id': 'payment', 'name': 'Payments', 'icon': Icons.payment},
    {'id': 'account', 'name': 'Account', 'icon': Icons.person},
    {'id': 'services', 'name': 'Services', 'icon': Icons.build},
  ];

  final List<Map<String, dynamic>> _faqs = [
    {
      'category': 'booking',
      'question': 'How do I book a service?',
      'answer': 'To book a service:\n\n1. Browse or search for the service you need\n2. View provider details and reviews\n3. Select your preferred date and time\n4. Enter service details and requirements\n5. Review booking summary\n6. Confirm and make payment\n\nYou\'ll receive instant confirmation and can track your booking in real-time.',
    },
    {
      'category': 'booking',
      'question': 'Can I cancel or modify my booking?',
      'answer': 'Yes! You can cancel or modify bookings:\n\n• Free cancellation up to 24 hours before service\n• Cancellation fee applies for last-minute cancellations\n• To modify: Go to My Bookings → Select booking → Modify\n• Refunds are processed within 5-7 business days',
    },
    {
      'category': 'booking',
      'question': 'What if the provider doesn\'t show up?',
      'answer': 'If a provider doesn\'t show up:\n\n1. Contact them via app chat or phone\n2. Wait 15 minutes past scheduled time\n3. Report issue through "Report Problem" button\n4. Get full refund automatically\n5. We\'ll help you find another provider\n\nOur support team is available 24/7 to assist you.',
    },
    {
      'category': 'payment',
      'question': 'What payment methods are accepted?',
      'answer': 'We accept multiple payment methods:\n\n• Credit/Debit Cards (Visa, Mastercard)\n• EasyPaisa\n• JazzCash\n• Bank Transfer\n• Haulistry Wallet\n• Cash on Delivery (selected services)\n\nAll payments are secure and encrypted.',
    },
    {
      'category': 'payment',
      'question': 'How do refunds work?',
      'answer': 'Refund process:\n\n• Automatic approval for valid cancellations\n• Refunded to original payment method\n• Processing time: 5-7 business days\n• Wallet refunds are instant\n• Partial refunds for service issues\n\nCheck refund status in Payment History.',
    },
    {
      'category': 'payment',
      'question': 'Is my payment information safe?',
      'answer': 'Absolutely! We use:\n\n• Bank-level encryption (256-bit SSL)\n• PCI-DSS compliance\n• Secure payment gateways\n• No storage of CVV/PIN\n• Two-factor authentication\n\nYour financial data is never shared with providers.',
    },
    {
      'category': 'account',
      'question': 'How do I update my profile?',
      'answer': 'To update your profile:\n\n1. Go to Profile tab\n2. Tap "Edit Profile"\n3. Update information\n4. Save changes\n\nYou can update:\n• Name and contact\n• Profile picture\n• Location preferences\n• Service preferences',
    },
    {
      'category': 'account',
      'question': 'How do I change my password?',
      'answer': 'To change password:\n\n1. Settings → Privacy & Security\n2. Tap "Change Password"\n3. Enter current password\n4. Enter new password (8+ characters)\n5. Confirm new password\n6. Save\n\nEnable 2FA for extra security!',
    },
    {
      'category': 'account',
      'question': 'How do I delete my account?',
      'answer': 'To delete your account:\n\n1. Settings → Privacy & Security\n2. Scroll to "Delete Account"\n3. Review consequences\n4. Confirm deletion\n5. Enter password to verify\n\nWarning: This action is permanent and cannot be undone. All data will be erased.',
    },
    {
      'category': 'services',
      'question': 'What types of services are available?',
      'answer': 'We offer services in:\n\n• Agriculture (Tractors, Harvesters, etc.)\n• Construction (Cranes, Excavators, etc.)\n• Logistics (Trucks, Cargo, Delivery)\n• Emergency (Towing, Heavy Lifting)\n\nBrowse by category or search for specific services.',
    },
    {
      'category': 'services',
      'question': 'How are providers verified?',
      'answer': 'All providers undergo:\n\n• Identity verification (CNIC)\n• License verification\n• Vehicle inspection\n• Background check\n• Insurance verification\n• Customer review system\n\nOnly verified providers can accept bookings.',
    },
    {
      'category': 'services',
      'question': 'Can I favorite providers?',
      'answer': 'Yes! To save favorite providers:\n\n1. View provider profile\n2. Tap heart icon\n3. Access favorites from menu\n4. Quick booking from favorites\n5. Get notified of their availability\n\nBuild your trusted provider network!',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredFaqs {
    return _faqs.where((faq) {
      final matchesCategory = _selectedCategory == 'all' || faq['category'] == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          faq['question'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          faq['answer'].toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.8)],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                          onPressed: () => context.pop(),
                        ),
                        Expanded(
                          child: Text(
                            'Help Center',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Search Bar
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search for help...',
                        hintStyle: TextStyle(color: Colors.white70),
                        prefixIcon: Icon(Icons.search, color: Colors.white),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: Colors.white),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Category Tabs
          _buildCategoryTabs(),

          // Content
          Expanded(
            child: _filteredFaqs.isEmpty
                ? _buildEmptyState()
                : ListView(
                    padding: EdgeInsets.all(16),
                    children: [
                      // Quick Contact Cards
                      if (_searchQuery.isEmpty && _selectedCategory == 'all') ...[
                        _buildQuickContactSection(),
                        SizedBox(height: 24),
                      ],
                      
                      // FAQs
                      Text(
                        'Frequently Asked Questions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onBackground,
                        ),
                      ),
                      SizedBox(height: 16),
                      ..._filteredFaqs.map((faq) => _buildFAQCard(faq)),
                      
                      SizedBox(height: 24),
                      _buildStillNeedHelp(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _faqCategories.length,
        itemBuilder: (context, index) {
          final category = _faqCategories[index];
          final isSelected = _selectedCategory == category['id'];
          
          return Padding(
            padding: EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category['icon'],
                    size: 18,
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                  ),
                  SizedBox(width: 8),
                  Text(category['name']),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedCategory = category['id']);
              },
              selectedColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Colors.grey.shade200,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Contact',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildContactCard(
                'Chat Support',
                '24/7 Available',
                Icons.chat_bubble,
                Colors.blue,
                () => _openChat(),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildContactCard(
                'Call Us',
                '+92 300 1234567',
                Icons.phone,
                Colors.green,
                () => _callSupport(),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildContactCard(
                'Email',
                'support@haulistry.com',
                Icons.email,
                Colors.orange,
                () => _emailSupport(),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildContactCard(
                'WhatsApp',
                'Quick Response',
                Icons.chat_bubble_outline,
                Colors.teal,
                () => _openWhatsApp(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQCard(Map<String, dynamic> faq) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getCategoryColor(faq['category']).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getCategoryIcon(faq['category']),
            color: _getCategoryColor(faq['category']),
            size: 20,
          ),
        ),
        title: Text(
          faq['question'],
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              faq['answer'],
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Was this helpful?',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Spacer(),
                TextButton.icon(
                  onPressed: () => _markHelpful(true),
                  icon: Icon(Icons.thumb_up, size: 16),
                  label: Text('Yes'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _markHelpful(false),
                  icon: Icon(Icons.thumb_down, size: 16),
                  label: Text('No'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 24),
            Text(
              'No Results Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Try different keywords or browse categories',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _selectedCategory = 'all';
                });
              },
              child: Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStillNeedHelp() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.support_agent, size: 48, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Still Need Help?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Our support team is available 24/7',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _openChat(),
              icon: Icon(Icons.chat, color: Theme.of(context).colorScheme.primary),
              label: Text(
                'Chat with Support',
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'booking':
        return Colors.blue;
      case 'payment':
        return Colors.green;
      case 'account':
        return Colors.purple;
      case 'services':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'booking':
        return Icons.book_online;
      case 'payment':
        return Icons.payment;
      case 'account':
        return Icons.person;
      case 'services':
        return Icons.build;
      default:
        return Icons.help;
    }
  }

  void _openChat() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening chat support...'),
        action: SnackBarAction(
          label: 'Connect',
          onPressed: () {},
        ),
      ),
    );
  }

  void _callSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Calling +92 300 1234567...')),
    );
  }

  void _emailSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening email client...')),
    );
  }

  void _openWhatsApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening WhatsApp...')),
    );
  }

  void _markHelpful(bool helpful) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(helpful ? 'Glad we could help!' : 'We\'ll improve this answer'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
