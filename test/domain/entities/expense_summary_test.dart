import 'package:clara/domain/entities/expense.dart';
import 'package:clara/domain/entities/expense_summary.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ExpenseSummary Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({'monthly_limit': 1000000.0});
    });

    group('Basic Calculations', () {
      test('should calculate today total correctly', () async {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        final expenses = [
          Expense(
              id: '1',
              amount: 25000.0,
              category: ExpenseCategory.comida,
              date: today),
          Expense(
              id: '2',
              amount: 15000.0,
              category: ExpenseCategory.transporte,
              date: today),
          Expense(
              id: '3',
              amount: 50000.0,
              category: ExpenseCategory.compras,
              date: today.subtract(const Duration(days: 1))),
        ];

        final summary = await ExpenseSummary.fromExpenses(expenses);

        expect(summary.totalToday, equals(40000.0)); // 25000 + 15000
      });

      test('should calculate month total correctly', () async {
        final now = DateTime.now();
        final thisMonth = DateTime(now.year, now.month, 5);
        final lastMonth = DateTime(now.year, now.month - 1, 15);

        final expenses = [
          Expense(
              id: '1',
              amount: 100000.0,
              category: ExpenseCategory.comida,
              date: thisMonth),
          Expense(
              id: '2',
              amount: 50000.0,
              category: ExpenseCategory.transporte,
              date: thisMonth),
          Expense(
              id: '3',
              amount: 75000.0,
              category: ExpenseCategory.compras,
              date: lastMonth),
        ];

        final summary = await ExpenseSummary.fromExpenses(expenses);

        expect(
            summary.totalMonth, equals(150000.0)); // Solo gastos del mes actual
      });

      test('should handle empty expense list', () async {
        final summary = await ExpenseSummary.fromExpenses([]);

        expect(summary.totalToday, equals(0.0));
        expect(summary.totalMonth, equals(0.0));
        expect(summary.categoryTotals.values.every((total) => total == 0.0),
            isTrue);
        expect(summary.topCategory, isNull);
        expect(summary.alerts, isEmpty);
      });
    });

    group('Category Analysis', () {
      test('should calculate category totals correctly', () async {
        final now = DateTime.now();
        final thisMonth = DateTime(now.year, now.month, 5);

        final expenses = [
          Expense(
              id: '1',
              amount: 100000.0,
              category: ExpenseCategory.comida,
              date: thisMonth),
          Expense(
              id: '2',
              amount: 50000.0,
              category: ExpenseCategory.comida,
              date: thisMonth),
          Expense(
              id: '3',
              amount: 75000.0,
              category: ExpenseCategory.transporte,
              date: thisMonth),
          Expense(
              id: '4',
              amount: 200000.0,
              category: ExpenseCategory.deudas,
              date: thisMonth),
        ];

        final summary = await ExpenseSummary.fromExpenses(expenses);

        expect(
            summary.categoryTotals[ExpenseCategory.comida], equals(150000.0));
        expect(summary.categoryTotals[ExpenseCategory.transporte],
            equals(75000.0));
        expect(
            summary.categoryTotals[ExpenseCategory.deudas], equals(200000.0));
        expect(summary.categoryTotals[ExpenseCategory.compras], equals(0.0));
        expect(summary.categoryTotals[ExpenseCategory.otros], equals(0.0));
      });

      test('should calculate category percentages correctly', () async {
        final now = DateTime.now();
        final thisMonth = DateTime(now.year, now.month, 5);

        final expenses = [
          Expense(
              id: '1',
              amount: 60000.0,
              category: ExpenseCategory.comida,
              date: thisMonth),
          Expense(
              id: '2',
              amount: 40000.0,
              category: ExpenseCategory.transporte,
              date: thisMonth),
        ];

        final summary = await ExpenseSummary.fromExpenses(expenses);

        expect(
            summary.categoryPercentages[ExpenseCategory.comida], equals(60.0));
        expect(summary.categoryPercentages[ExpenseCategory.transporte],
            equals(40.0));
        expect(
            summary.categoryPercentages[ExpenseCategory.compras], equals(0.0));
      });

      test('should identify top category correctly', () async {
        final now = DateTime.now();
        final thisMonth = DateTime(now.year, now.month, 5);

        final expenses = [
          Expense(
              id: '1',
              amount: 50000.0,
              category: ExpenseCategory.comida,
              date: thisMonth),
          Expense(
              id: '2',
              amount: 100000.0,
              category: ExpenseCategory.deudas,
              date: thisMonth),
          Expense(
              id: '3',
              amount: 25000.0,
              category: ExpenseCategory.transporte,
              date: thisMonth),
        ];

        final summary = await ExpenseSummary.fromExpenses(expenses);

        expect(summary.topCategory, equals(ExpenseCategory.deudas));
      });

      test('should return null top category when no expenses', () async {
        final summary = await ExpenseSummary.fromExpenses([]);
        expect(summary.topCategory, isNull);
      });
    });

    group('Alert Generation', () {
      test('should generate monthly limit alert at 90%', () async {
        SharedPreferences.setMockInitialValues({'monthly_limit': 100000.0});

        final now = DateTime.now();
        final thisMonth = DateTime(now.year, now.month, 5);

        final expenses = [
          Expense(
              id: '1',
              amount: 90000.0,
              category: ExpenseCategory.deudas,
              date: thisMonth),
        ];

        final summary = await ExpenseSummary.fromExpenses(expenses);

        expect(
            summary.alerts
                .any((alert) => alert.contains('🚨') && alert.contains('90%')),
            isTrue);
      });

      test('should generate monthly limit alert at 75%', () async {
        SharedPreferences.setMockInitialValues({'monthly_limit': 100000.0});

        final now = DateTime.now();
        final thisMonth = DateTime(now.year, now.month, 5);

        final expenses = [
          Expense(
              id: '1',
              amount: 75000.0,
              category: ExpenseCategory.compras,
              date: thisMonth),
        ];

        final summary = await ExpenseSummary.fromExpenses(expenses);

        expect(
            summary.alerts
                .any((alert) => alert.contains('⚠️') && alert.contains('75%')),
            isTrue);
      });

      test('should generate monthly limit alert at 50%', () async {
        SharedPreferences.setMockInitialValues({'monthly_limit': 100000.0});

        final now = DateTime.now();
        final thisMonth = DateTime(now.year, now.month, 5);

        final expenses = [
          Expense(
              id: '1',
              amount: 50000.0,
              category: ExpenseCategory.comida,
              date: thisMonth),
        ];

        final summary = await ExpenseSummary.fromExpenses(expenses);

        expect(
            summary.alerts
                .any((alert) => alert.contains('📊') && alert.contains('50%')),
            isTrue);
      });

      test('should not generate limit alerts below 50%', () async {
        SharedPreferences.setMockInitialValues({'monthly_limit': 100000.0});

        final now = DateTime.now();
        final thisMonth = DateTime(now.year, now.month, 5);

        final expenses = [
          Expense(
              id: '1',
              amount: 5000.0, // Solo 5% del límite, no debería generar alertas
              category: ExpenseCategory.comida,
              date: thisMonth),
        ];

        final summary = await ExpenseSummary.fromExpenses(expenses);

        expect(summary.alerts.any((alert) => alert.contains('%')), isFalse);
      });

      test('should generate high individual expense alert', () async {
        SharedPreferences.setMockInitialValues({'monthly_limit': 100000.0});

        final now = DateTime.now();
        final thisMonth = DateTime(now.year, now.month, 5);

        final expenses = [
          Expense(
              id: '1',
              amount: 15000.0,
              category: ExpenseCategory.deudas,
              date: thisMonth), // 15% del límite
        ];

        final summary = await ExpenseSummary.fromExpenses(expenses);

        expect(
            summary.alerts.any(
                (alert) => alert.contains('¡Ojo!') && alert.contains('15.0%')),
            isTrue);
      });

      test('should use default monthly limit when not set', () async {
        SharedPreferences.setMockInitialValues({});

        final now = DateTime.now();
        final thisMonth = DateTime(now.year, now.month, 5);

        final expenses = [
          Expense(
              id: '1',
              amount: 500000.0,
              category: ExpenseCategory.deudas,
              date: thisMonth),
        ];

        final summary = await ExpenseSummary.fromExpenses(expenses);

        // Con límite por defecto de 1000000, 500000 es 50%
        expect(summary.alerts.any((alert) => alert.contains('50%')), isTrue);
      });
    });

    group('Edge Cases', () {
      test('should handle expenses with same timestamp', () async {
        final now = DateTime.now();
        final sameTime = DateTime(now.year, now.month, now.day, 10, 0);

        final expenses = [
          Expense(
              id: '1',
              amount: 25000.0,
              category: ExpenseCategory.comida,
              date: sameTime),
          Expense(
              id: '2',
              amount: 35000.0,
              category: ExpenseCategory.comida,
              date: sameTime),
          Expense(
              id: '3',
              amount: 15000.0,
              category: ExpenseCategory.transporte,
              date: sameTime),
        ];

        final summary = await ExpenseSummary.fromExpenses(expenses);

        expect(summary.totalToday, equals(75000.0));
        expect(summary.totalMonth, equals(75000.0));
        expect(summary.categoryTotals[ExpenseCategory.comida], equals(60000.0));
        expect(summary.categoryTotals[ExpenseCategory.transporte],
            equals(15000.0));
      });

      test('should handle very large amounts', () async {
        final now = DateTime.now();
        final thisMonth = DateTime(now.year, now.month, 5);

        final expenses = [
          Expense(
              id: '1',
              amount: 999999999.0,
              category: ExpenseCategory.deudas,
              date: thisMonth),
        ];

        final summary = await ExpenseSummary.fromExpenses(expenses);

        expect(summary.totalMonth, equals(999999999.0));
        expect(summary.categoryTotals[ExpenseCategory.deudas],
            equals(999999999.0));
        expect(summary.topCategory, equals(ExpenseCategory.deudas));
      });

      test('should handle expenses at month boundaries', () async {
        final now = DateTime.now();
        final currentMonth = DateTime(now.year, now.month, 1, 0, 1);
        final previousMonth = DateTime(now.year, now.month - 1, 28, 23, 59);

        final expenses = [
          Expense(
              id: 'prev',
              amount: 50000.0,
              category: ExpenseCategory.comida,
              date: previousMonth),
          Expense(
              id: 'curr',
              amount: 30000.0,
              category: ExpenseCategory.comida,
              date: currentMonth),
        ];

        final summary = await ExpenseSummary.fromExpenses(expenses);

        expect(summary.totalMonth,
            equals(30000.0)); // Solo el gasto del mes actual
      });

      test('should handle all categories with zero amounts', () async {
        final now = DateTime.now();
        final previousMonth = DateTime(now.year, now.month - 1, 15);

        final expenses = [
          Expense(
              id: '1',
              amount: 50000.0,
              category: ExpenseCategory.comida,
              date: previousMonth),
        ];

        final summary = await ExpenseSummary.fromExpenses(expenses);

        expect(summary.totalMonth, equals(0.0));
        expect(summary.categoryTotals.values.every((total) => total == 0.0),
            isTrue);
        expect(
            summary.categoryPercentages.values
                .every((percentage) => percentage == 0.0),
            isTrue);
        expect(summary.topCategory, isNull);
      });
    });
  });
}
