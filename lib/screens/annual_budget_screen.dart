import 'package:flutter/material.dart';
import 'services/budget_service.dart';
import 'models/transactions.dart';
import 'models/fixed_costs.dart';

class AnnualBudgetScreen extends StatefulWidget {
  @override
  _AnnualBudgetScreenState createState() => _AnnualBudgetScreenState();
}

class _AnnualBudgetScreenState extends State<AnnualBudgetScreen> {
  final BudgetService _budgetService = BudgetService();

  double totalIncome = 0.0;
  double totalVariableExpense = 0.0;
  double totalFixedMonthly = 0.0;
  double totalFixedYearly = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateTotals();
  }

  void _calculateTotals() {
    totalIncome = _budgetService.transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);

    totalVariableExpense = _budgetService.transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    totalFixedMonthly = _budgetService.fixedCosts
        .where((fc) => fc.period == FixedCostPeriod.monthly)
        .fold(0.0, (sum, fc) => sum + fc.amount);

    totalFixedYearly = _budgetService.fixedCosts
        .where((fc) => fc.period == FixedCostPeriod.yearly)
        .fold(0.0, (sum, fc) => sum + fc.amount);
  }

  @override
  Widget build(BuildContext context) {
    final totalExpenses = totalVariableExpense + totalFixedMonthly + totalFixedYearly;
    final balance = totalIncome - totalExpenses;

    return Scaffold(
      appBar: AppBar(title: Text('Budżet roczny')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Przychody zmienne: ${totalIncome.toStringAsFixed(2)} zł', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Koszty zmienne: ${totalVariableExpense.toStringAsFixed(2)} zł', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Koszty stałe miesięczne: ${totalFixedMonthly.toStringAsFixed(2)} zł', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Koszty stałe roczne: ${totalFixedYearly.toStringAsFixed(2)} zł', style: TextStyle(fontSize: 18)),
            Divider(height: 32, thickness: 2),
            Text('Łączne wydatki: ${totalExpenses.toStringAsFixed(2)} zł', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Bilans: ${balance.toStringAsFixed(2)} zł', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: balance >= 0 ? Colors.green : Colors.red)),
          ],
        ),
      ),
    );
  }
}