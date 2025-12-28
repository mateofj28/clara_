import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sección de presupuesto
          _buildSectionHeader(context, 'Presupuesto'),
          _buildSettingCard(
            context,
            icon: Icons.account_balance_wallet_outlined,
            title: 'Presupuesto mensual',
            subtitle: 'Configura tu límite mensual',
            onTap: () => _showComingSoon(context),
          ),
          
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
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
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