//IMPORT PAKIETÓW

import 'package:budzetownik/services/budget_service.dart';
import 'package:budzetownik/models/transactions.dart';
import 'package:budzetownik/models/fixed_costs.dart';
import 'package:flutter/material.dart';

//DEFINIOWANIE EKRANU BUDŻETU

class AnnualBudgetScreen extends StatefulWidget {
  const AnnualBudgetScreen({super.key});

  @override
  State<AnnualBudgetScreen> createState() => _AnnualBudgetScreenState();
}

//BUDOWA EKRANU BUDŻETU- JEDYNIE WYŚWIETLANIE DANYCH

class _AnnualBudgetScreenState extends State<AnnualBudgetScreen> {
  final BudgetService _budgetService = BudgetService();
  BudgetViewMode _viewMode = BudgetViewMode.yearly;

  @override
  Widget build(BuildContext context) {
    final income = _budgetService.calculateIncome(_viewMode);
    final variableExpenses =
        _budgetService.calculateVariableExpenses(_viewMode);
    final fixedExpenses =
        _budgetService.calculateFixedCosts(_viewMode);
    final balance =
        _budgetService.calculateBalance(_viewMode);

    return Scaffold(
      appBar: AppBar(
        title: Text('Budżet'),
        actions: [
          PopupMenuButton<BudgetViewMode>(
            onSelected: (mode) {
              setState(() {
                _viewMode = mode;
              });
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: BudgetViewMode.daily,
                child: Text('Widok dzienny'),
              ),
              PopupMenuItem(
                value: BudgetViewMode.monthly,
                child: Text('Widok miesięczny'),
              ),
              PopupMenuItem(
                value: BudgetViewMode.yearly,
                child: Text('Widok roczny'),
              ),
            ],
            icon: Icon(Icons.calendar_view_month),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _SummaryRow(
              label: 'Przychody',
              value: income,
            ),
            _SummaryRow(
              label: 'Koszty zmienne',
              value: variableExpenses,
            ),
            _SummaryRow(
              label: 'Koszty stałe',
              value: fixedExpenses,
            ),
            Divider(height: 32, thickness: 2),
            _SummaryRow(
              label: 'Saldo',
              value: balance,
              isBold: true,
              valueColor: balance >= 0 ? Colors.green : Colors.red,
            ),
            SizedBox(height: 12),
            Text(
              _modeDescription(),
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  String _modeDescription() {
    switch (_viewMode) {
      case BudgetViewMode.daily:
        return 'Widok dzienny (koszty stałe przeliczone na dzień)';
      case BudgetViewMode.monthly:
        return 'Widok miesięczny (roczne ÷ 12)';
      case BudgetViewMode.yearly:
        return 'Widok roczny (miesięczne × 12)';
    }
  }
}

//BUDOWA EKRANU BUDŻETU- JAK LICZYĆ, W JAKIM TRYBIE I KIEDY ODŚWIEŻYĆ UI

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isBold;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 18,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      color: valueColor,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text('${value.toStringAsFixed(2)} zł', style: style),
        ],
      ),
    );
  }
}
