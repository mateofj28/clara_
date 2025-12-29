import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/di/injection_container.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/expense.dart';
import '../../../domain/entities/expense_summary.dart';
import '../../bloc/expense_bloc.dart';

String formatCurrency(double amount) {
  // Convertir a entero para evitar decimales
  int intAmount = amount.toInt();

  // Formatear manualmente con separadores de miles
  String numStr = intAmount.toString();
  String result = '';

  for (int i = 0; i < numStr.length; i++) {
    if (i > 0 && (numStr.length - i) % 3 == 0) {
      result += ',';
    }
    result += numStr[i];
  }

  return '\$$result';
}

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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
        }
      });
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
    final now = DateTime.now();
    final monthName = DateFormat('MMMM yyyy', 'es_ES').format(now);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con total del mes
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryGreen,
                  AppTheme.primaryGreenDark,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _capitalizeFirst(monthName),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  formatCurrency(summary.totalMonth),
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 36,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total gastado este mes',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Desglose por categorías
          Row(
            children: [
              Icon(
                Icons.pie_chart,
                color: AppTheme.primaryGreen,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Desglose por categorías',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (summary.totalMonth > 0) ...[
            ...summary.categoryTotals.entries
                .where((entry) => entry.value > 0)
                .map((entry) => _buildModernCategoryCard(
                      entry.key,
                      entry.value,
                      summary.categoryPercentages[entry.key] ?? 0,
                      summary.totalMonth,
                    )),
          ] else ...[
            _buildEmptyCategories(),
          ],

          const SizedBox(height: 24),

          // Interpretación
          if (summary.totalMonth > 0) _buildInterpretation(summary),

          const SizedBox(height: 80), // Espacio para navegación
        ],
      ),
    );
  }

  Widget _buildModernCategoryCard(
    ExpenseCategory category,
    double amount,
    double percentage,
    double totalMonth,
  ) {
    // Calcular la intensidad del color basado en el porcentaje
    final intensity = (percentage / 100).clamp(0.0, 1.0);
    final cardColor = Color.lerp(
      AppTheme.primaryGreen.withValues(alpha: 0.1),
      AppTheme.primaryGreen.withValues(alpha: 0.2),
      intensity,
    )!;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Barra de progreso visual
            Container(
              height: 4,
              width: double.infinity,
              color: AppTheme.backgroundGrey,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage / 100,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryGreen,
                        AppTheme.primaryGreenDark,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Contenido de la tarjeta
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Emoji con fondo colorido
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        category.emoji,
                        style: const TextStyle(fontSize: 24),
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
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatCurrency(amount),
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: AppTheme.primaryGreen,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${percentage.toStringAsFixed(1)}% del total',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                  ),

                  // Indicador visual del porcentaje
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${percentage.toStringAsFixed(0)}%',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppTheme.primaryGreen,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    ),
                  ),
                ],
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
    final topPercentage =
        topCategory != null ? summary.categoryPercentages[topCategory] ?? 0 : 0;

    String interpretation = '';
    if (topCategory != null && topPercentage > 0) {
      interpretation =
          '${topCategory.displayName} representa el ${topPercentage.toStringAsFixed(0)}% de tus gastos';
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
