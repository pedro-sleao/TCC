import 'package:dashboard_flutter/constants.dart';
import 'package:dashboard_flutter/widgets/table.dart';
import 'package:flutter/material.dart';

/// Página de visualização de tabela para dispositivos móveis.
///
/// Esta página exibe uma tabela utilizando o [TableWidget] e fornece um botão para
/// voltar à tela anterior. A página é ajustada para uma visualização amigável em
/// dispositivos móveis.
class TableMobile extends StatefulWidget {
  /// Cria uma instância de [TableMobile].
  const TableMobile({super.key});

  @override
  State<TableMobile> createState() => _TableMobileState();
}

class _TableMobileState extends State<TableMobile> {
  @override
  Widget build(BuildContext context) {
    return Material(
        child: Container(
      color: primaryColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.black,
                ),
              ),
              const Expanded(child: TableWidget()),
            ],
          ),
        ),
      ),
    ));
  }
}
