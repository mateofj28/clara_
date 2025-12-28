import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/local_expense_datasource.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final LocalExpenseDataSource localDataSource;

  ExpenseRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Expense>> getAllExpenses() async {
    return await localDataSource.getAllExpenses();
  }

  @override
  Future<void> addExpense(Expense expense) async {
    await localDataSource.saveExpense(expense);
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    await localDataSource.updateExpense(expense);
  }

  @override
  Future<void> deleteExpense(String id) async {
    await localDataSource.deleteExpense(id);
  }

  @override
  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end) async {
    final allExpenses = await getAllExpenses();
    return allExpenses.where((expense) {
      return expense.date.isAfter(start.subtract(const Duration(days: 1))) &&
             expense.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  @override
  Future<List<Expense>> getExpensesByCategory(ExpenseCategory category) async {
    final allExpenses = await getAllExpenses();
    return allExpenses.where((expense) => expense.category == category).toList();
  }
}