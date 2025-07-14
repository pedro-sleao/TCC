// ignore_for_file: prefer_const_constructors

import 'package:dashboard_flutter/constants.dart';
import 'package:dashboard_flutter/cubit/HTTPCubit/http_cubit.dart';
import 'package:dashboard_flutter/responsive.dart';
import 'package:dashboard_flutter/widgets/register_form.dart';
import 'package:dashboard_flutter/widgets/table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


/// Página de registro de usuários.
///
/// Esta página permite o registro de novos usuários. Inclui um formulário de registro
/// e, em telas grandes (desktop), também exibe uma tabela com informações adicionais.
class RegisterPage extends StatefulWidget {
  /// Cria uma instância de [RegisterPage].
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  void initState() {
    super.initState();
    context.read<HttpCubit>().fetchLocals();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HttpCubit, HttpState>(
      builder: (context, state) {
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
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(flex: 1, child: RegisterForm()),
                        SizedBox(width: 16.0),
                        if (Responsive.isDesktop(context))
                          Expanded(flex: 2, child: TableWidget()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Cria uma coluna de dados para uma tabela.
///
/// O parâmetro [columnName] define o nome da coluna que será exibido na tabela.
/// 
/// [columnName] - Nome da coluna a ser exibido.
DataColumn getDataColumn(String columnName) {
  return DataColumn(
    label: Expanded(
      child: Text(
        columnName,
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
    ),
  );
}
