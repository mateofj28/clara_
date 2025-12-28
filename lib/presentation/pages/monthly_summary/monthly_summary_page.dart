import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/expense.dart';
import '../../../domain/entities/expense_summary.dart';
import '../../bloc/expense_bloc.dart';

class MonthlySummaryPage extends StatefulWidget {
  const MonthlySummaryPage({super.key});

  @override
  State<MonthlySummaryPage> createState() => _MonthlySummaryPageState();
}

class _MonthlySummaryPageState extends State<MonthlySummaryPage> {
  late ExpenseBloc _expenseBloc;

  @override
  void initState() {
    super.initState();
    _expenseBloc = sl.get<ExpenseBloc>();
    _expenseBloc.addListener(_onBlocStateChanged);
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
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen mensual'),
        automaticallyImplyLeading: false,
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    final state = _expenseBloc.state;

    if (state is ExpenseLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryGreen,
        ),
      );
    }

    if (state is ExpenseError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar datos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _expenseBloc.loadExpenses(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (state is ExpenseLoaded) {
      return _buildSummaryContent(state.summary);
    }

    return _buildEmptyContent();
  }

  Widget _buildSummaryContent(ExpenseSummary summary) {
    final currencyFormat = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '\$',
      decimalDigits: 0,
    );

    final now = DateTime.now();
    final monthName = DateFormat('MMMM yyyy', 'es_ES').format(now);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con total del mes
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _capitalizeFirst(monthName),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormat.format(summary.totalMonth),
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total gastado este mes',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Desglose por categorías
          Text(
            'Desglose por categorías',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          if (summary.totalMonth > 0) ...[
            ...summary.categoryTotals.entries
                .where((entry) => entry.value > 0)
                .map((entry) => _buildCategoryCard(
                      entry.key,
                      entry.value,
                      summary.categoryPercentages[entry.key] ?? 0,
                      currencyFormat,
                    )),
          ] else ...[
            _buildEmptyCategories(),
          ],

          const SizedBox(height: 24),

          // Interpretación
          if (summary.totalMonth > 0) _buildInterpretation(summary),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    ExpenseCategory category,
    double amount,
    double percentage,
    NumberFormat currencyFormat,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Emoji e icono
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  category.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Información de la categoría
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.displayName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormat.format(amount),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            // Porcentaje
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.backgroundGrey,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${percentage.toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCategories() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 48,
              color: AppTheme.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Sin gastos este mes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cuando agregues gastos, verás el desglose aquí',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterpretation(ExpenseSummary summary) {
    final topCategory = summary.topCategory;
    final topPercentage = topCategory != null 
        ? summary.categoryPercentages[topCategory] ?? 0 
        : 0;

    String interpretation = '';
    if (topCategory != null && topPercentage > 0) {
      interpretation = '${topCategory.displayName} representa el ${topPercentage.toStringAsFixed(0)}% de tus gastos';
    }

    return Card(
      color: AppTheme.primaryGreen.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: AppTheme.primaryGreen,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Interpretación',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (interpretation.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                interpretation,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_outlined,
            size: 64,
            color: AppTheme.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Sin datos para mostrar',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega algunos gastos para ver tu resumen',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}