import 'package:dashboard_flutter/cubit/CalibrationCubit/calibration_cubit.dart';
import 'package:dashboard_flutter/cubit/OTACubit/ota_cubit.dart';
import 'package:flutter/material.dart';
import 'package:dashboard_flutter/constants.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CalibrationPage extends StatefulWidget {
  const CalibrationPage({super.key});

  @override
  State<CalibrationPage> createState() => _CalibrationPageState();
}

class _CalibrationPageState extends State<CalibrationPage> {
  @override
  Widget build(BuildContext context) {
    var idplacaController = TextEditingController();
    var tdsExpectedValueController = TextEditingController();
    CalibrationCubit calibrationCubit = BlocProvider.of<CalibrationCubit>(context);

    return Material(
      child: SafeArea(
        child: Container(
          color: primaryColor,
          child: Stack(
            children: [
               Positioned(
                    top: 16.0,
                    left: 16.0,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.black,
                      ),
                    ),
                  ),
              BlocConsumer<CalibrationCubit, CalibrationState>(
                listener: (context, state) {
                  if (state is CalibrationDone) {
                    Fluttertoast.showToast(
                        webBgColor: "linear-gradient(to right, #FEFFBA, #FEFFBA)",
                        webPosition: "center",
                        backgroundColor: Colors.yellow[200],
                        textColor: Colors.black,
                        msg: state.calibrationMessage,
                        timeInSecForIosWeb: 5,
                        toastLength: Toast.LENGTH_LONG);
                      calibrationCubit.resetCalibrationState();
                  } else if (state is CalibrationSent) {
                    calibrationCubit.clearPhExpectedValue();
                    idplacaController.clear();
                    tdsExpectedValueController.clear();
                    Fluttertoast.showToast(
                        webBgColor: "linear-gradient(to right, #dbead5, #dbead5)",
                        webPosition: "center",
                        backgroundColor: Colors.green[200],
                        textColor: Colors.black,
                        msg: "Dados da calibracao enviados.",
                        timeInSecForIosWeb: 5,
                        toastLength: Toast.LENGTH_LONG);
                  } else if (state is CalibrationError) {
                    Fluttertoast.showToast(
                        webBgColor: "linear-gradient(to right, #FFBEBE, #FFBEBE)",
                        webPosition: "center",
                        backgroundColor: Colors.red[300],
                        textColor: Colors.black,
                        msg: state.calibrationError,
                        timeInSecForIosWeb: 5,
                        toastLength: Toast.LENGTH_LONG);
                  }
                },
                builder: (context, state) {
                  return Center(
                    child: Container(
                      width: 300,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Campo ID da placa
                          TextField(
                            controller: idplacaController,
                            decoration: const InputDecoration(
                              labelText: 'ID da Placa',
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Dropdown: pH ou TDS
                          DropdownButtonFormField<String>(
                            value: calibrationCubit.selectedCalibration,
                            items: const [
                              DropdownMenuItem(value: 'pH', child: Text('Calibrar pH')),
                              DropdownMenuItem(value: 'TDS', child: Text('Calibrar TDS')),
                            ],
                            onChanged: (value) {
                              calibrationCubit.updateSelectedCalibration(value!);
                            },
                            decoration: const InputDecoration(labelText: 'Tipo de calibração'),
                          ),
                          const SizedBox(height: 16),

                          // Se for pH, mostra checkboxes
                          if (calibrationCubit.selectedCalibration == 'pH') ...[
                            _createCheckBox("6.86", calibrationCubit),
                            _createCheckBox("9.18", calibrationCubit),
                          ],

                          // Se for TDS, mostra campo de texto
                          if (calibrationCubit.selectedCalibration == 'TDS') ...[
                            TextField(
                              controller: tdsExpectedValueController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: const InputDecoration(
                                labelText: 'Valor TDS esperado',
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),

                          // Botão de envio
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.black,
                            ),
                            onPressed: () {
                              final id = idplacaController.text.trim();
                              if (id.isEmpty) {
                                Fluttertoast.showToast(
                                  webBgColor: "linear-gradient(to right, #FFBEBE, #FFBEBE)",
                                  webPosition: "center",
                                  backgroundColor: Colors.red[300],
                                  textColor: Colors.black,
                                  msg: "ID da placa obrigatório.",
                                  timeInSecForIosWeb: 5,
                                  toastLength: Toast.LENGTH_LONG);
                                return;
                              }

                              if (calibrationCubit.selectedCalibration == 'pH') {
                                final phSelected = calibrationCubit.getSelectedPhValue();
                                if (phSelected != null) {
                                  calibrationCubit.sendCalibrationData(id, double.tryParse(phSelected), null);
                                } else {
                                  Fluttertoast.showToast(
                                    webBgColor: "linear-gradient(to right, #FFBEBE, #FFBEBE)",
                                    webPosition: "center",
                                    backgroundColor: Colors.red[300],
                                    textColor: Colors.black,
                                    msg: "Selecione um valor de pH para calibrar.",
                                    timeInSecForIosWeb: 5,
                                    toastLength: Toast.LENGTH_LONG);
                                }
                                
                              } else {  
                                final tdsText = tdsExpectedValueController.text.trim();
                                if (tdsText.isEmpty) {
                                  Fluttertoast.showToast(
                                    webBgColor: "linear-gradient(to right, #FFBEBE, #FFBEBE)",
                                    webPosition: "center",
                                    backgroundColor: Colors.red[300],
                                    textColor: Colors.black,
                                    msg: "Informe o valor de TDS.",
                                    timeInSecForIosWeb: 5,
                                    toastLength: Toast.LENGTH_LONG);
                                  return;
                                }
                                final tdsValue = double.tryParse(tdsText);
                                if (tdsValue == null) {
                                  Fluttertoast.showToast(
                                    webBgColor: "linear-gradient(to right, #FFBEBE, #FFBEBE)",
                                    webPosition: "center",
                                    backgroundColor: Colors.red[300],
                                    textColor: Colors.black,
                                    msg: "Valor de TDS inválido.",
                                    timeInSecForIosWeb: 5,
                                    toastLength: Toast.LENGTH_LONG);
                                  return;
                                }
                                calibrationCubit.sendCalibrationData(id, null, tdsValue);
                              }
                            },
                            child: const Text("Enviar Calibração"),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

BlocBuilder<CalibrationCubit, CalibrationState> _createCheckBox(String sensorValue, CalibrationCubit calibrationCubit) {
  return BlocBuilder<CalibrationCubit, CalibrationState>(builder: (context, state) {
    return Row(
      children: [
        Checkbox(
          checkColor: Colors.black,
          fillColor: WidgetStateProperty.resolveWith(getColor),
          value: calibrationCubit.phExpectedValues[sensorValue],
          onChanged: (bool? value) {
            calibrationCubit.setPhValueChecked(sensorValue, value!);
          },
        ),
        Text(sensorValue)
      ],
    );
  });
}

/// Retorna a cor de preenchimento para a caixa de seleção com base no estado.
///
/// Utiliza o [primaryColor] como cor padrão e uma cor cinza para estados interativos
/// como pressionado, focado e sobreposto.
Color getColor(Set<WidgetState> states) {
  const Set<WidgetState> interactiveStates = <WidgetState>{
    WidgetState.pressed,
    WidgetState.hovered,
    WidgetState.focused,
  };
  if (states.any(interactiveStates.contains)) {
    return Colors.grey.shade300;
  }
  return primaryColor;
}
