import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/expense.dart';
import '../../../domain/entities/expense_summary.dart';
import '../../bloc/expense_bloc.dart';
import '../../bloc/expense_event.dart';
import '../../bloc/expense_state.dart';
import '../../widgets/expense_state_widgets.dart';

class MonthlySummaryPage extends StatefulWidget {
  const MonthlySummaryPage({super.key});

  @override
  State<MonthlySummaryPage> createState() => _MonthlySummaryPageState();
}

class _MonthlySummaryPageState extends State<MonthlySummaryPage> {
  @override
  void initState() {
    super.initState();
    // Cargar gastos si es necesario
    context.read<ExpenseBloc>().add(const LoadExpenses());
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
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        if (state is ExpenseLoading) {
          return const ExpenseLoadingWidget(
            message: 'Cargando resumen mensual...',
          );
        }

        if (state is ExpenseError) {
          return ExpenseErrorWidget(
            message: state.message,
            onRetry: () =>
                context.read<ExpenseBloc>().add(const LoadExpenses()),
          );
        }

        if (state is ExpenseLoaded) {
          return _buildSummaryContent(state.summary);
        }

        if (state is ExpenseOperationSuccess && state.summary != null) {
          return _buildSummaryContent(state.summary!);
        }

        return _buildEmptyContent();
      },
    );
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
                  CurrencyFormatter.format(summary.totalMonth),
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

          // Interpretación (segundo después del header)
          if (summary.totalMonth > 0) ...[
            _buildInterpretation(summary),
            const SizedBox(height: 32),
          ],

          if (summary.totalMonth > 0) ...[
            // Gráfico de barras apiladas
            _buildStackedBarChart(summary),
            const SizedBox(height: 32),

            // Desglose por categorías (después de distribución visual)
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

            // Tarjetas de categorías (sin barras de progreso)
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
      _getCategoryColor(category).withValues(alpha: 0.1),
      _getCategoryColor(category).withValues(alpha: 0.2),
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
      child: Padding(
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
                  color: _getCategoryColor(category).withValues(alpha: 0.3),
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.format(amount),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: _getCategoryColor(category),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${percentage.toStringAsFixed(1)}% del total',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                color: _getCategoryColor(category).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _getCategoryColor(category),
                        fontWeight: FontWeight.w700,
                      ),
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

  // Método para obtener colores únicos para cada categoría
  Color _getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.comida:
        return const Color(0xFF4CAF50); // Verde
      case ExpenseCategory.transporte:
        return const Color(0xFF2196F3); // Azul
      case ExpenseCategory.deudas:
        return const Color(0xFFF44336); // Rojo
      case ExpenseCategory.compras:
        return const Color(0xFFE91E63); // Rosa
      case ExpenseCategory.otros:
        return const Color(0xFF795548); // Marrón
    }
  }

  // Widget para el gráfico de barras apiladas
  Widget _buildStackedBarChart(ExpenseSummary summary) {
    final categories = summary.categoryTotals.entries
        .where((entry) => entry.value > 0)
        .toList()
      ..sort((a, b) =>
          b.value.compareTo(a.value)); // Ordenar por valor descendente

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.donut_small,
                  color: AppTheme.primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Distribución visual',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Barra apilada principal con animación
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1200),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Container(
                height: 32,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppTheme.backgroundGrey.withValues(alpha: 0.3),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Row(
                        children: categories.asMap().entries.map((mapEntry) {
                          final index = mapEntry.key;
                          final entry = mapEntry.value;
                          final percentage =
                              (summary.categoryPercentages[entry.key] ?? 0)
                                  .clamp(0.0, 100.0);
                          final animatedPercentage =
                              (percentage * value).clamp(0.0, 100.0);

                          // Calcular ancho de forma más segura
                          final maxWidth = constraints.maxWidth;
                          final calculatedWidth =
                              maxWidth * (animatedPercentage / 100);
                          final safeWidth =
                              calculatedWidth.clamp(0.0, maxWidth);

                          // Si el ancho es muy pequeño, no mostrar la barra
                          if (safeWidth < 1.0) {
                            return const SizedBox.shrink();
                          }

                          return AnimatedContainer(
                            duration:
                                Duration(milliseconds: 800 + (index * 200)),
                            curve: Curves.easeOutBack,
                            width: safeWidth,
                            height: 32,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _getCategoryColor(entry.key),
                                  _getCategoryColor(entry.key)
                                      .withValues(alpha: 0.8),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _getCategoryColor(entry.key)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Leyenda mejorada con animación
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1000),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Wrap(
                spacing: 16,
                runSpacing: 12,
                children: categories.asMap().entries.map((mapEntry) {
                  final index = mapEntry.key;
                  final entry = mapEntry.value;
                  final percentage =
                      summary.categoryPercentages[entry.key] ?? 0;

                  return Transform.scale(
                    scale: value,
                    child: Transform.translate(
                      offset: Offset(0.0, (1 - value) * 20),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 600 + (index * 100)),
                        curve: Curves.easeOutBack,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(entry.key)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _getCategoryColor(entry.key)
                                  .withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(entry.key),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getCategoryColor(entry.key)
                                          .withValues(alpha: 0.4),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                entry.key.emoji,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                entry.key.displayName,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(entry.key),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${percentage.toStringAsFixed(0)}%',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 16),

          // Información adicional con animación
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1400),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryGreen.withValues(alpha: 0.05),
                        AppTheme.primaryGreen.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.insights,
                        color: AppTheme.primaryGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Total: ${CurrencyFormatter.format(summary.totalMonth)} distribuido en ${categories.length} categoría${categories.length > 1 ? 's' : ''}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.primaryGreen,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
