import 'package:dashboard_flutter/cubit/HTTPCubit/http_cubit.dart';
import 'package:dashboard_flutter/cubit/RegisterCubit/register_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Um widget de campo de pesquisa com um dropdown para filtragem.
///
/// Este widget permite ao usuário buscar e filtrar dados com base em diferentes
/// critérios. Ele utiliza o `RegisterCubit` para gerenciar o estado do filtro
/// selecionado e o `HttpCubit` para realizar a busca com base no texto e no filtro selecionado.
class SearchField extends StatelessWidget {
  /// Cria uma instância do [SearchField].
  const SearchField({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    /// Converte uma lista de colunas em uma lista de itens do dropdown.
    ///
    /// [columnsList] Lista de nomes das colunas a serem usadas no dropdown.
    /// Retorna uma lista de itens para o dropdown com base nas colunas fornecidas.
    List<DropdownMenuItem<String>> getDropDownItems(List<dynamic> columnsList) {
      return columnsList.map((column) {
        return DropdownMenuItem<String>(
          value: column,
          child: Text(column),
        );
      }).toList();
    }

    // Lista de opções para o dropdown de filtro.
    List<String> columnList = [
      'Sem filtro',
      'Id da Placa',
      'Nome do Local',
      'Temperatura',
      'TDS',
      'Turbidez',
      'pH',
    ];

    // Mapeia os nomes das colunas para suas respectivas chaves de consulta.
    Map<String, String> queryList = {
      'Sem filtro': '',
      'Id da Placa': 'id_placa',
      'Nome do Local': 'local',
      'Temperatura': 'temperature',
      'TDS': 'tds',
      'Turbidez': 'turbidity',
      'pH': 'ph',
    };

    var searchController = TextEditingController();

    return BlocBuilder<RegisterCubit, RegisterState>(builder: (context, state) {
      RegisterCubit registerCubit = BlocProvider.of<RegisterCubit>(context);
      HttpCubit httpCubit = BlocProvider.of<HttpCubit>(context);

      return TextField(
        controller: searchController,
        onSubmitted: (value) {
          if (searchController.text.isNotEmpty) {
            httpCubit.fetchNodeData(
                "${queryList[registerCubit.selectedColumn]!}=${searchController.text}");
          } else {
            httpCubit.fetchNodeData();
          }
        },
        decoration: InputDecoration(
          hoverColor: Colors.transparent,
          hintText: "Search",
          fillColor: Colors.white,
          filled: true,
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          prefixIcon: InkWell(
            onTap: () {
              if (searchController.text.isNotEmpty) {
                httpCubit.fetchNodeData(
                    "${queryList[registerCubit.selectedColumn]!}=${searchController.text}");
              } else {
                httpCubit.fetchNodeData();
              }
            },
            child: const Icon(Icons.search),
          ),
          suffixIcon: SizedBox(
            height: 25,
            child: DropdownButton<String>(
              focusColor: Colors.transparent,
              value: registerCubit.selectedColumn,
              items: getDropDownItems(columnList),
              onChanged: (value) {
                registerCubit.changeSelectedColumn(value!);
              },
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.black,
              ),
              iconSize: 30,
              underline: const SizedBox(),
            ),
          ),
        ),
      );
    });
  }
}
