import 'package:clara/core/utils/currency_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CurrencyFormatter Tests', () {
    group('Format Method', () {
      test('should format simple amounts correctly', () {
        expect(CurrencyFormatter.format(0), equals('\$0'));
        expect(CurrencyFormatter.format(1), equals('\$1'));
        expect(CurrencyFormatter.format(100), equals('\$100'));
        expect(CurrencyFormatter.format(999), equals('\$999'));
      });

      test('should format thousands with comma separator', () {
        expect(CurrencyFormatter.format(1000), equals('\$1,000'));
        expect(CurrencyFormatter.format(1234), equals('\$1,234'));
        expect(CurrencyFormatter.format(9999), equals('\$9,999'));
        expect(CurrencyFormatter.format(10000), equals('\$10,000'));
        expect(CurrencyFormatter.format(50000), equals('\$50,000'));
        expect(CurrencyFormatter.format(99999), equals('\$99,999'));
      });

      test('should format millions with comma separators', () {
        expect(CurrencyFormatter.format(100000), equals('\$100,000'));
        expect(CurrencyFormatter.format(123456), equals('\$123,456'));
        expect(CurrencyFormatter.format(1000000), equals('\$1,000,000'));
        expect(CurrencyFormatter.format(1234567), equals('\$1,234,567'));
        expect(CurrencyFormatter.format(12345678), equals('\$12,345,678'));
      });

      test('should handle decimal amounts by converting to integer', () {
        expect(CurrencyFormatter.format(1234.56), equals('\$1,234'));
        expect(CurrencyFormatter.format(1234.99), equals('\$1,234'));
        expect(CurrencyFormatter.format(999.01), equals('\$999'));
        expect(CurrencyFormatter.format(1000.99), equals('\$1,000'));
      });

      test('should handle negative amounts', () {
        expect(CurrencyFormatter.format(-100), equals('\$-100'));
        expect(CurrencyFormatter.format(-1234), equals('\$-1,234'));
        expect(CurrencyFormatter.format(-1000000), equals('\$-1,000,000'));
      });

      test('should handle edge cases', () {
        expect(CurrencyFormatter.format(0.0), equals('\$0'));
        expect(CurrencyFormatter.format(0.99), equals('\$0'));
        expect(CurrencyFormatter.format(999.99), equals('\$999'));
        expect(CurrencyFormatter.format(1000.01), equals('\$1,000'));
      });

      test('should handle large amounts', () {
        expect(CurrencyFormatter.format(999999999), equals('\$999,999,999'));
        expect(CurrencyFormatter.format(1000000000), equals('\$1,000,000,000'));
      });
    });

    group('Parse Method', () {
      test('should parse simple formatted amounts', () {
        expect(CurrencyFormatter.parse('\$0'), equals(0.0));
        expect(CurrencyFormatter.parse('\$1'), equals(1.0));
        expect(CurrencyFormatter.parse('\$100'), equals(100.0));
        expect(CurrencyFormatter.parse('\$999'), equals(999.0));
      });

      test('should parse amounts with comma separators', () {
        expect(CurrencyFormatter.parse('\$1,000'), equals(1000.0));
        expect(CurrencyFormatter.parse('\$1,234'), equals(1234.0));
        expect(CurrencyFormatter.parse('\$50,000'), equals(50000.0));
        expect(CurrencyFormatter.parse('\$123,456'), equals(123456.0));
        expect(CurrencyFormatter.parse('\$1,000,000'), equals(1000000.0));
        expect(CurrencyFormatter.parse('\$1,234,567'), equals(1234567.0));
      });

      test('should parse negative amounts', () {
        expect(CurrencyFormatter.parse('\$-100'), equals(-100.0));
        expect(CurrencyFormatter.parse('\$-1,234'), equals(-1234.0));
        expect(CurrencyFormatter.parse('\$-1,000,000'), equals(-1000000.0));
      });

      test('should handle amounts without dollar sign', () {
        expect(CurrencyFormatter.parse('1,000'), equals(1000.0));
        expect(CurrencyFormatter.parse('123,456'), equals(123456.0));
        expect(CurrencyFormatter.parse('1000'), equals(1000.0));
      });

      test('should return 0 for invalid formats', () {
        expect(CurrencyFormatter.parse(''), equals(0.0));
        expect(CurrencyFormatter.parse('abc'), equals(0.0));
        expect(CurrencyFormatter.parse('\$abc'), equals(0.0));
        expect(CurrencyFormatter.parse('not-a-number'), equals(0.0));
      });

      test('should handle edge cases', () {
        expect(CurrencyFormatter.parse('\$0'), equals(0.0));
        expect(CurrencyFormatter.parse('\$'), equals(0.0));
        expect(CurrencyFormatter.parse(','), equals(0.0));
        expect(CurrencyFormatter.parse('\$,'), equals(0.0));
      });
    });

    group('IsValid Method', () {
      test('should validate correct formats', () {
        expect(CurrencyFormatter.isValid('\$0'), isTrue);
        expect(CurrencyFormatter.isValid('\$100'), isTrue);
        expect(CurrencyFormatter.isValid('\$1,000'), isTrue);
        expect(CurrencyFormatter.isValid('\$123,456'), isTrue);
        expect(CurrencyFormatter.isValid('\$1,000,000'), isTrue);
      });

      test('should validate formats without dollar sign', () {
        expect(CurrencyFormatter.isValid('100'), isTrue);
        expect(CurrencyFormatter.isValid('1,000'), isTrue);
        expect(CurrencyFormatter.isValid('123,456'), isTrue);
      });

      test('should validate negative amounts', () {
        expect(CurrencyFormatter.isValid('\$-100'), isTrue);
        expect(CurrencyFormatter.isValid('\$-1,234'), isTrue);
        expect(CurrencyFormatter.isValid('-1000'), isTrue);
      });

      test('should invalidate incorrect formats', () {
        expect(CurrencyFormatter.isValid(''), isFalse);
        expect(CurrencyFormatter.isValid('abc'), isFalse);
        expect(CurrencyFormatter.isValid('\$abc'), isFalse);
        expect(CurrencyFormatter.isValid('not-a-number'), isFalse);
        expect(CurrencyFormatter.isValid('\$'), isFalse);
        expect(CurrencyFormatter.isValid(','), isFalse);
      });

      test('should handle edge cases', () {
        expect(CurrencyFormatter.isValid('0'), isTrue);
        expect(CurrencyFormatter.isValid('\$0'), isTrue);
        expect(CurrencyFormatter.isValid('0.0'), isTrue);
        expect(CurrencyFormatter.isValid('\$0.0'), isTrue);
      });
    });

    group('Round-trip Format and Parse', () {
      test('should maintain consistency between format and parse', () {
        final testAmounts = [
          0.0,
          1.0,
          100.0,
          999.0,
          1000.0,
          1234.0,
          50000.0,
          123456.0,
          1000000.0,
          1234567.0,
          999999999.0
        ];

        for (final amount in testAmounts) {
          final formatted = CurrencyFormatter.format(amount);
          final parsed = CurrencyFormatter.parse(formatted);
          expect(parsed, equals(amount.toInt().toDouble()),
              reason: 'Failed for amount: $amount');
        }
      });

      test('should validate all formatted amounts', () {
        final testAmounts = [
          0.0,
          1.0,
          100.0,
          999.0,
          1000.0,
          1234.0,
          50000.0,
          123456.0,
          1000000.0,
          1234567.0
        ];

        for (final amount in testAmounts) {
          final formatted = CurrencyFormatter.format(amount);
          expect(CurrencyFormatter.isValid(formatted), isTrue,
              reason: 'Formatted amount should be valid: $formatted');
        }
      });
    });
  });
}
