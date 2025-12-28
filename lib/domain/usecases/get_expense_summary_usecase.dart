import '../entities/expense_summary.dart';
import '../repositories/expense_repository.dart';

class GetExpenseSummaryUseCase {
  final ExpenseRepository repository;

  GetExpenseSummaryUseCase(this.repository);

  Future<ExpenseSummary> call() async {
    final expenses = await repository.getAllExpenses();
    return ExpenseSummary.fromExpenses(expenses);
  }
}