import 'package:equatable/equatable.dart';

enum ExpenseCategory {
  comida('Comida', '🍽️'),
  transporte('Transporte', '🚗'),
  deudas('Deudas', '💳'),
  compras('Compras', '🛍️'),
  otros('Otros', '📦');

  const ExpenseCategory(this.displayName, this.emoji);

  final String displayName;
  final String emoji;
}

class Expense extends Equatable {
  final String id;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final String? note;

  const Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
  });

  Expense copyWith({
    String? id,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
    String? note,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [id, amount, category, date, note];

  // Lógica de sugerencia de categoría
  static ExpenseCategory suggestCategory(double amount) {
    if (amount >= 200000) {
      return ExpenseCategory.deudas;
    } else if (amount >= 100000) {
      return ExpenseCategory.compras;
    } else if (amount >= 50000) {
      return ExpenseCategory.comida;
    } else {
      return ExpenseCategory.transporte;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'category': category.name,
      'date': date.millisecondsSinceEpoch,
      'note': note,
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      amount: json['amount'].toDouble(),
      category: ExpenseCategory.values.firstWhere(
        (cat) => cat.name == json['category'],
        orElse: () => ExpenseCategory.otros,
      ),
      date: DateTime.fromMillisecondsSinceEpoch(json['date']),
      note: json['note'],
    );
  }
}
