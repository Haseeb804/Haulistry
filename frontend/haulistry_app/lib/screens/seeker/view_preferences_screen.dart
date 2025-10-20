import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../providers/seeker_preferences_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../models/seeker_preferences_model.dart';

class ViewPreferencesScreen extends StatefulWidget {
  const ViewPreferencesScreen({super.key});

  @override
  State<ViewPreferencesScreen> createState() => _ViewPreferencesScreenState();
}

class _ViewPreferencesScreenState extends State<ViewPreferencesScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to avoid calling notifyListeners during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPreferences();
    });
  }

  Future<void> _loadPreferences() async {
    final authService = context.read<AuthService>();
    final authProvider = context.read<AuthProvider>();
    final preferencesProvider = context.read<SeekerPreferencesProvider>();
    
    await preferencesProvider.loadPreferences(
      authProvider.currentUser?.id ?? 'user_123',
      authService: authService,
    );
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Service Preferences',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              context.push('/seeker/service-preferences');
            },
            tooltip: 'Edit Preferences',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : Consumer<SeekerPreferencesProvider>(
              builder: (context, preferencesProvider, child) {
                if (!preferencesProvider.hasPreferences()) {
                  return _buildEmptyState();
                }

                final preferences = preferencesProvider.preferences;
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Card
                      _buildHeaderCard(preferences),

                      SizedBox(height: 16),

                      // Service Categories Section
                      _buildSectionCard(
                        'Service Categories',
                        Icons.category,
                        Colors.blue,
                        _buildCategoriesList(preferences),
                      ),

                      SizedBox(height: 16),

                      // Primary Purpose & Urgency
                      _buildSectionCard(
                        'Usage Details',
                        Icons.info_outline,
                        Colors.purple,
                        _buildUsageDetails(preferences),
                      ),

                      SizedBox(height: 16),

                      // Service Requirements
                      if (preferences.serviceRequirements.isNotEmpty)
                        _buildSectionCard(
                          'Service Requirements',
                          Icons.list_alt,
                          Colors.orange,
                          _buildRequirementsList(preferences),
                        ),

                      SizedBox(height: 16),

                      // Notes
                      if (preferences.notes.isNotEmpty)
                        _buildSectionCard(
                          'Additional Notes',
                          Icons.note,
                          Colors.teal,
                          _buildNotes(preferences),
                        ),

                      SizedBox(height: 16),

                      // Timestamps
                      _buildTimestamps(preferences),

                      SizedBox(height: 32),

                      // Action Buttons
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  context.push('/seeker/service-preferences');
                                },
                                icon: Icon(Icons.edit),
                                label: Text('Update Preferences'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => _confirmClearPreferences(),
                                icon: Icon(Icons.delete_outline),
                                label: Text('Clear All Preferences'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: BorderSide(color: Colors.red),
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 32),
                    ],
                  ),
                );
              },
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
              Icons.tune,
              size: 100,
              color: Colors.grey.shade300,
            ),
            SizedBox(height: 24),
            Text(
              'No Preferences Set',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Set your service preferences to get better recommendations and personalized matches.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.push('/seeker/service-preferences');
              },
              icon: Icon(Icons.add),
              label: Text('Set Preferences Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(SeekerPreferences preferences) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 32),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Preferences Set',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Your service preferences are helping us provide better recommendations',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, IconData icon, Color color, Widget content) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: EdgeInsets.all(20),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList(SeekerPreferences preferences) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: preferences.serviceCategories.map((category) {
        final subcategories = preferences.categoryDetails[category] ?? [];
        return Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getCategoryIcon(category),
                    color: AppColors.primary,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              if (subcategories.isNotEmpty) ...[
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: subcategories.map((subcategory) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Text(
                        subcategory,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUsageDetails(SeekerPreferences preferences) {
    return Column(
      children: [
        _buildDetailRow(
          'Primary Purpose',
          preferences.primaryPurpose,
          Icons.flag,
          Colors.purple,
        ),
        SizedBox(height: 12),
        _buildDetailRow(
          'Urgency Level',
          preferences.urgency,
          Icons.timer,
          _getUrgencyColor(preferences.urgency),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequirementsList(SeekerPreferences preferences) {
    final requirements = preferences.serviceRequirements.entries.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: requirements.map((entry) {
        final category = entry.key;
        final requirement = entry.value;
        
        return Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 8),
              if (requirement.frequency != null)
                _buildRequirementDetail('Frequency', requirement.frequency!),
              if (requirement.quantity != null) ...[
                SizedBox(height: 4),
                _buildRequirementDetail('Quantity', requirement.quantity!),
              ],
              if (requirement.duration != null) ...[
                SizedBox(height: 4),
                _buildRequirementDetail('Duration', requirement.duration!),
              ],
              if (requirement.additionalDetails.isNotEmpty) ...[
                SizedBox(height: 8),
                ...requirement.additionalDetails.entries.map((detail) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: _buildRequirementDetail(detail.key, detail.value),
                  );
                }).toList(),
              ],
              if (entry != requirements.last)
                Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Divider(),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRequirementDetail(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotes(SeekerPreferences preferences) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        preferences.notes,
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildTimestamps(SeekerPreferences preferences) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Created:',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  _formatDate(preferences.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Last Updated:',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  _formatDate(preferences.updatedAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Agriculture':
        return Icons.agriculture;
      case 'Construction':
        return Icons.construction;
      case 'Transportation':
        return Icons.local_shipping;
      case 'Heavy Equipment':
        return Icons.precision_manufacturing;
      default:
        return Icons.category;
    }
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'immediate':
        return Colors.red;
      case 'within a week':
        return Colors.orange;
      case 'within a month':
        return Colors.blue;
      case 'flexible':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _confirmClearPreferences() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('Clear Preferences?'),
          ],
        ),
        content: Text(
          'Are you sure you want to clear all your service preferences? This action cannot be undone.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final authService = context.read<AuthService>();
      final preferencesProvider = context.read<SeekerPreferencesProvider>();
      
      final userId = authService.userProfile?['uid'] ?? 'user_123';
      
      try {
        await preferencesProvider.clearPreferences(
          userId,
          authService: authService,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Preferences cleared successfully from both app and database'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          
          // Navigate back to dashboard
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to clear preferences: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}
