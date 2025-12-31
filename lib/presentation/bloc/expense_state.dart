import 'package:equatable/equatable.dart';

import '../../domain/entities/expense_summary.dart';

abstract class ExpenseState extends Equatable {
  const ExpenseState();

  @override
  List<Object?> get props => [];
}

class ExpenseInitial extends ExpenseState {
  const ExpenseInitial();
}

class ExpenseLoading extends ExpenseState {
  const ExpenseLoading();
}

class ExpenseLoaded extends ExpenseState {
  final ExpenseSummary summary;

  const ExpenseLoaded(this.summary);

  @override
  List<Object?> get props => [summary];
}

class ExpenseError extends ExpenseState {
  final String message;

  const ExpenseError(this.message);

  @override
  List<Object?> get props => [message];
}

class ExpenseOperationSuccess extends ExpenseState {
  final String message;
  final ExpenseSummary? summary;

  const ExpenseOperationSuccess(this.message, {this.summary});

  @override
  List<Object?> get props => [message, summary];
}
