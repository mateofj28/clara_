import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../domain/entities/expense_summary.dart';

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

class ExpenseSummaryCard extends StatelessWidget {
  final ExpenseSummary summary;

  const ExpenseSummaryCard({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total de hoy (principal)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hoy gastaste',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatCurrency(summary.totalToday),
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Divider
            Container(
              height: 1,
              color: AppTheme.dividerGrey,
            ),

            const SizedBox(height: 20),

            // Información secundaria
            Row(
              children: [
                Expanded(
                  child: _buildSecondaryInfo(
                    context,
                    'Este mes',
                    formatCurrency(summary.totalMonth),
                  ),
                ),
                if (summary.topCategory != null) ...[
                  Container(
                    width: 1,
                    height: 40,
                    color: AppTheme.dividerGrey,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSecondaryInfo(
                      context,
                      'Categoría principal',
                      '${summary.topCategory!.emoji} ${summary.topCategory!.displayName}',
                    ),
                  ),
                ],
              ],
            ),

            // Mensaje motivacional
            if (summary.totalToday == 0 && summary.totalMonth > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: AppTheme.primaryGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Vas bien hoy 👍',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryInfo(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
