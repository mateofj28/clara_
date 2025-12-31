import 'package:flutter/foundation.dart';

import '../../core/utils/logger.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/expense_summary.dart';
import '../../domain/usecases/add_expense_usecase.dart';
import '../../domain/usecases/get_expense_summary_usecase.dart';

// Estados
abstract class ExpenseState {}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseLoaded extends ExpenseState {
  final ExpenseSummary summary;
  ExpenseLoaded(this.summary);
}

class ExpenseError extends ExpenseState {
  final String message;
  ExpenseError(this.message);
}

class ExpenseAdded extends ExpenseState {}

// Eventos
abstract class ExpenseEvent {}

class LoadExpenses extends ExpenseEvent {}

class AddExpense extends ExpenseEvent {
  final Expense expense;
  AddExpense(this.expense);
}

// Bloc simple sin dependencias externas
class ExpenseBloc extends ChangeNotifier {
  final AddExpenseUseCase addExpenseUseCase;
  final GetExpenseSummaryUseCase getExpenseSummaryUseCase;

  ExpenseBloc({
    required this.addExpenseUseCase,
    required this.getExpenseSummaryUseCase,
  });

  ExpenseState _state = ExpenseInitial();
  ExpenseState get state => _state;

  void _emit(ExpenseState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> loadExpenses() async {
    try {
      _emit(ExpenseLoading());
      final summary = await getExpenseSummaryUseCase();
      _emit(ExpenseLoaded(summary));
    } catch (e) {
      _emit(ExpenseError('Error al cargar gastos: ${e.toString()}'));
    }
  }

  Future<void> addExpense(Expense expense) async {
    try {
      AppLogger.bloc('addExpense',
          'Adding expense: ${expense.amount} - ${expense.category.displayName}');
      await addExpenseUseCase(expense);
      _emit(ExpenseAdded());
      AppLogger.bloc('addExpense', 'Successfully added expense');
      // Recargar después de agregar
      await loadExpenses();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to add expense', e, stackTrace, 'BLOC');
      _emit(ExpenseError('Error al agregar gasto: ${e.toString()}'));
    }
  }
}
