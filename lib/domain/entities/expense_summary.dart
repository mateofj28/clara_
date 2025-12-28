import 'package:equatable/equatable.dart';
import 'expense.dart';

class ExpenseSummary extends Equatable {
  final double totalToday;
  final double totalMonth;
  final Map<ExpenseCategory, double> categoryTotals;
  final Map<ExpenseCategory, double> categoryPercentages;
  final ExpenseCategory? topCategory;
  final List<String> alerts;

  const ExpenseSummary({
    required this.totalToday,
    required this.totalMonth,
    required this.categoryTotals,
    required this.categoryPercentages,
    this.topCategory,
    required this.alerts,
  });

  @override
  List<Object?> get props => [
    totalToday,
    totalMonth,
    categoryTotals,
    categoryPercentages,
    topCategory,
    alerts,
  ];

  static ExpenseSummary fromExpenses(List<Expense> expenses) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monthStart = DateTime(now.year, now.month, 1);
    
    // Filtrar gastos de hoy
    final todayExpenses = expenses.where((expense) {
      final expenseDate = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );
      return expenseDate.isAtSameMomentAs(today);
    }).toList();
    
    // Filtrar gastos del mes
    final monthExpenses = expenses.where((expense) {
      return expense.date.isAfter(monthStart.subtract(const Duration(days: 1)));
    }).toList();
    
    // Calcular totales
    final totalToday = todayExpenses.fold<double>(
      0.0,
      (sum, expense) => sum + expense.amount,
    );
    
    final totalMonth = monthExpenses.fold<double>(
      0.0,
      (sum, expense) => sum + expense.amount,
    );
    
    // Calcular totales por categoría
    final categoryTotals = <ExpenseCategory, double>{};
    for (final category in ExpenseCategory.values) {
      categoryTotals[category] = monthExpenses
          .where((expense) => expense.category == category)
          .fold<double>(0.0, (sum, expense) => sum + expense.amount);
    }
    
    // Calcular porcentajes
    final categoryPercentages = <ExpenseCategory, double>{};
    if (totalMonth > 0) {
      for (final category in ExpenseCategory.values) {
        categoryPercentages[category] = 
            (categoryTotals[category]! / totalMonth) * 100;
      }
    }
    
    // Encontrar categoría principal
    ExpenseCategory? topCategory;
    double maxAmount = 0;
    for (final entry in categoryTotals.entries) {
      if (entry.value > maxAmount) {
        maxAmount = entry.value;
        topCategory = entry.key;
      }
    }
    
    // Generar alertas simples
    final alerts = _generateAlerts(expenses, categoryTotals);
    
    return ExpenseSummary(
      totalToday: totalToday,
      totalMonth: totalMonth,
      categoryTotals: categoryTotals,
      categoryPercentages: categoryPercentages,
      topCategory: maxAmount > 0 ? topCategory : null,
      alerts: alerts,
    );
  }
  
  static List<String> _generateAlerts(
    List<Expense> expenses,
    Map<ExpenseCategory, double> categoryTotals,
  ) {
    final alerts = <String>[];
    final now = DateTime.now();
    
    // Calcular promedio semanal por categoría
    final weeklyAverages = <ExpenseCategory, double>{};
    
    for (final category in ExpenseCategory.values) {
      final categoryExpenses = expenses
          .where((expense) => expense.category == category)
          .toList();
      
      if (categoryExpenses.isNotEmpty) {
        // Obtener gastos de las últimas 4 semanas
        final fourWeeksAgo = now.subtract(const Duration(days: 28));
        final recentExpenses = categoryExpenses
            .where((expense) => expense.date.isAfter(fourWeeksAgo))
            .toList();
        
        if (recentExpenses.isNotEmpty) {
          final totalAmount = recentExpenses.fold<double>(
            0.0,
            (sum, expense) => sum + expense.amount,
          );
          weeklyAverages[category] = totalAmount / 4; // Promedio semanal
        }
      }
    }
    
    // Verificar gastos de esta semana vs promedio
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    for (final category in ExpenseCategory.values) {
      final weeklyAverage = weeklyAverages[category] ?? 0;
      if (weeklyAverage > 0) {
        final thisWeekExpenses = expenses
            .where((expense) => 
                expense.category == category && 
                expense.date.isAfter(weekStart))
            .fold<double>(0.0, (sum, expense) => sum + expense.amount);
        
        if (thisWeekExpenses > weeklyAverage * 1.2) { // 20% más que el promedio
          alerts.add(
            'Ojo 👀, esta semana gastaste más de lo normal en ${category.displayName.toLowerCase()}'
          );
        }
      }
    }
    
    return alerts;
  }
}