import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class PaymentSettingsScreen extends StatefulWidget {
  const PaymentSettingsScreen({super.key});

  @override
  State<PaymentSettingsScreen> createState() => _PaymentSettingsScreenState();
}

class _PaymentSettingsScreenState extends State<PaymentSettingsScreen> {
  String _defaultPaymentMethod = 'card_1';
  bool _saveCardDetails = true;
  bool _autoPayEnabled = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'card_1',
      'type': 'card',
      'name': 'Visa ending in 4242',
      'icon': Icons.credit_card,
      'color': Colors.blue,
      'expiry': '12/25',
    },
    {
      'id': 'card_2',
      'type': 'card',
      'name': 'Mastercard ending in 8888',
      'icon': Icons.credit_card,
      'color': Colors.orange,
      'expiry': '08/26',
    },
    {
      'id': 'easypaisa',
      'type': 'mobile',
      'name': 'EasyPaisa',
      'icon': Icons.phone_android,
      'color': Colors.green,
      'number': '+92 300 1234567',
    },
    {
      'id': 'jazzcash',
      'type': 'mobile',
      'name': 'JazzCash',
      'icon': Icons.phone_android,
      'color': Colors.red,
      'number': '+92 301 7654321',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Payment Settings'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () => _showPaymentHistory(context),
            tooltip: 'Payment History',
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Payment Methods
          _buildSectionHeader('Payment Methods', Icons.payment),
          SizedBox(height: 12),
          ..._paymentMethods.map((method) => _buildPaymentMethodCard(method)),
          
          SizedBox(height: 12),
          _buildAddPaymentButton(context),
          
          SizedBox(height: 24),
          
          // Settings
          _buildSectionHeader('Payment Settings', Icons.settings),
          SizedBox(height: 12),
          _buildSettingsCard(context),
          
          SizedBox(height: 24),
          
          // Quick Actions
          _buildSectionHeader('Quick Actions', Icons.bolt),
          SizedBox(height: 12),
          _buildQuickActionsCard(context),
          
          SizedBox(height: 20),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPaymentMethodDialog(context),
        icon: Icon(Icons.add),
        label: Text('Add Payment Method'),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard(Map<String, dynamic> method) {
    final isDefault = _defaultPaymentMethod == method['id'];
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: method['color'].withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(method['icon'], color: method['color'], size: 28),
        ),
        title: Text(
          method['name'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              method['type'] == 'card' 
                ? 'Expires: ${method['expiry']}'
                : method['number'],
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            if (isDefault) ...[
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Default',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton(
          icon: Icon(Icons.more_vert),
          itemBuilder: (context) => [
            if (!isDefault)
              PopupMenuItem(
                value: 'default',
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 20),
                    SizedBox(width: 8),
                    Text('Set as Default'),
                  ],
                ),
              ),
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Remove', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) => _handlePaymentAction(value, method),
        ),
      ),
    );
  }

  Widget _buildAddPaymentButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _showAddPaymentMethodDialog(context),
      icon: Icon(Icons.add_circle_outline),
      label: Text('Add New Payment Method'),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            secondary: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.save, color: Colors.blue),
            ),
            title: Text('Save Card Details'),
            subtitle: Text('Securely save cards for faster checkout'),
            value: _saveCardDetails,
            onChanged: (value) => setState(() => _saveCardDetails = value),
          ),
          Divider(height: 1),
          SwitchListTile(
            secondary: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.auto_awesome, color: Colors.green),
            ),
            title: Text('Auto-Pay'),
            subtitle: Text('Automatically pay for bookings'),
            value: _autoPayEnabled,
            onChanged: (value) => setState(() => _autoPayEnabled = value),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.history, color: Colors.purple),
            ),
            title: Text('Payment History'),
            subtitle: Text('View all transactions'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showPaymentHistory(context),
          ),
          Divider(height: 1),
          ListTile(
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.receipt_long, color: Colors.orange),
            ),
            title: Text('Invoices'),
            subtitle: Text('Download invoices'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showInvoices(context),
          ),
          Divider(height: 1),
          ListTile(
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.account_balance_wallet, color: Colors.teal),
            ),
            title: Text('Wallet'),
            subtitle: Text('Add money to wallet'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showWalletDialog(context),
          ),
        ],
      ),
    );
  }

  void _handlePaymentAction(String action, Map<String, dynamic> method) {
    switch (action) {
      case 'default':
        setState(() => _defaultPaymentMethod = method['id']);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${method['name']} set as default')),
        );
        break;
      case 'edit':
        _showEditPaymentDialog(context, method);
        break;
      case 'delete':
        _showDeletePaymentDialog(context, method);
        break;
    }
  }

  void _showAddPaymentMethodDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add Payment Method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPaymentOption(context, 'Credit/Debit Card', Icons.credit_card, Colors.blue),
            SizedBox(height: 12),
            _buildPaymentOption(context, 'EasyPaisa', Icons.phone_android, Colors.green),
            SizedBox(height: 12),
            _buildPaymentOption(context, 'JazzCash', Icons.phone_android, Colors.red),
            SizedBox(height: 12),
            _buildPaymentOption(context, 'Bank Transfer', Icons.account_balance, Colors.purple),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(BuildContext context, String name, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(name),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.pop(context);
          _showAddCardDialog(context, name);
        },
      ),
    );
  }

  void _showAddCardDialog(BuildContext context, String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Add $type'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: type.contains('Card') ? 'Card Number' : 'Mobile Number',
                  prefixIcon: Icon(type.contains('Card') ? Icons.credit_card : Icons.phone),
                ),
              ),
              if (type.contains('Card')) ...[
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Expiry',
                          hintText: 'MM/YY',
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'CVV',
                        ),
                        obscureText: true,
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Cardholder Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$type added successfully')),
              );
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditPaymentDialog(BuildContext context, Map<String, dynamic> method) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit ${method['name']}')),
    );
  }

  void _showDeletePaymentDialog(BuildContext context, Map<String, dynamic> method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 12),
            Text('Remove Payment Method?'),
          ],
        ),
        content: Text('Are you sure you want to remove ${method['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${method['name']} removed')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showPaymentHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Payment History'),
        content: Container(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildHistoryItem('Tractor Service', '-PKR 5,000', 'Oct 10, 2025', true),
              _buildHistoryItem('Sand Delivery', '-PKR 3,500', 'Oct 8, 2025', true),
              _buildHistoryItem('Crane Rental', '-PKR 12,000', 'Oct 5, 2025', true),
              _buildHistoryItem('Wallet Top-up', '+PKR 10,000', 'Oct 3, 2025', false),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String title, String amount, String date, bool isDebit) {
    return ListTile(
      leading: Icon(
        isDebit ? Icons.arrow_upward : Icons.arrow_downward,
        color: isDebit ? Colors.red : Colors.green,
      ),
      title: Text(title),
      subtitle: Text(date),
      trailing: Text(
        amount,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isDebit ? Colors.red : Colors.green,
        ),
      ),
    );
  }

  void _showInvoices(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening invoices...')),
    );
  }

  void _showWalletDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.account_balance_wallet, color: Colors.teal),
            SizedBox(width: 12),
            Text('Wallet Balance'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'PKR 2,500',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                labelText: 'Add Amount',
                prefixText: 'PKR ',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Money added to wallet')),
              );
            },
            child: Text('Add Money'),
          ),
        ],
      ),
    );
  }
}
