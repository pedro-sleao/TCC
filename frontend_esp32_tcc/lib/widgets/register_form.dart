import 'package:dashboard_flutter/constants.dart';
import 'package:dashboard_flutter/cubit/HTTPCubit/http_cubit.dart';
import 'package:dashboard_flutter/cubit/RegisterCubit/register_cubit.dart';
import 'package:dashboard_flutter/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Widget utilizado para realizar o cadastro de novas placas.
/// 
/// Este widget fornece um formulário para inserir dados sobre novas placas e selecionar os sensores
/// associados. Ele usa o `RegisterCubit` para gerenciar o estado do formulário e `HttpCubit`
/// para atualizar os dados dos sensores após o registro.
class RegisterForm extends StatefulWidget {
  /// Cria uma instância do [RegisterForm].
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  @override
  Widget build(BuildContext context) {
    var localNameController = TextEditingController();
    var idplacaController = TextEditingController();

    RegisterCubit registerCubit = BlocProvider.of<RegisterCubit>(context);
    HttpCubit httpCubit = BlocProvider.of<HttpCubit>(context);

    return BlocListener<RegisterCubit, RegisterState>(
      listener: (context, state) {
        if (state is RegisterDone) {
          httpCubit.fetchNodeData();
          registerCubit.clearSensorStates();
          localNameController.clear();
          idplacaController.clear();
          Fluttertoast.showToast(
              webBgColor: "linear-gradient(to right, #dbead5, #dbead5)",
              webPosition: "center",
              backgroundColor: Colors.green[200],
              textColor: Colors.black,
              msg: state.registerMessage,
              timeInSecForIosWeb: 5,
              toastLength: Toast.LENGTH_LONG);
        } else if (state is RegisterError) {
          Fluttertoast.showToast(
              webBgColor: "linear-gradient(to right, #FFBEBE, #FFBEBE)",
              webPosition: "center",
              backgroundColor: Colors.red[300],
              textColor: Colors.black,
              msg: state.registerError,
              timeInSecForIosWeb: 5,
              toastLength: Toast.LENGTH_LONG);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormField(
              controller: localNameController,
              keyboardType: TextInputType.text,
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.fromLTRB(10, 25, 10, 0),
                labelText: 'Nome do Local',
                labelStyle: TextStyle(color: Colors.grey.shade600),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade600),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: idplacaController,
              keyboardType: TextInputType.text,
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.fromLTRB(10, 25, 10, 0),
                labelText: 'ID Placa',
                labelStyle: TextStyle(color: Colors.grey.shade600),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade600),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const SizedBox(height: 20.0),
            Column(
              children: [
                _createCheckBox("Temperatura", registerCubit),
                _createCheckBox("TDS", registerCubit),
                _createCheckBox("Turbidez", registerCubit),
                _createCheckBox("pH", registerCubit),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                if (localNameController.text.isNotEmpty &&
                    idplacaController.text.isNotEmpty) {
                  registerCubit.registerNodeData(
                      localNameController.text,
                      idplacaController.text,);
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Campo vazio'),
                        content:
                            const Text('Preencha todos os campos de texto'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'OK'),
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonBackgroundColor,
              ),
              child: const Text(
                "Enviar",
                style: TextStyle(color: buttonTextColor),
              ),
            ),
            if (!Responsive.isDesktop(context)) ...[
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/table');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonBackgroundColor,
                ),
                child: const Text(
                  "Visualizar tabela",
                  style: TextStyle(color: buttonTextColor),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

/// Cria um widget de caixa de seleção para o sensor especificado.
///
/// O widget é construído com base no estado atual dos sensores do [RegisterCubit].
///
/// [sensorName] Nome do sensor a ser exibido.
/// [registerCubit] Instância do cubit responsável pelo gerenciamento do estado do formulário.
BlocBuilder<RegisterCubit, RegisterState> _createCheckBox(String sensorName, RegisterCubit registerCubit) {
  return BlocBuilder<RegisterCubit, RegisterState>(builder: (context, state) {
    return Row(
      children: [
        Checkbox(
          checkColor: Colors.black,
          fillColor: WidgetStateProperty.resolveWith(getColor),
          value: registerCubit.sensorStates[sensorName],
          onChanged: (bool? value) {
            registerCubit.setSensorChecked(sensorName, value!);
          },
        ),
        Text(sensorName)
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
