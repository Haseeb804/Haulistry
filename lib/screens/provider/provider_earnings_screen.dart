import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_colors.dart';

class ProviderEarningsScreen extends StatefulWidget {
  const ProviderEarningsScreen({super.key});

  @override
  State<ProviderEarningsScreen> createState() => _ProviderEarningsScreenState();
}

class _ProviderEarningsScreenState extends State<ProviderEarningsScreen> {
  String _selectedPeriod = 'This Month';
  final List<String> _periods = ['Today', 'This Week', 'This Month', 'This Year', 'All Time'];

  // Mock data
  final Map<String, dynamic> _earnings = {
    'total': 450000,
    'thisMonth': 85000,
    'pending': 12500,
    'available': 72500,
  };

  final List<Map<String, dynamic>> _transactions = [
    {
      'id': 'TXN001',
      'type': 'earning',
      'title': 'Booking Payment',
      'client': 'Ahmed Khan',
      'service': 'Premium Harvester',
      'amount': 10000,
      'date': '2024-03-10',
      'status': 'completed',
      'bookingId': 'BK001',
    },
    {
      'id': 'TXN002',
      'type': 'withdrawal',
      'title': 'Bank Transfer',
      'bankName': 'HBL Bank',
      'accountNumber': '****1234',
      'amount': 50000,
      'date': '2024-03-08',
      'status': 'completed',
    },
    {
      'id': 'TXN003',
      'type': 'earning',
      'title': 'Booking Payment',
      'client': 'Hassan Ali',
      'service': 'Harvester Pro',
      'amount': 15000,
      'date': '2024-03-07',
      'status': 'completed',
      'bookingId': 'BK002',
    },
    {
      'id': 'TXN004',
      'type': 'earning',
      'title': 'Booking Payment',
      'client': 'Fatima Noor',
      'service': 'Premium Harvester',
      'amount': 20000,
      'date': '2024-03-05',
      'status': 'pending',
      'bookingId': 'BK003',
    },
    {
      'id': 'TXN005',
      'type': 'refund',
      'title': 'Booking Refund',
      'client': 'Usman Tariq',
      'service': 'Harvester Pro',
      'amount': 12500,
      'date': '2024-03-03',
      'status': 'completed',
      'bookingId': 'BK004',
    },
  ];

  final List<Map<String, dynamic>> _chartData = [
    {'month': 'Jan', 'amount': 65000},
    {'month': 'Feb', 'amount': 75000},
    {'month': 'Mar', 'amount': 85000},
    {'month': 'Apr', 'amount': 70000},
    {'month': 'May', 'amount': 90000},
    {'month': 'Jun', 'amount': 80000},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.topRight,
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.8),
                ],
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
                            'Earnings',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.download, color: Colors.white),
                          onPressed: _downloadReport,
                        ),
                      ],
                    ),
                  ),

                  // Stats Cards
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Total Earnings',
                                'Rs ${_earnings['total']}',
                                Icons.account_balance_wallet,
                                Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                'This Month',
                                'Rs ${_earnings['thisMonth']}',
                                Icons.trending_up,
                                Colors.white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Pending',
                                'Rs ${_earnings['pending']}',
                                Icons.pending,
                                Colors.orange,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                'Available',
                                'Rs ${_earnings['available']}',
                                Icons.check_circle,
                                Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Withdraw Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _showWithdrawDialog,
                      icon: Icon(Icons.account_balance, color: Colors.white),
                      label: Text(
                        'Withdraw Earnings',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),

                  SizedBox(height: 24),

                  // Earnings Chart
                  _buildSectionTitle('Earnings Overview'),
                  SizedBox(height: 12),
                  _buildEarningsChart(),

                  SizedBox(height: 24),

                  // Period Filter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle('Transaction History'),
                      DropdownButton<String>(
                        value: _selectedPeriod,
                        items: _periods.map((period) {
                          return DropdownMenuItem(
                            value: period,
                            child: Text(period),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPeriod = value!;
                          });
                        },
                        underline: SizedBox(),
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12),

                  // Transactions List
                  ..._transactions.map((transaction) {
                    return _buildTransactionCard(transaction);
                  }).toList(),

                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color iconColor) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildEarningsChart() {
    double maxAmount = _chartData.map((e) => e['amount'] as int).reduce((a, b) => a > b ? a : b).toDouble();

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: _chartData.map((data) {
              double height = (data['amount'] / maxAmount) * 150;
              bool isHighest = data['amount'] == maxAmount;

              return Column(
                children: [
                  Text(
                    'Rs ${(data['amount'] / 1000).toStringAsFixed(0)}k',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isHighest
                            ? [AppColors.primary, AppColors.primary.withOpacity(0.6)]
                            : [AppColors.primary.withOpacity(0.6), AppColors.primary.withOpacity(0.3)],
                      ),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    data['month'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    IconData icon;
    Color iconColor;
    Color bgColor;

    switch (transaction['type']) {
      case 'earning':
        icon = Icons.arrow_downward;
        iconColor = Colors.green;
        bgColor = Colors.green.shade50;
        break;
      case 'withdrawal':
        icon = Icons.arrow_upward;
        iconColor = Colors.blue;
        bgColor = Colors.blue.shade50;
        break;
      case 'refund':
        icon = Icons.undo;
        iconColor = Colors.red;
        bgColor = Colors.red.shade50;
        break;
      default:
        icon = Icons.attach_money;
        iconColor = AppColors.primary;
        bgColor = Colors.orange.shade50;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          transaction['title'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            if (transaction['type'] == 'earning' || transaction['type'] == 'refund')
              Text(
                '${transaction['client']} • ${transaction['service']}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              )
            else
              Text(
                '${transaction['bankName']} • ${transaction['accountNumber']}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            SizedBox(height: 4),
            Row(
              children: [
                Text(
                  transaction['date'],
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: transaction['status'] == 'completed'
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    transaction['status'].toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: transaction['status'] == 'completed'
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${transaction['type'] == 'withdrawal' || transaction['type'] == 'refund' ? '-' : '+'} Rs ${transaction['amount']}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: transaction['type'] == 'withdrawal' || transaction['type'] == 'refund'
                    ? Colors.red
                    : Colors.green,
              ),
            ),
            if (transaction['bookingId'] != null) ...[
              SizedBox(height: 4),
              Text(
                transaction['bookingId'],
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
        onTap: () => _showTransactionDetail(transaction),
      ),
    );
  }

  void _showWithdrawDialog() {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.account_balance, color: AppColors.primary),
            SizedBox(width: 12),
            Text('Withdraw Earnings'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Balance: Rs ${_earnings['available']}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount (PKR)',
                hintText: 'Enter amount',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Bank: HBL Bank ****1234',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 4),
            TextButton(
              onPressed: () {},
              child: Text('Change Bank Account'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.zero,
              ),
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
                SnackBar(
                  content: Text('Withdrawal request submitted'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text('Withdraw', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showTransactionDetail(Map<String, dynamic> transaction) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaction Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildDetailRow('Transaction ID', transaction['id']),
            Divider(height: 24),
            _buildDetailRow('Type', transaction['type'].toUpperCase()),
            Divider(height: 24),
            _buildDetailRow('Amount', 'Rs ${transaction['amount']}'),
            Divider(height: 24),
            _buildDetailRow('Date', transaction['date']),
            Divider(height: 24),
            _buildDetailRow('Status', transaction['status'].toUpperCase()),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.download, color: Colors.white),
                label: Text('Download Receipt', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  void _downloadReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading earnings report...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
