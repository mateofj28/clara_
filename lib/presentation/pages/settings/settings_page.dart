import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_theme.dart';
import '../../widgets/amount_input_field.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double _monthlyLimit = 1000000; // Límite por defecto: $1,000,000
  final TextEditingController _limitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMonthlyLimit();
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  Future<void> _loadMonthlyLimit() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _monthlyLimit = prefs.getDouble('monthly_limit') ?? 1000000;
      _limitController.text = _monthlyLimit.toInt().toString();
    });
  }

  Future<void> _saveMonthlyLimit(double limit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('monthly_limit', limit);
    setState(() {
      _monthlyLimit = limit;
    });
  }

  String _formatCurrency(double amount) {
    int intAmount = amount.toInt();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Sección de presupuesto
            _buildSectionHeader(context, 'Presupuesto'),
            _buildLimitCard(context),

            const SizedBox(height: 24),

            // Sección PRO
            _buildSectionHeader(context, 'Funciones PRO'),
            _buildSettingCard(
              context,
              icon: Icons.file_download_outlined,
              title: 'Exportar reporte',
              subtitle: 'Descarga tus datos en PDF',
              trailing: _buildProBadge(),
              onTap: () => _showProFeature(context),
            ),
            _buildSettingCard(
              context,
              icon: Icons.history,
              title: 'Historial completo',
              subtitle: 'Accede a todos tus gastos',
              trailing: _buildProBadge(),
              onTap: () => _showProFeature(context),
            ),

            const SizedBox(height: 24),

            // Sección de información
            _buildSectionHeader(context, 'Información'),
            _buildSettingCard(
              context,
              icon: Icons.info_outline,
              title: 'Acerca de CLARA',
              subtitle: 'Versión 1.0.0',
              onTap: () => _showAboutDialog(context),
            ),
            _buildSettingCard(
              context,
              icon: Icons.help_outline,
              title: 'Ayuda y soporte',
              subtitle: 'Preguntas frecuentes',
              onTap: () => _showComingSoon(context),
            ),
            _buildSettingCard(
              context,
              icon: Icons.privacy_tip_outlined,
              title: 'Privacidad',
              subtitle: 'Tus datos se guardan localmente',
              onTap: () => _showPrivacyInfo(context),
            ),

            const SizedBox(height: 32),

            // Botón de actualizar a PRO
            _buildUpgradeButton(context),

            const SizedBox(height: 80), // Espacio para navegación
          ],
        ),
      ),
    );
  }

  Widget _buildLimitCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    color: AppTheme.primaryGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Límite mensual',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Actual: ${_formatCurrency(_monthlyLimit)}',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: AppTheme.primaryGreen,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showLimitDialog(context),
                  icon: const Icon(Icons.edit),
                  style: IconButton.styleFrom(
                    backgroundColor:
                        AppTheme.primaryGreen.withValues(alpha: 0.1),
                    foregroundColor: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Recibirás alertas cuando tus gastos se acerquen a este límite',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLimitDialog(BuildContext context) {
    // Formatear el valor actual con comas para mostrarlo correctamente
    final formattedValue = _formatCurrency(_monthlyLimit).replaceAll('\$', '');
    _limitController.text = formattedValue;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configurar límite mensual'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Establece tu límite de gastos mensual:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            AmountInputField(
              controller: _limitController,
              labelText: 'Límite mensual',
              hintText: '1,000,000',
              helperText: 'Mínimo: \$10,000 - Máximo: \$999,999,999',
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => _saveLimitFromDialog(context),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _saveLimitFromDialog(BuildContext context) {
    final text = _limitController.text.trim();
    if (text.isEmpty) {
      _showErrorSnackBar('Por favor ingresa un valor');
      return;
    }

    // Remover comas del formato antes de parsear
    final cleanText = text.replaceAll(',', '');
    final value = double.tryParse(cleanText);
    if (value == null) {
      _showErrorSnackBar('Valor inválido');
      return;
    }

    // Validar rango
    if (value < 10000) {
      _showErrorSnackBar('El límite mínimo es \$10,000');
      return;
    }

    if (value > 999999999) {
      _showErrorSnackBar('El límite máximo es \$999,999,999');
      return;
    }

    _saveMonthlyLimit(value);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Límite actualizado a ${_formatCurrency(value)}'),
        backgroundColor: AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        textAlign: TextAlign.left,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryGreen,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildProBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'PRO',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildUpgradeButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryGreen,
            AppTheme.primaryGreenDark,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.star,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            'Actualizar a CLARA PRO',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Historial ilimitado y exportación de reportes',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _showComingSoon(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryGreen,
            ),
            child: const Text('Próximamente'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Próximamente'),
        content: const Text(
          'Esta función estará disponible en una próxima actualización.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showProFeature(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Función PRO'),
        content: const Text(
          'Esta función está disponible en CLARA PRO. Actualiza para acceder a todas las funciones premium.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showComingSoon(context);
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'CLARA',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.account_balance_wallet,
          color: Colors.white,
          size: 32,
        ),
      ),
      children: [
        const Text(
          'Control de gastos personales simple y claro.\n\n'
          'CLARA te ayuda a entender en qué gastas tu dinero '
          'de forma rápida y sin complicaciones.',
        ),
      ],
    );
  }

  void _showPrivacyInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tu privacidad'),
        content: const Text(
          'CLARA funciona completamente offline. Todos tus datos se guardan '
          'únicamente en tu dispositivo y nunca se envían a servidores externos.\n\n'
          'Tienes control total sobre tu información financiera.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
