import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/logger.dart';
import '../../domain/usecases/add_expense_usecase.dart';
import '../../domain/usecases/delete_expense_usecase.dart';
import '../../domain/usecases/get_expense_summary_usecase.dart';
import '../../domain/usecases/update_expense_usecase.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final AddExpenseUseCase addExpenseUseCase;
  final GetExpenseSummaryUseCase getExpenseSummaryUseCase;
  final UpdateExpenseUseCase? updateExpenseUseCase;
  final DeleteExpenseUseCase? deleteExpenseUseCase;

  ExpenseBloc({
    required this.addExpenseUseCase,
    required this.getExpenseSummaryUseCase,
    this.updateExpenseUseCase,
    this.deleteExpenseUseCase,
  }) : super(const ExpenseInitial()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<AddExpense>(_onAddExpense);
    on<UpdateExpense>(_onUpdateExpense);
    on<DeleteExpense>(_onDeleteExpense);
    on<RefreshExpenses>(_onRefreshExpenses);
  }

  Future<void> _onLoadExpenses(
    LoadExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      emit(const ExpenseLoading());
      AppLogger.bloc('LoadExpenses', 'Loading expenses summary');

      final summary = await getExpenseSummaryUseCase();

      AppLogger.bloc('LoadExpenses', 'Successfully loaded expenses summary');
      emit(ExpenseLoaded(summary));
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load expenses', e, stackTrace, 'BLOC');
      emit(ExpenseError('Error al cargar gastos: ${e.toString()}'));
    }
  }

  Future<void> _onAddExpense(
    AddExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    try {
      AppLogger.bloc('AddExpense',
          'Adding expense: ${event.expense.amount} - ${event.expense.category.displayName}');

      await addExpenseUseCase(event.expense);

      AppLogger.bloc('AddExpense', 'Successfully added expense');

      // Recargar datos después de agregar
      final summary = await getExpenseSummaryUseCase();
      emit(ExpenseOperationSuccess('Gasto agregado exitosamente',
          summary: summary));
    } catch (e, stackTrace) {
      AppLogger.error('Failed to add expense', e, stackTrace, 'BLOC');
      emit(ExpenseError('Error al agregar gasto: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateExpense(
    UpdateExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    if (updateExpenseUseCase == null) {
      emit(const ExpenseError('Función de actualización no disponible'));
      return;
    }

    try {
      AppLogger.bloc('UpdateExpense', 'Updating expense: ${event.expense.id}');

      await updateExpenseUseCase!(event.expense);

      AppLogger.bloc('UpdateExpense', 'Successfully updated expense');

      // Recargar datos después de actualizar
      final summary = await getExpenseSummaryUseCase();
      emit(ExpenseOperationSuccess('Gasto actualizado exitosamente',
          summary: summary));
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update expense', e, stackTrace, 'BLOC');
      emit(ExpenseError('Error al actualizar gasto: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteExpense(
    DeleteExpense event,
    Emitter<ExpenseState> emit,
  ) async {
    if (deleteExpenseUseCase == null) {
      emit(const ExpenseError('Función de eliminación no disponible'));
      return;
    }

    try {
      AppLogger.bloc('DeleteExpense', 'Deleting expense: ${event.expenseId}');

      await deleteExpenseUseCase!(event.expenseId);

      AppLogger.bloc('DeleteExpense', 'Successfully deleted expense');

      // Recargar datos después de eliminar
      final summary = await getExpenseSummaryUseCase();
      emit(ExpenseOperationSuccess('Gasto eliminado exitosamente',
          summary: summary));
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete expense', e, stackTrace, 'BLOC');
      emit(ExpenseError('Error al eliminar gasto: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshExpenses(
    RefreshExpenses event,
    Emitter<ExpenseState> emit,
  ) async {
    // Usar el mismo handler que LoadExpenses
    await _onLoadExpenses(const LoadExpenses(), emit);
  }
}
