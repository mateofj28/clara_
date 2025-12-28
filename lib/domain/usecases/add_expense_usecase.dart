import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

class AddExpenseUseCase {
  final ExpenseRepository repository;

  AddExpenseUseCase(this.repository);

  Future<void> call(Expense expense) async {
    await repository.addExpense(expense);
  }
}