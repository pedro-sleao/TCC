import 'package:dashboard_flutter/constants.dart';
import 'package:dashboard_flutter/cubit/RegisterCubit/register_cubit.dart';
import 'package:dashboard_flutter/widgets/users_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A página que exibe a lista de usuários. Criada para mostrar a lista de usuários em dispositivos móveis.
///
/// Esta página usa o [RegisterCubit] para gerenciar o estado relacionado aos
/// usuários e exibe um widget de lista de usuários.
class UsersListPage extends StatelessWidget {
  /// Cria uma instância de [UsersListPage].
  const UsersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    RegisterCubit registerCubit = BlocProvider.of<RegisterCubit>(context);
    return Material(
      child: Container(
        color: primaryColor,
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
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
              Expanded(
                  child: UsersListWidget(
                registerCubit: registerCubit,
              ))
            ]),
          ),
        ),
      ),
    );
  }
}
