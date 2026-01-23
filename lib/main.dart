import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/transactions.dart';
import 'models/fixed_costs.dart';
import 'services/budget_service.dart';
import 'screens/category_report_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(TransactionTypeAdapter());
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(FixedCostPeriodAdapter());
  Hive.registerAdapter(FixedCostAdapter());

  await BudgetService().init();

  runApp(BudzetownikApp());
}

class BudzetownikApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budżetownik',
      debugShowCheckedModeBanner: false,
      home: MainMenu(),
    );
  }
}

// ======================
// MAIN MENU
// ======================
class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MenuButton(
                  text: 'Przychody i koszty zmienne',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => VariableCostsScreen()),
                  ),
                ),
                MenuButton(
                  text: 'Przychody i koszty stałe',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => FixedCostsScreen()),
                  ),
                ),
                MenuButton(
                  text: 'Budżet',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AnnualBudgetScreen()),
                  ),
                ),
                MenuButton(
                  text: 'Raport według kategorii',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CategoryReportScreen()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const MenuButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 30),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.8),
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, color: Colors.black87),
        ),
      ),
    );
  }
}

// ======================
// VARIABLE COSTS
// ======================
class VariableCostsScreen extends StatefulWidget {
  @override
  State<VariableCostsScreen> createState() => _VariableCostsScreenState();
}

class _VariableCostsScreenState extends State<VariableCostsScreen> {
  final BudgetService _budgetService = BudgetService();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  TransactionType _type = TransactionType.expense;
  String _selectedCategory = 'Ogólne';

  final List<String> _categories = [
    'Ogólne',
    'Jedzenie',
    'Transport',
    'Rozrywka',
    'Zdrowie',
    'Inne'
  ];

  void _addTransaction() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Dodaj transakcję'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<TransactionType>(
              value: _type,
              items: const [
                DropdownMenuItem(
                    value: TransactionType.expense, child: Text('Koszt')),
                DropdownMenuItem(
                    value: TransactionType.income, child: Text('Przychód')),
              ],
              onChanged: (v) => _type = v!,
              decoration: const InputDecoration(labelText: 'Typ'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Opis'),
            ),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Kwota'),
            ),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => _selectedCategory = v!,
              decoration: const InputDecoration(labelText: 'Kategoria'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anuluj')),
          ElevatedButton(
            onPressed: () {
              _budgetService.addTransaction(Transaction(
                id: DateTime.now().toIso8601String(),
                type: _type,
                amount: double.parse(_amountController.text),
                date: DateTime.now(),
                category: _selectedCategory,
                description: _descriptionController.text,
              ));
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Dodaj'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactions = _budgetService.transactions;

    return Scaffold(
      appBar: AppBar(title: const Text('Koszty zmienne')),
      floatingActionButton:
          FloatingActionButton(onPressed: _addTransaction, child: const Icon(Icons.add)),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (_, i) {
          final t = transactions[i];
          return ListTile(
            title: Text(t.description),
            subtitle: Text('${t.type == TransactionType.income ? 'Przychód' : 'Koszt'} • ${t.category}'),
            trailing: Text('${t.amount.toStringAsFixed(2)} zł'),
          );
        },
      ),
    );
  }
}

// ======================
// FIXED COSTS
// ======================
class FixedCostsScreen extends StatefulWidget {
  @override
  State<FixedCostsScreen> createState() => _FixedCostsScreenState();
}

class _FixedCostsScreenState extends State<FixedCostsScreen> {
  final BudgetService _budgetService = BudgetService();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  FixedCostPeriod _period = FixedCostPeriod.monthly;
  String _selectedCategory = 'Stałe';

  final List<String> _categories = [
    'Stałe',
    'Mieszkanie',
    'Rachunki',
    'Subskrypcje',
    'Inne'
  ];

  void _addFixedCost() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Dodaj koszt stały'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nazwa'),
            ),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Kwota'),
            ),
            DropdownButtonFormField<FixedCostPeriod>(
              value: _period,
              items: const [
                DropdownMenuItem(
                    value: FixedCostPeriod.monthly, child: Text('Miesięczny')),
                DropdownMenuItem(
                    value: FixedCostPeriod.yearly, child: Text('Roczny')),
              ],
              onChanged: (v) => _period = v!,
              decoration: const InputDecoration(labelText: 'Okres'),
            ),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => _selectedCategory = v!,
              decoration: const InputDecoration(labelText: 'Kategoria'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anuluj')),
          ElevatedButton(
            onPressed: () {
              _budgetService.addFixedCost(FixedCost(
                id: DateTime.now().toIso8601String(),
                name: _nameController.text,
                amount: double.parse(_amountController.text),
                category: _selectedCategory,
                period: _period,
                startDate: DateTime.now(),
              ));
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Dodaj'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fixedCosts = _budgetService.fixedCosts;

    return Scaffold(
      appBar: AppBar(title: const Text('Koszty stałe')),
      floatingActionButton:
          FloatingActionButton(onPressed: _addFixedCost, child: const Icon(Icons.add)),
      body: ListView.builder(
        itemCount: fixedCosts.length,
        itemBuilder: (_, i) {
          final fc = fixedCosts[i];
          return ListTile(
            title: Text(fc.name),
            subtitle:
                Text('${fc.period == FixedCostPeriod.monthly ? 'Miesięczny' : 'Roczny'} • ${fc.category}'),
            trailing: Text('${fc.amount.toStringAsFixed(2)} zł'),
          );
        },
      ),
    );
  }
}

// ======================
// BUDGET SCREEN
// ======================

class AnnualBudgetScreen extends StatefulWidget {
  @override
  State<AnnualBudgetScreen> createState() => _AnnualBudgetScreenState();
}

class _AnnualBudgetScreenState extends State<AnnualBudgetScreen> {
  final BudgetService _budgetService = BudgetService();
  BudgetViewMode _mode = BudgetViewMode.yearly;

  @override
  Widget build(BuildContext context) {
    double income = _budgetService.calculateIncome(_mode);
    double variable = _budgetService.calculateVariableExpenses(_mode);
    double fixed = _budgetService.calculateFixedCosts(_mode);
    double balance = _budgetService.calculateBalance(_mode);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budżet'),
        actions: [
          DropdownButton<BudgetViewMode>(
            value: _mode,
            onChanged: (v) => setState(() => _mode = v!),
            items: const [
              DropdownMenuItem(value: BudgetViewMode.daily, child: Text('Dzienny')),
              DropdownMenuItem(value: BudgetViewMode.monthly, child: Text('Miesięczny')),
              DropdownMenuItem(value: BudgetViewMode.yearly, child: Text('Roczny')),
            ],
          )
        ],
      ),
      body: Column(
        children: [
          SummaryTile('Przychody', income),
          SummaryTile('Koszty zmienne', variable),
          SummaryTile('Koszty stałe', fixed),
          const Divider(),
          SummaryTile('Saldo', balance, bold: true),
        ],
      ),
    );
  }
}

class SummaryTile extends StatelessWidget {
  final String title;
  final double value;
  final bool bold;

  const SummaryTile(this.title, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title,
          style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      trailing: Text('${value.toStringAsFixed(2)} zł',
          style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
    );
  }
}
