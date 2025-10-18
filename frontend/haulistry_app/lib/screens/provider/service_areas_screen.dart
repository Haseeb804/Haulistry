import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_colors.dart';

class ServiceAreasScreen extends StatefulWidget {
  const ServiceAreasScreen({super.key});

  @override
  State<ServiceAreasScreen> createState() => _ServiceAreasScreenState();
}

class _ServiceAreasScreenState extends State<ServiceAreasScreen> {
  final List<Map<String, dynamic>> _serviceAreas = [
    {
      'id': '1',
      'city': 'Faisalabad',
      'areas': ['Madina Town', 'People\'s Colony', 'Susan Road', 'Samanabad'],
      'isActive': true,
      'addedDate': '2024-01-15',
    },
    {
      'id': '2',
      'city': 'Lahore',
      'areas': ['DHA', 'Gulberg', 'Model Town', 'Johar Town'],
      'isActive': true,
      'addedDate': '2024-02-10',
    },
    {
      'id': '3',
      'city': 'Multan',
      'areas': ['Cantt', 'Gulgasht Colony', 'Shah Rukn-e-Alam'],
      'isActive': false,
      'addedDate': '2024-03-05',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final activeAreas = _serviceAreas.where((a) => a['isActive'] == true).length;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
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
                            'Service Areas',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, color: Colors.white),
                          onPressed: _showAddAreaDialog,
                        ),
                      ],
                    ),
                  ),

                  // Stats
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            'Total Cities',
                            _serviceAreas.length.toString(),
                            Icons.location_city,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          _buildStatItem(
                            'Active Areas',
                            activeAreas.toString(),
                            Icons.check_circle,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          _buildStatItem(
                            'Coverage',
                            '${(activeAreas / _serviceAreas.length * 100).toInt()}%',
                            Icons.analytics,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                // Info Card
                _buildInfoCard(),
                SizedBox(height: 20),

                // Service Areas List
                Text(
                  'Your Service Areas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 12),

                ..._serviceAreas.map((area) => _buildAreaCard(area)),

                SizedBox(height: 20),
                _buildAddAreaButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Add cities and areas where you provide services. Customers in these areas can find and book your services.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaCard(Map<String, dynamic> area) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: area['isActive'] 
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.location_city,
                    color: area['isActive'] ? Colors.green : Colors.grey,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            area['city'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: area['isActive'] 
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              area['isActive'] ? 'Active' : 'Inactive',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: area['isActive'] ? Colors.green : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${area['areas'].length} areas covered',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  icon: Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 12),
                          Text('Edit Areas'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(
                            area['isActive'] ? Icons.pause_circle : Icons.play_circle,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Text(area['isActive'] ? 'Deactivate' : 'Activate'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 12),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) => _handleAreaAction(value.toString(), area),
                ),
              ],
            ),

            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 12),

            // Areas List
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (area['areas'] as List<String>).map((areaName) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on, size: 14, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text(
                        areaName,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 12),
            Text(
              'Added on ${area['addedDate']}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddAreaButton() {
    return OutlinedButton.icon(
      onPressed: _showAddAreaDialog,
      icon: Icon(Icons.add_circle_outline),
      label: Text('Add New Service Area'),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(color: AppColors.primary, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showAddAreaDialog() {
    final cityController = TextEditingController();
    final areaController = TextEditingController();
    final List<String> selectedAreas = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.add_location, color: AppColors.primary),
              SizedBox(width: 12),
              Text('Add Service Area'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: cityController,
                  decoration: InputDecoration(
                    labelText: 'City Name',
                    hintText: 'Enter city name',
                    prefixIcon: Icon(Icons.location_city),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: areaController,
                  decoration: InputDecoration(
                    labelText: 'Area/Locality',
                    hintText: 'Enter area name',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.add_circle),
                      onPressed: () {
                        if (areaController.text.isNotEmpty) {
                          setDialogState(() {
                            selectedAreas.add(areaController.text);
                            areaController.clear();
                          });
                        }
                      },
                    ),
                  ),
                ),
                if (selectedAreas.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Text(
                    'Selected Areas:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: selectedAreas.map((area) {
                      return Chip(
                        label: Text(area, style: TextStyle(fontSize: 12)),
                        deleteIcon: Icon(Icons.close, size: 18),
                        onDeleted: () {
                          setDialogState(() {
                            selectedAreas.remove(area);
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (cityController.text.isNotEmpty && selectedAreas.isNotEmpty) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Service area added successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: Text('Add Area'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAreaAction(String action, Map<String, dynamic> area) {
    switch (action) {
      case 'edit':
        _showAddAreaDialog();
        break;
      case 'toggle':
        setState(() {
          area['isActive'] = !area['isActive'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              area['isActive'] 
                  ? 'Service area activated' 
                  : 'Service area deactivated',
            ),
          ),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(area);
        break;
    }
  }

  void _showDeleteConfirmation(Map<String, dynamic> area) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 12),
            Text('Delete Service Area?'),
          ],
        ),
        content: Text(
          'Are you sure you want to remove ${area['city']} from your service areas?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _serviceAreas.removeWhere((a) => a['id'] == area['id']);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Service area deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
