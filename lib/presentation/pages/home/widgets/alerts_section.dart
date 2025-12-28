import 'package:flutter/material.dart';

import '../../../../core/services/audio_service.dart';

class AlertsSection extends StatefulWidget {
  final List<String> alerts;

  const AlertsSection({
    super.key,
    required this.alerts,
  });

  @override
  State<AlertsSection> createState() => _AlertsSectionState();
}

class _AlertsSectionState extends State<AlertsSection> {
  final AudioService _audioService = AudioService();
  List<String> _previousAlerts = [];

  @override
  void initState() {
    super.initState();
    _previousAlerts = List.from(widget.alerts);
    // Reproducir sonido si hay alertas
    if (widget.alerts.isNotEmpty) {
      _playAlertSound();
    }
  }

  @override
  void didUpdateWidget(AlertsSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Verificar si hay nuevas alertas
    if (widget.alerts.length > _previousAlerts.length) {
      print('🔊 AUDIO: Nuevas alertas detectadas, reproduciendo sonido');
      _playAlertSound();
    }
    _previousAlerts = List.from(widget.alerts);
  }

  void _playAlertSound() async {
    // Usar el servicio de audio mejorado
    await _audioService.playAlertSound();

    // Como el audio no funciona en MIUI, mostrar alerta visual
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.notifications_active, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '🚨 NUEVA ALERTA: Revisa tus gastos',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          duration: Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'VER',
            textColor: Colors.white,
            onPressed: () {
              // Cerrar el snackbar
            },
          ),
        ),
      );
    }

    // Debug: imprimir en consola para verificar que se ejecuta
    print(
        '🔊 AUDIO: Intentando reproducir sonido de alerta - Total alertas: ${widget.alerts.length}');
  }

  @override
  Widget build(BuildContext context) {
    if (widget.alerts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.notifications_active,
              color: Colors.orange.shade700,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Avisos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...widget.alerts.map((alert) => _buildAlertCard(context, alert)),
      ],
    );
  }

  Widget _buildAlertCard(BuildContext context, String alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.orange.shade700,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              alert,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.orange.shade700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
