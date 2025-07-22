import 'package:flutter/material.dart';


/// Um widget de barra que exibe um gráfico de barra baseado em dados fornecidos.
///
/// Este widget exibe um gráfico de barra horizontal que representa visualmente
/// os dados em relação a um valor máximo. O título do gráfico é exibido junto com
/// a unidade de medida apropriada (temperatura, umidade ou iluminação).
class BarWidget extends StatefulWidget {
  const BarWidget(
      {super.key,
      required this.title,
      required this.dataList,
      required this.maxValue});

  /// O título do gráfico. Usado para determinar a unidade de medida e 
  /// exibir a legenda.
  final String title;

  /// Lista de dados a serem exibidos no gráfico. O último valor não nulo 
  /// é utilizado para calcular o tamanho da barra.
  final List<dynamic> dataList;

  /// O valor máximo para calcular a porcentagem da barra. Valores maiores
  /// que [maxValue] serão representados como 100% da largura da barra.
  final double maxValue;

  @override
  State<BarWidget> createState() => _BarWidgetState();
}

class _BarWidgetState extends State<BarWidget> {
  late double data;
  late double barPercentage;
  late String unidade;

  @override
  void initState() {
    super.initState();

    // Inicializa o valor de dados com o último valor não nulo da lista de dados.
    if (widget.dataList.where((element) => element != null).toList().isEmpty) {
      data = 0;
    } else {
      data = widget.dataList.lastWhere((element) => element != null).toDouble();
    }

    // Calcula a porcentagem da barra com base no valor de dados e no valor máximo.
    if(data > widget.maxValue){
      barPercentage = 1;
    } else{
      barPercentage = data / widget.maxValue;
    }
    
    // Define a unidade de medida com base no título do gráfico.
    if (widget.title.contains("Temperatura")){
      unidade = "°C";
    } else if (widget.title.contains("Turbidez")){
      unidade = "%";
    } else if (widget.title.contains("TDS")){
      unidade = "ppm";
    } else if (widget.title.contains("pH")){
      unidade = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double barWidth = constraints.maxWidth*0.9;
        return Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${widget.title} ${unidade == "" ? "" : '($unidade)'}"),
              const SizedBox(
                height: 5,
              ),
              Container(
                width: barWidth,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(5),
                        bottomLeft: Radius.circular(5),
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      // curve: Curves.linear,
                      // duration: const Duration(seconds: 1),
                      width: barPercentage * (barWidth),
                      height: 25,
                      decoration: BoxDecoration(
                          color: Colors.cyan.shade400,
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(5),
                              bottomLeft: Radius.circular(5),
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10))),
                      child: Center(child: Text("$data")),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}
