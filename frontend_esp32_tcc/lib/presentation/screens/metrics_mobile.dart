import 'package:dashboard_flutter/constants.dart';
import 'package:dashboard_flutter/widgets/metrics.dart';
import 'package:flutter/material.dart';


/// Página de métricas para dispositivos móveis.
///
/// Esta página exibe as métricas em um layout adequado para dispositivos móveis.
/// Inclui um botão para voltar à tela anterior e um widget de métricas.
class MetricsMobilePage extends StatelessWidget {
  /// Cria uma instância de [MetricsMobilePage].
  const MetricsMobilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: primaryColor,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.black,
                ),
              ),
              const Expanded(child: Metrics())
            ]),
          ),
        ),
      ),
    );
  }
}
