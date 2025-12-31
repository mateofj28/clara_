import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import '../bloc/expense_state.dart';

mixin ExpenseBlocMixin<T extends StatefulWidget> on State<T> {
  ExpenseBloc get expenseBloc => context.read<ExpenseBloc>();

  void loadExpenses() {
    expenseBloc.add(const LoadExpenses());
  }

  void refreshExpenses() {
    expenseBloc.add(const RefreshExpenses());
  }

  Widget buildBlocListener({required Widget child}) {
    return BlocListener<ExpenseBloc, ExpenseState>(
      listener: (context, state) {
        if (state is ExpenseError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (state is ExpenseOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: child,
    );
  }

  Widget buildBlocBuilder({
    required Widget Function(BuildContext context, ExpenseState state) builder,
  }) {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: builder,
    );
  }

  Widget buildBlocConsumer({
    required Widget Function(BuildContext context, ExpenseState state) builder,
    void Function(BuildContext context, ExpenseState state)? listener,
  }) {
    return BlocConsumer<ExpenseBloc, ExpenseState>(
      listener: listener ??
          (context, state) {
            if (state is ExpenseError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            } else if (state is ExpenseOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
      builder: builder,
    );
  }
}
