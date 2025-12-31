import 'package:flutter/material.dart';

import '../../core/di/injection_container.dart';
import '../bloc/expense_bloc.dart';

/// Mixin reutilizable para manejar el estado del ExpenseBloc
mixin ExpenseBlocMixin<T extends StatefulWidget> on State<T> {
  late ExpenseBloc _expenseBloc;

  ExpenseBloc get expenseBloc => _expenseBloc;

  @override
  void initState() {
    super.initState();
    _expenseBloc = sl.get<ExpenseBloc>();
    _expenseBloc.addListener(_onBlocStateChanged);

    // Solo cargar si no está ya cargado
    if (_expenseBloc.state is! ExpenseLoaded) {
      _expenseBloc.loadExpenses();
    }
  }

  @override
  void dispose() {
    _expenseBloc.removeListener(_onBlocStateChanged);
    super.dispose();
  }

  void _onBlocStateChanged() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  /// Método para recargar los gastos
  void reloadExpenses() {
    _expenseBloc.loadExpenses();
  }
}
