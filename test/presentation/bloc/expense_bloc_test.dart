import 'package:clara/domain/entities/expense.dart';
import 'package:clara/domain/entities/expense_summary.dart';
import 'package:clara/presentation/bloc/expense_event.dart';
import 'package:clara/presentation/bloc/expense_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExpenseEvent Tests', () {
    group('Equality Tests', () {
      test('LoadExpenses events should be equal', () {
        expect(const LoadExpenses(), equals(const LoadExpenses()));
      });

      test('AddExpense events with same expense should be equal', () {
        final expense = Expense(
          id: 'test',
          amount: 1000.0,
          category: ExpenseCategory.comida,
          date: DateTime(2024, 1, 1),
        );

        expect(AddExpense(expense), equals(AddExpense(expense)));
      });

      test('AddExpense events with different expenses should not be equal', () {
        final expense1 = Expense(
          id: 'test1',
          amount: 1000.0,
          category: ExpenseCategory.comida,
          date: DateTime(2024, 1, 1),
        );

        final expense2 = Expense(
          id: 'test2',
          amount: 2000.0,
          category: ExpenseCategory.transporte,
          date: DateTime(2024, 1, 2),
        );

        expect(AddExpense(expense1), isNot(equals(AddExpense(expense2))));
      });

      test('UpdateExpense events with same expense should be equal', () {
        final expense = Expense(
          id: 'test',
          amount: 1000.0,
          category: ExpenseCategory.comida,
          date: DateTime(2024, 1, 1),
        );

        expect(UpdateExpense(expense), equals(UpdateExpense(expense)));
      });

      test('DeleteExpense events with same id should be equal', () {
        expect(const DeleteExpense('test-id'),
            equals(const DeleteExpense('test-id')));
      });

      test('DeleteExpense events with different ids should not be equal', () {
        expect(const DeleteExpense('id1'),
            isNot(equals(const DeleteExpense('id2'))));
      });

      test('RefreshExpenses events should be equal', () {
        expect(const RefreshExpenses(), equals(const RefreshExpenses()));
      });
    });

    group('Props Tests', () {
      test('LoadExpenses props should be empty', () {
        const event = LoadExpenses();
        expect(event.props, isEmpty);
      });

      test('AddExpense props should include expense', () {
        final expense = Expense(
          id: 'test',
          amount: 1000.0,
          category: ExpenseCategory.comida,
          date: DateTime(2024, 1, 1),
        );

        final event = AddExpense(expense);
        expect(event.props, equals([expense]));
      });

      test('UpdateExpense props should include expense', () {
        final expense = Expense(
          id: 'test',
          amount: 1000.0,
          category: ExpenseCategory.comida,
          date: DateTime(2024, 1, 1),
        );

        final event = UpdateExpense(expense);
        expect(event.props, equals([expense]));
      });

      test('DeleteExpense props should include expenseId', () {
        const event = DeleteExpense('test-id');
        expect(event.props, equals(['test-id']));
      });

      test('RefreshExpenses props should be empty', () {
        const event = RefreshExpenses();
        expect(event.props, isEmpty);
      });
    });
  });

  group('ExpenseState Tests', () {
    group('Equality Tests', () {
      test('ExpenseInitial states should be equal', () {
        expect(const ExpenseInitial(), equals(const ExpenseInitial()));
      });

      test('ExpenseLoading states should be equal', () {
        expect(const ExpenseLoading(), equals(const ExpenseLoading()));
      });

      test('ExpenseError states with same message should be equal', () {
        expect(
          const ExpenseError('Test error'),
          equals(const ExpenseError('Test error')),
        );
      });

      test('ExpenseError states with different messages should not be equal',
          () {
        expect(
          const ExpenseError('Error 1'),
          isNot(equals(const ExpenseError('Error 2'))),
        );
      });

      test('ExpenseLoaded states with same summary should be equal', () {
        const summary = ExpenseSummary(
          totalToday: 100.0,
          totalMonth: 500.0,
          categoryTotals: {},
          categoryPercentages: {},
          alerts: [],
        );

        expect(
          const ExpenseLoaded(summary),
          equals(const ExpenseLoaded(summary)),
        );
      });

      test('ExpenseOperationSuccess states with same message should be equal',
          () {
        expect(
          const ExpenseOperationSuccess('Success'),
          equals(const ExpenseOperationSuccess('Success')),
        );
      });

      test(
          'ExpenseOperationSuccess states with different messages should not be equal',
          () {
        expect(
          const ExpenseOperationSuccess('Success 1'),
          isNot(equals(const ExpenseOperationSuccess('Success 2'))),
        );
      });
    });

    group('Props Tests', () {
      test('ExpenseInitial props should be empty', () {
        const state = ExpenseInitial();
        expect(state.props, isEmpty);
      });

      test('ExpenseLoading props should be empty', () {
        const state = ExpenseLoading();
        expect(state.props, isEmpty);
      });

      test('ExpenseError props should include message', () {
        const state = ExpenseError('Test error');
        expect(state.props, equals(['Test error']));
      });

      test('ExpenseLoaded props should include summary', () {
        const summary = ExpenseSummary(
          totalToday: 100.0,
          totalMonth: 500.0,
          categoryTotals: {},
          categoryPercentages: {},
          alerts: [],
        );

        const state = ExpenseLoaded(summary);
        expect(state.props, equals([summary]));
      });

      test('ExpenseOperationSuccess props should include message and summary',
          () {
        const summary = ExpenseSummary(
          totalToday: 100.0,
          totalMonth: 500.0,
          categoryTotals: {},
          categoryPercentages: {},
          alerts: [],
        );

        const state = ExpenseOperationSuccess('Success', summary: summary);
        expect(state.props, equals(['Success', summary]));
      });

      test('ExpenseOperationSuccess props with null summary', () {
        const state = ExpenseOperationSuccess('Success', summary: null);
        expect(state.props, equals(['Success', null]));
      });
    });
  });

  group('Type Hierarchy Tests', () {
    test('all events should extend ExpenseEvent', () {
      expect(const LoadExpenses(), isA<ExpenseEvent>());

      final expense = Expense(
        id: 'test',
        amount: 1000.0,
        category: ExpenseCategory.comida,
        date: DateTime.now(),
      );

      expect(AddExpense(expense), isA<ExpenseEvent>());
      expect(UpdateExpense(expense), isA<ExpenseEvent>());
      expect(const DeleteExpense('test'), isA<ExpenseEvent>());
      expect(const RefreshExpenses(), isA<ExpenseEvent>());
    });

    test('all states should extend ExpenseState', () {
      expect(const ExpenseInitial(), isA<ExpenseState>());
      expect(const ExpenseLoading(), isA<ExpenseState>());
      expect(const ExpenseError('error'), isA<ExpenseState>());

      const summary = ExpenseSummary(
        totalToday: 0,
        totalMonth: 0,
        categoryTotals: {},
        categoryPercentages: {},
        alerts: [],
      );

      expect(const ExpenseLoaded(summary), isA<ExpenseState>());
      expect(const ExpenseOperationSuccess('success'), isA<ExpenseState>());
    });
  });
}
