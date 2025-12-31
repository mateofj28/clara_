import 'package:clara/data/datasources/local_expense_datasource.dart';
import 'package:clara/domain/entities/expense.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LocalExpenseDataSource Tests', () {
    late LocalExpenseDataSourceImpl dataSource;
    late SharedPreferences sharedPreferences;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      sharedPreferences = await SharedPreferences.getInstance();
      dataSource =
          LocalExpenseDataSourceImpl(sharedPreferences: sharedPreferences);
    });

    tearDown(() async {
      await sharedPreferences.clear();
    });

    group('Basic Operations', () {
      test('should save and retrieve a single expense correctly', () async {
        final expense = Expense(
          id: 'test-1',
          amount: 50000.0,
          category: ExpenseCategory.comida,
          date: DateTime(2024, 1, 15),
          note: 'Test expense',
        );

        await dataSource.saveExpense(expense);
        final expenses = await dataSource.getAllExpenses();

        expect(expenses.length, equals(1));
        expect(expenses.first, equals(expense));
      });

      test('should save multiple expenses', () async {
        final date1 = DateTime(2024, 1, 15, 10, 0);
        final date2 = DateTime(2024, 1, 16, 11, 0);

        final expenses = [
          Expense(
              id: '1',
              amount: 25000.0,
              category: ExpenseCategory.transporte,
              date: date1),
          Expense(
              id: '2',
              amount: 75000.0,
              category: ExpenseCategory.compras,
              date: date2),
        ];

        for (final expense in expenses) {
          await dataSource.saveExpense(expense);
        }
        final retrieved = await dataSource.getAllExpenses();

        expect(retrieved.length, equals(2));
        expect(retrieved.map((e) => e.id), containsAll(['1', '2']));
        expect(retrieved.map((e) => e.amount), containsAll([25000.0, 75000.0]));
      });

      test('should return empty list when no expenses', () async {
        final expenses = await dataSource.getAllExpenses();
        expect(expenses, isEmpty);
      });

      test('should update existing expense', () async {
        final original = Expense(
          id: 'update-test',
          amount: 30000.0,
          category: ExpenseCategory.otros,
          date: DateTime.now(),
        );

        await dataSource.saveExpense(original);

        final updated = original.copyWith(amount: 45000.0);
        await dataSource.updateExpense(updated);

        final expenses = await dataSource.getAllExpenses();
        expect(expenses.length, equals(1));
        expect(expenses.first.amount, equals(45000.0));
      });

      test('should delete existing expense', () async {
        final expense = Expense(
          id: 'delete-me',
          amount: 20000.0,
          category: ExpenseCategory.comida,
          date: DateTime.now(),
        );

        await dataSource.saveExpense(expense);
        await dataSource.deleteExpense('delete-me');

        final expenses = await dataSource.getAllExpenses();
        expect(expenses, isEmpty);
      });
    });

    group('Data Validation', () {
      test('should reject expense with empty id', () async {
        final invalidExpense = Expense(
          id: '',
          amount: 50000.0,
          category: ExpenseCategory.comida,
          date: DateTime.now(),
        );

        expect(
          () async => await dataSource.saveExpense(invalidExpense),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should reject expense with zero amount', () async {
        final zeroExpense = Expense(
          id: 'zero-test',
          amount: 0.0,
          category: ExpenseCategory.comida,
          date: DateTime.now(),
        );

        expect(
          () async => await dataSource.saveExpense(zeroExpense),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should reject expense with negative amount', () async {
        final negativeExpense = Expense(
          id: 'negative-test',
          amount: -1000.0,
          category: ExpenseCategory.comida,
          date: DateTime.now(),
        );

        expect(
          () async => await dataSource.saveExpense(negativeExpense),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should reject expense with infinite amount', () async {
        final infiniteExpense = Expense(
          id: 'infinite-test',
          amount: double.infinity,
          category: ExpenseCategory.comida,
          date: DateTime.now(),
        );

        expect(
          () async => await dataSource.saveExpense(infiniteExpense),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should reject expense with NaN amount', () async {
        final nanExpense = Expense(
          id: 'nan-test',
          amount: double.nan,
          category: ExpenseCategory.comida,
          date: DateTime.now(),
        );

        expect(
          () async => await dataSource.saveExpense(nanExpense),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should reject expense with very large amount', () async {
        final largeExpense = Expense(
          id: 'large-test',
          amount: 1000000000000.0, // 1 trillion
          category: ExpenseCategory.deudas,
          date: DateTime.now(),
        );

        expect(
          () async => await dataSource.saveExpense(largeExpense),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should reject expense with future date', () async {
        final futureExpense = Expense(
          id: 'future-test',
          amount: 50000.0,
          category: ExpenseCategory.comida,
          date: DateTime.now().add(const Duration(days: 2)),
        );

        expect(
          () async => await dataSource.saveExpense(futureExpense),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should reject expense with very old date', () async {
        final oldExpense = Expense(
          id: 'old-test',
          amount: 50000.0,
          category: ExpenseCategory.comida,
          date: DateTime.now().subtract(const Duration(days: 365 * 11)),
        );

        expect(
          () async => await dataSource.saveExpense(oldExpense),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should accept valid expense', () async {
        final fixedDate = DateTime(2024, 1, 15, 10, 0);
        final validExpense = Expense(
          id: 'valid-test',
          amount: 50000.0,
          category: ExpenseCategory.comida,
          date: fixedDate,
          note: 'Valid note',
        );

        await dataSource.saveExpense(validExpense);
        final expenses = await dataSource.getAllExpenses();

        expect(expenses.length, equals(1));
        expect(expenses.first.id, equals('valid-test'));
        expect(expenses.first.amount, equals(50000.0));
      });
    });

    group('Error Handling', () {
      test('should handle corrupted JSON gracefully', () async {
        await sharedPreferences.setString('expenses', 'invalid-json');

        final expenses = await dataSource.getAllExpenses();

        expect(expenses, isEmpty);
        expect(sharedPreferences.getString('expenses'), isNull);
      });

      test('should handle empty JSON string', () async {
        await sharedPreferences.setString('expenses', '');

        final expenses = await dataSource.getAllExpenses();

        expect(expenses, isEmpty);
      });

      test('should handle null data', () async {
        final expenses = await dataSource.getAllExpenses();
        expect(expenses, isEmpty);
      });

      test('should skip invalid expenses in JSON array', () async {
        final mixedJson = '''[
          {
            "id": "valid-1",
            "amount": 50000.0,
            "category": "comida",
            "date": ${DateTime.now().millisecondsSinceEpoch},
            "note": "Valid"
          },
          {
            "id": "",
            "amount": -1000.0,
            "category": "invalid",
            "date": ${DateTime.now().millisecondsSinceEpoch}
          }
        ]''';

        await sharedPreferences.setString('expenses', mixedJson);

        final expenses = await dataSource.getAllExpenses();

        expect(expenses.length, equals(1));
        expect(expenses.first.id, equals('valid-1'));
      });
    });
  });
}
