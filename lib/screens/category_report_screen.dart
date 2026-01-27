//IMPORT PAKIETÓW I MODELI

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/budget_service.dart';

//DEFINIOWANIE EKRANU RAPORTU

class CategoryReportScreen extends StatefulWidget {
  const CategoryReportScreen({super.key});

  @override
  State<CategoryReportScreen> createState() => _CategoryReportScreenState();
}

//BUDOWA EKRANU RAPORTU

class _CategoryReportScreenState extends State<CategoryReportScreen> {
  DateTimeRange? _selectedRange;
  Map<String, double> _categoryTotals = {};

  @override
  void initState() {
    super.initState();
    _selectedRange = DateTimeRange(
      start: DateTime(DateTime.now().year, 1, 1),
      end: DateTime(DateTime.now().year, 12, 31),
    );
    _loadData();
  }

  void _loadData() {
    if (_selectedRange == null) return;
    final totals = BudgetService().getTotalsByCategory(
      start: _selectedRange!.start,
      end: _selectedRange!.end,
    );
    setState(() {
      _categoryTotals = totals;
    });
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: _selectedRange,
    );
    if (picked != null) {
      setState(() {
        _selectedRange = picked;
      });
      _loadData();
    }
  }

  List<PieChartSectionData> _generateSections() {
    final List<PieChartSectionData> sections = [];
    final totalAmount = _categoryTotals.values.fold<double>(0, (a, b) => a + b);

    int i = 0;
    _categoryTotals.forEach((category, amount) {
      final value = amount / totalAmount * 100;
      final color = Colors.primaries[i % Colors.primaries.length];
      sections.add(PieChartSectionData(
        color: color,
        value: amount,
        title: '$category\n${value.toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      ));
      i++;
    });

    return sections;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Raport według kategorii'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _pickDateRange,
          ),
        ],
      ),
      body: _categoryTotals.isEmpty
          ? const Center(child: Text('Brak danych do wyświetlenia'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: PieChart(
                PieChartData(
                  sections: _generateSections(),
                  centerSpaceRadius: 0,
                  sectionsSpace: 2,
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
    );
  }
}
