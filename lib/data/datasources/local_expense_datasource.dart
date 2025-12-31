import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/expense.dart';

abstract class LocalExpenseDataSource {
  Future<List<Expense>> getAllExpenses();
  Future<void> saveExpense(Expense expense);
  Future<void> updateExpense(Expense expense);
  Future<void> deleteExpense(String id);
}

class LocalExpenseDataSourceImpl implements LocalExpenseDataSource {
  static const String _expensesKey = 'expenses';
  final SharedPreferences sharedPreferences;

  LocalExpenseDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<Expense>> getAllExpenses() async {
    try {
      final jsonString = sharedPreferences.getString(_expensesKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> jsonList = json.decode(jsonString);
        final expenses = <Expense>[];

        // Validar cada gasto individualmente
        for (final json in jsonList) {
          try {
            if (json is Map<String, dynamic>) {
              final expense = Expense.fromJson(json);
              // Validar que el gasto sea válido
              if (_isValidExpense(expense)) {
                expenses.add(expense);
              }
            }
          } catch (e) {
            // Log del error pero continúa con los demás gastos
            print('Error parsing individual expense: $e');
          }
        }

        return expenses;
      }
      return [];
    } catch (e) {
      // Si hay error crítico, devolver lista vacía y limpiar datos corruptos
      print('Critical error loading expenses: $e');
      await sharedPreferences.remove(_expensesKey);
      return [];
    }
  }

  @override
  Future<void> saveExpense(Expense expense) async {
    // Validar el gasto antes de guardarlo
    if (!_isValidExpense(expense)) {
      throw ArgumentError('Invalid expense data');
    }

    try {
      final expenses = await getAllExpenses();
      expenses.add(expense);
      await _saveExpenses(expenses);
    } catch (e) {
      throw Exception('Failed to save expense: $e');
    }
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    final expenses = await getAllExpenses();
    final index = expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      expenses[index] = expense;
      await _saveExpenses(expenses);
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    final expenses = await getAllExpenses();
    expenses.removeWhere((expense) => expense.id == id);
    await _saveExpenses(expenses);
  }

  Future<void> _saveExpenses(List<Expense> expenses) async {
    final jsonList = expenses.map((expense) => expense.toJson()).toList();
    final jsonString = json.encode(jsonList);
    await sharedPreferences.setString(_expensesKey, jsonString);
  }

  /// Valida que un gasto tenga datos válidos
  bool _isValidExpense(Expense expense) {
    // Validar ID
    if (expense.id.isEmpty) return false;

    // Validar monto (debe ser positivo y no infinito)
    if (expense.amount <= 0 ||
        expense.amount.isInfinite ||
        expense.amount.isNaN ||
        expense.amount > 999999999999) {
      return false; // Límite máximo razonable
    }

    // Validar fecha (no puede ser muy futura)
    final now = DateTime.now();
    final maxFutureDate = now.add(const Duration(days: 1));
    if (expense.date.isAfter(maxFutureDate)) return false;

    // Validar que la fecha no sea muy antigua (más de 10 años)
    final minDate = now.subtract(const Duration(days: 365 * 10));
    if (expense.date.isBefore(minDate)) return false;

    // Validar nota (si existe, no debe ser muy larga)
    if (expense.note != null && expense.note!.length > 500) return false;

    return true;
  }
}
