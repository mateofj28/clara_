import 'package:clara/domain/entities/expense.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Expense Entity Tests', () {
    late Expense testExpense;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 1, 15, 10, 30);
      testExpense = Expense(
        id: 'test-id-123',
        amount: 50000.0,
        category: ExpenseCategory.comida,
        date: testDate,
        note: 'Almuerzo en restaurante',
      );
    });

    group('Constructor and Properties', () {
      test('should create expense with all properties', () {
        expect(testExpense.id, equals('test-id-123'));
        expect(testExpense.amount, equals(50000.0));
        expect(testExpense.category, equals(ExpenseCategory.comida));
        expect(testExpense.date, equals(testDate));
        expect(testExpense.note, equals('Almuerzo en restaurante'));
      });

      test('should create expense without note', () {
        final expense = Expense(
          id: 'test-id',
          amount: 25000.0,
          category: ExpenseCategory.transporte,
          date: testDate,
        );

        expect(expense.note, isNull);
      });
    });

    group('Equality and Props', () {
      test('should be equal when all properties match', () {
        final expense1 = Expense(
          id: 'same-id',
          amount: 100000.0,
          category: ExpenseCategory.compras,
          date: testDate,
          note: 'Same note',
        );

        final expense2 = Expense(
          id: 'same-id',
          amount: 100000.0,
          category: ExpenseCategory.compras,
          date: testDate,
          note: 'Same note',
        );

        expect(expense1, equals(expense2));
        expect(expense1.hashCode, equals(expense2.hashCode));
      });

      test('should not be equal when properties differ', () {
        final expense1 = Expense(
          id: 'id-1',
          amount: 100000.0,
          category: ExpenseCategory.compras,
          date: testDate,
        );

        final expense2 = Expense(
          id: 'id-2',
          amount: 100000.0,
          category: ExpenseCategory.compras,
          date: testDate,
        );

        expect(expense1, isNot(equals(expense2)));
      });
    });

    group('CopyWith Method', () {
      test('should copy with new id', () {
        final copied = testExpense.copyWith(id: 'new-id');

        expect(copied.id, equals('new-id'));
        expect(copied.amount, equals(testExpense.amount));
        expect(copied.category, equals(testExpense.category));
        expect(copied.date, equals(testExpense.date));
        expect(copied.note, equals(testExpense.note));
      });

      test('should copy with new amount', () {
        final copied = testExpense.copyWith(amount: 75000.0);

        expect(copied.amount, equals(75000.0));
        expect(copied.id, equals(testExpense.id));
      });

      test('should copy with new category', () {
        final copied = testExpense.copyWith(category: ExpenseCategory.deudas);

        expect(copied.category, equals(ExpenseCategory.deudas));
        expect(copied.id, equals(testExpense.id));
      });

      test('should copy with new date', () {
        final newDate = DateTime(2024, 2, 20);
        final copied = testExpense.copyWith(date: newDate);

        expect(copied.date, equals(newDate));
        expect(copied.id, equals(testExpense.id));
      });

      test('should copy with new note', () {
        final copied = testExpense.copyWith(note: 'Nueva nota');

        expect(copied.note, equals('Nueva nota'));
        expect(copied.id, equals(testExpense.id));
      });

      test('should copy without changing anything when no parameters', () {
        final copied = testExpense.copyWith();

        expect(copied, equals(testExpense));
        expect(copied.id, equals(testExpense.id));
        expect(copied.amount, equals(testExpense.amount));
        expect(copied.category, equals(testExpense.category));
        expect(copied.date, equals(testExpense.date));
        expect(copied.note, equals(testExpense.note));
      });
    });

    group('ExpenseCategory Tests', () {
      test('should have correct display names', () {
        expect(ExpenseCategory.comida.displayName, equals('Comida'));
        expect(ExpenseCategory.transporte.displayName, equals('Transporte'));
        expect(ExpenseCategory.deudas.displayName, equals('Deudas'));
        expect(ExpenseCategory.compras.displayName, equals('Compras'));
        expect(ExpenseCategory.otros.displayName, equals('Otros'));
      });

      test('should have correct emojis', () {
        expect(ExpenseCategory.comida.emoji, equals('🍽️'));
        expect(ExpenseCategory.transporte.emoji, equals('🚗'));
        expect(ExpenseCategory.deudas.emoji, equals('💳'));
        expect(ExpenseCategory.compras.emoji, equals('🛍️'));
        expect(ExpenseCategory.otros.emoji, equals('📦'));
      });

      test('should have all 5 categories', () {
        expect(ExpenseCategory.values.length, equals(5));
      });
    });

    group('Category Suggestion Logic', () {
      test('should suggest deudas for amounts >= 200000', () {
        expect(Expense.suggestCategory(200000), equals(ExpenseCategory.deudas));
        expect(Expense.suggestCategory(500000), equals(ExpenseCategory.deudas));
        expect(
            Expense.suggestCategory(1000000), equals(ExpenseCategory.deudas));
      });

      test('should suggest compras for amounts >= 100000 and < 200000', () {
        expect(
            Expense.suggestCategory(100000), equals(ExpenseCategory.compras));
        expect(
            Expense.suggestCategory(150000), equals(ExpenseCategory.compras));
        expect(
            Expense.suggestCategory(199999), equals(ExpenseCategory.compras));
      });

      test('should suggest comida for amounts >= 50000 and < 100000', () {
        expect(Expense.suggestCategory(50000), equals(ExpenseCategory.comida));
        expect(Expense.suggestCategory(75000), equals(ExpenseCategory.comida));
        expect(Expense.suggestCategory(99999), equals(ExpenseCategory.comida));
      });

      test('should suggest transporte for amounts < 50000', () {
        expect(Expense.suggestCategory(0), equals(ExpenseCategory.transporte));
        expect(
            Expense.suggestCategory(25000), equals(ExpenseCategory.transporte));
        expect(
            Expense.suggestCategory(49999), equals(ExpenseCategory.transporte));
      });

      test('should handle edge cases', () {
        expect(Expense.suggestCategory(49999.99),
            equals(ExpenseCategory.transporte));
        expect(
            Expense.suggestCategory(50000.01), equals(ExpenseCategory.comida));
        expect(
            Expense.suggestCategory(99999.99), equals(ExpenseCategory.comida));
        expect(Expense.suggestCategory(100000.01),
            equals(ExpenseCategory.compras));
        expect(Expense.suggestCategory(199999.99),
            equals(ExpenseCategory.compras));
        expect(
            Expense.suggestCategory(200000.01), equals(ExpenseCategory.deudas));
      });
    });

    group('JSON Serialization', () {
      late Expense testExpense;
      late DateTime testDate;

      setUp(() {
        testDate = DateTime(2024, 1, 15, 10, 30);
        testExpense = Expense(
          id: 'json-test-id',
          amount: 125000.0,
          category: ExpenseCategory.compras,
          date: testDate,
          note: 'Test note for JSON',
        );
      });

      test('should serialize to JSON correctly', () {
        final json = testExpense.toJson();

        expect(json['id'], equals('json-test-id'));
        expect(json['amount'], equals(125000.0));
        expect(json['category'], equals('compras'));
        expect(json['date'], equals(testDate.millisecondsSinceEpoch));
        expect(json['note'], equals('Test note for JSON'));
      });

      test('should serialize to JSON without note', () {
        final expenseWithoutNote = Expense(
          id: 'no-note-id',
          amount: 50000.0,
          category: ExpenseCategory.comida,
          date: testDate,
        );

        final json = expenseWithoutNote.toJson();

        expect(json['id'], equals('no-note-id'));
        expect(json['amount'], equals(50000.0));
        expect(json['category'], equals('comida'));
        expect(json['date'], equals(testDate.millisecondsSinceEpoch));
        expect(json['note'], isNull);
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'id': 'from-json-id',
          'amount': 75000.0,
          'category': 'transporte',
          'date': testDate.millisecondsSinceEpoch,
          'note': 'Deserialized note',
        };

        final expense = Expense.fromJson(json);

        expect(expense.id, equals('from-json-id'));
        expect(expense.amount, equals(75000.0));
        expect(expense.category, equals(ExpenseCategory.transporte));
        expect(expense.date, equals(testDate));
        expect(expense.note, equals('Deserialized note'));
      });

      test('should deserialize from JSON without note', () {
        final json = {
          'id': 'no-note-from-json',
          'amount': 30000.0,
          'category': 'otros',
          'date': testDate.millisecondsSinceEpoch,
          'note': null,
        };

        final expense = Expense.fromJson(json);

        expect(expense.id, equals('no-note-from-json'));
        expect(expense.amount, equals(30000.0));
        expect(expense.category, equals(ExpenseCategory.otros));
        expect(expense.date, equals(testDate));
        expect(expense.note, isNull);
      });

      test('should handle unknown category gracefully', () {
        final json = {
          'id': 'unknown-category-id',
          'amount': 40000.0,
          'category': 'categoria_inexistente',
          'date': testDate.millisecondsSinceEpoch,
          'note': 'Unknown category test',
        };

        final expense = Expense.fromJson(json);

        expect(expense.category, equals(ExpenseCategory.otros));
        expect(expense.id, equals('unknown-category-id'));
        expect(expense.amount, equals(40000.0));
      });

      test('should handle integer amount in JSON', () {
        final json = {
          'id': 'integer-amount-id',
          'amount': 60000, // Integer instead of double
          'category': 'comida',
          'date': testDate.millisecondsSinceEpoch,
          'note': 'Integer amount test',
        };

        final expense = Expense.fromJson(json);

        expect(expense.amount, equals(60000.0));
        expect(expense.id, equals('integer-amount-id'));
      });

      test('should round-trip serialize and deserialize correctly', () {
        final json = testExpense.toJson();
        final deserializedExpense = Expense.fromJson(json);

        expect(deserializedExpense, equals(testExpense));
        expect(deserializedExpense.id, equals(testExpense.id));
        expect(deserializedExpense.amount, equals(testExpense.amount));
        expect(deserializedExpense.category, equals(testExpense.category));
        expect(deserializedExpense.date, equals(testExpense.date));
        expect(deserializedExpense.note, equals(testExpense.note));
      });
    });
  });
}
