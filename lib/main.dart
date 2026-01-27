//IMPORT PAKIETÓW, MODELI, LOGIKI i EKRANÓW

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/transactions.dart';
import 'models/fixed_costs.dart';
import 'services/budget_service.dart';
import 'screens/category_report_screen.dart';
import 'screens/annual_budget_screen.dart';

//PRZYGOTOWANIE DO URUCHOMIENIA APLIKACJI I INICJALIZACJA HIVE DO ZAPISYWANIA DANYCH
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

//INICJACJA UI

class BudzetownikApp extends StatelessWidget {
  const BudzetownikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budżetownik',
      debugShowCheckedModeBanner: false,
      home: MainMenu(),
    );
  }
}

// EKRAN MENU GŁÓWNEGO

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

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
                  text: 'Koszty stałe',
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

//TWORZENIE WIDŻETU PRZYCISKU MENU

class MenuButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const MenuButton({super.key, required this.text, required this.onPressed});

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


// EKRAN DODAWANIA KOSZTÓW I PRZYCHODÓW ZMIENNYCH

class VariableCostsScreen extends StatefulWidget {
  const VariableCostsScreen({super.key});

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
    'Ogólne', 'Jedzenie', 'Transport', 'Rozrywka', 'Zdrowie', 'Inne'
  ];

  void _showTransactionDialog({Transaction? transaction}) {
    if (transaction != null) {
      _descriptionController.text = transaction.description;
      _amountController.text = transaction.amount.toString();
      _type = transaction.type;
      _selectedCategory = transaction.category;
    } else {
      _descriptionController.clear();
      _amountController.clear();
      _type = TransactionType.expense;
      _selectedCategory = 'Ogólne';
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(transaction == null ? 'Dodaj transakcję' : 'Edytuj transakcję'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<TransactionType>(
              initialValue: _type,
              items: const [
                DropdownMenuItem(value: TransactionType.expense, child: Text('Koszt')),
                DropdownMenuItem(value: TransactionType.income, child: Text('Przychód')),
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
              initialValue: _selectedCategory,
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => _selectedCategory = v!,
              decoration: const InputDecoration(labelText: 'Kategoria'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Anuluj')),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(_amountController.text) ?? 0;
              if (transaction == null) {
                await _budgetService.addTransaction(Transaction(
                  id: DateTime.now().toIso8601String(),
                  type: _type,
                  amount: amount,
                  date: DateTime.now(),
                  category: _selectedCategory,
                  description: _descriptionController.text,
                ));
              } else {
                await _budgetService.editTransaction(transaction.id, Transaction(
                  id: transaction.id,
                  type: _type,
                  amount: amount,
                  date: transaction.date,
                  category: _selectedCategory,
                  description: _descriptionController.text,
                ));
              }
              setState(() {});
              Navigator.pop(context);
            },
            child: Text(transaction == null ? 'Dodaj' : 'Zapisz'),
          ),
        ],
      ),
    );
  }

  void _deleteTransaction(String id) async {
    await _budgetService.deleteTransaction(id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final transactions = _budgetService.transactions;

    return Scaffold(
      appBar: AppBar(title: const Text('Koszty zmienne')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTransactionDialog(),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (_, i) {
          final t = transactions[i];
          return ListTile(
            title: Text(t.description),
            subtitle: Text('${t.type == TransactionType.income ? 'Przychód' : 'Koszt'} • ${t.category}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${t.amount.toStringAsFixed(2)} zł', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showTransactionDialog(transaction: t),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteTransaction(t.id),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


// EKRAN KOSZTÓW STAŁYCH

class FixedCostsScreen extends StatefulWidget {
  const FixedCostsScreen({super.key});

  @override
  State<FixedCostsScreen> createState() => _FixedCostsScreenState();
}

class _FixedCostsScreenState extends State<FixedCostsScreen> {
  final BudgetService _budgetService = BudgetService();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  FixedCostPeriod _period = FixedCostPeriod.monthly;
  String _selectedCategory = 'Stałe';
  final List<String> _categories = ['Stałe', 'Mieszkanie', 'Rachunki', 'Subskrypcje', 'Inne'];

  void _showFixedCostDialog({FixedCost? cost}) {
    if (cost != null) {
      _nameController.text = cost.name;
      _amountController.text = cost.amount.toString();
      _period = cost.period;
      _selectedCategory = cost.category;
    } else {
      _nameController.clear();
      _amountController.clear();
      _period = FixedCostPeriod.monthly;
      _selectedCategory = 'Stałe';
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(cost == null ? 'Dodaj koszt stały' : 'Edytuj koszt stały'),
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
              initialValue: _period,
              items: const [
                DropdownMenuItem(value: FixedCostPeriod.monthly, child: Text('Miesięczny')),
                DropdownMenuItem(value: FixedCostPeriod.yearly, child: Text('Roczny')),
              ],
              onChanged: (v) => _period = v!,
              decoration: const InputDecoration(labelText: 'Okres'),
            ),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => _selectedCategory = v!,
              decoration: const InputDecoration(labelText: 'Kategoria'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Anuluj')),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(_amountController.text) ?? 0;
              if (cost == null) {
                await _budgetService.addFixedCost(FixedCost(
                  id: DateTime.now().toIso8601String(),
                  name: _nameController.text,
                  amount: amount,
                  category: _selectedCategory,
                  period: _period,
                  startDate: DateTime.now(),
                ));
              } else {
                await _budgetService.editFixedCost(cost.id, FixedCost(
                  id: cost.id,
                  name: _nameController.text,
                  amount: amount,
                  category: _selectedCategory,
                  period: _period,
                  startDate: cost.startDate,
                ));
              }
              setState(() {});
              Navigator.pop(context);
            },
            child: Text(cost == null ? 'Dodaj' : 'Zapisz'),
          ),
        ],
      ),
    );
  }

  void _deleteFixedCost(String id) async {
    await _budgetService.deleteFixedCost(id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final fixedCosts = _budgetService.fixedCosts;

    return Scaffold(
      appBar: AppBar(title: const Text('Koszty stałe')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFixedCostDialog(),
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: fixedCosts.length,
        itemBuilder: (_, i) {
          final fc = fixedCosts[i];
          return ListTile(
            title: Text(fc.name),
            subtitle: Text('${fc.period == FixedCostPeriod.monthly ? 'Miesięczny' : 'Roczny'} • ${fc.category}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${fc.amount.toStringAsFixed(2)} zł', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showFixedCostDialog(cost: fc),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteFixedCost(fc.id),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


// EKRAN ROCZNEGO BUDŻETU

class AnnualBudgetScreen extends StatefulWidget {
  const AnnualBudgetScreen({super.key});

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

//OPIS I KWOTA, DO UŻYCIA W EKRANIE WYDATKÓW STAŁYCH I ZMIENNYCH

class SummaryTile extends StatelessWidget {
  final String title;
  final double value;
  final bool bold;

  const SummaryTile(this.title, this.value, {super.key, this.bold = false});

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

