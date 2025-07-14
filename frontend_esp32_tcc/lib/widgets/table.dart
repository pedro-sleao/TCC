import 'package:dashboard_flutter/cubit/HTTPCubit/http_cubit.dart';
import 'package:dashboard_flutter/data/models/placa_data.dart';
import 'package:dashboard_flutter/widgets/searchfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Um widget que exibe uma tabela com os dados dos nós.
///
/// Este widget utiliza o `HttpCubit` para obter os dados dos nós e exibi-los em uma tabela.
/// Inclui um campo de pesquisa no topo da tabela para filtrar os resultados exibidos.
class TableWidget extends StatefulWidget {
  /// Cria uma instância do [TableWidget].
  const TableWidget({super.key});

  @override
  State<TableWidget> createState() => _TableWidgetState();
}

class _TableWidgetState extends State<TableWidget> {
  @override
  Widget build(BuildContext context) {
    List<DataRow> rows = [];

    HttpCubit httpCubit = BlocProvider.of<HttpCubit>(context);

    return BlocBuilder<HttpCubit, HttpState>(builder: (context, state) {
      if (httpCubit.nodeDataList != null) {
        rows = [];
        List<PlacaData>? nodeDataList = httpCubit.nodeDataList;
        for (var data in nodeDataList!) {
          rows.add(_createTableRow(
              data.idPlaca,
              data.localName,
              data.checkStatus,
              data.checkTemp,
              data.checkTds,
              data.checkTurb,
              data.checkPh));
        }
      } else {
        httpCubit.fetchNodeData();
      }
      return Column(
        children: [
          const SizedBox(
            height: 16,
          ),
          const SizedBox(width: 500, child: SearchField()),
          const SizedBox(
            height: 30,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                columnSpacing: 15,
                columns: const <DataColumn>[
                  DataColumn(
                    label: Expanded(
                      child: Text(
                        'ID da Placa',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Expanded(
                      child: Text(
                        'Nome do Local',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ),
                   DataColumn(
                    label: Expanded(
                      child: Text(
                        'Status',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Expanded(
                      child: Text(
                        'Temperatura',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Expanded(
                      child: Text(
                        'TDS',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Expanded(
                      child: Text(
                        'Turbidez',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Expanded(
                      child: Text(
                        'pH',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ),
                ],
                rows: rows,
              ),
            ),
          ),
        ],
      );
    });
  }
}

/// Cria uma linha de dados para a tabela.
///
/// [idPlaca] O identificador da placa.
/// [localName] O nome do local onde a placa está situada.
/// [checkTemp] O status do sensor de temperatura.
/// [checkTds] O status do sensor de TDS.
/// [checkTurb] O status do sensor de turbidez.
/// [checkPh] O status do sensor de pH.
/// [checkStatus] O status da placa.
///
/// Retorna uma instância de [DataRow] contendo os dados fornecidos.
DataRow _createTableRow(
    String idPlaca,
    String? localName,
    bool? checkTemp,
    bool? checkTds,
    bool? checkTurb,
    bool? checkPh,
    bool? checkStatus) {
  return DataRow(
    cells: <DataCell>[
      DataCell(SizedBox(width: 100, child: SelectableText(idPlaca))),
      DataCell(SizedBox(width: 100, child: SelectableText("$localName"))),
      DataCell(SelectableText("$checkTemp")),
      DataCell(SelectableText("$checkTds")),
      DataCell(SelectableText("$checkTurb")),
      DataCell(SelectableText("$checkPh")),
      DataCell(SelectableText("$checkStatus")),
    ],
  );
}
