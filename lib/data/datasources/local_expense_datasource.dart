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
    final jsonString = sharedPreferences.getString(_expensesKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => Expense.fromJson(json)).toList();
    }
    return [];
  }

  @override
  Future<void> saveExpense(Expense expense) async {
    final expenses = await getAllExpenses();
    expenses.add(expense);
    await _saveExpenses(expenses);
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
}