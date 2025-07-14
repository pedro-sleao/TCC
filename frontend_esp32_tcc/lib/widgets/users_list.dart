import 'package:dashboard_flutter/cubit/RegisterCubit/register_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Um widget que exibe uma lista de usuários.
///
/// Este widget utiliza o [RegisterCubit] para obter a lista de usuários e exibi-los em uma lista
/// rolável. Cada item da lista possui um botão de exclusão que permite remover o usuário
/// da lista após uma confirmação.
class UsersListWidget extends StatelessWidget {
  /// Cria uma instância do [UsersListWidget].
  ///
  /// [registerCubit] O cubit utilizado para gerenciar o estado da lista de usuários.
  const UsersListWidget({
    super.key,
    required this.registerCubit,
  });

  /// O cubit utilizado para gerenciar o estado da lista de usuários.
  final RegisterCubit registerCubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterCubit, RegisterState>(
      builder: (context, state) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Lista de usuários",
              style: TextStyle(fontSize: 25),
            ),
            const SizedBox(
              height: 15,
            ),
            Expanded(
              child: ListView.separated(
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(height: 1),
                itemBuilder: (context, index) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        registerCubit.usersList[index],
                        style: const TextStyle(fontSize: 18),
                      ),
                      IconButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Aviso!'),
                                  content: Text(
                                      'Deseja deletar a conta do ${registerCubit.usersList[index]}'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, 'Não');
                                        registerCubit.deleteUser(
                                            registerCubit.usersList[index]);
                                      },
                                      child: const Text('Sim'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, 'Não'),
                                      child: const Text('Não'),
                                    ),
                                  ],
                                );
                              });
                        },
                        icon: const Icon(
                          Icons.close,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  );
                },
                itemCount: registerCubit.usersList.length,
              ),
            ),
          ],
        );
      }
    );
  }
}
