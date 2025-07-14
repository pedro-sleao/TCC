import 'package:dashboard_flutter/constants.dart';
import 'package:dashboard_flutter/cubit/RegisterCubit/register_cubit.dart';
import 'package:dashboard_flutter/responsive.dart';
import 'package:dashboard_flutter/widgets/users_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// A página principal do administrador.
///
/// Esta página exibe um formulário para cadastrar novos usuários e uma lista de
/// usuários já cadastrados. A exibição do layout pode variar dependendo do
/// tamanho da tela, com uma abordagem responsiva para dispositivos móveis e
/// desktops.
class AdminPage extends StatefulWidget {
  /// Cria uma instância de [AdminPage].
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  var usernameController = TextEditingController();
  var passwordController = TextEditingController();

  late String registerResponse;

  @override
  void initState() {
    super.initState();
    context.read<RegisterCubit>().fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    RegisterCubit registerCubit = BlocProvider.of<RegisterCubit>(context);
    return BlocListener<RegisterCubit, RegisterState>(
      listener: (context, state) {
        if (state is RegisterDone) {
          registerCubit.fetchUsers();
          Fluttertoast.showToast(
              webBgColor: "linear-gradient(to right, #dbead5, #dbead5)",
              webPosition: "center",
              backgroundColor: Colors.green[200],
              textColor: Colors.black,
              msg: state.registerMessage,
              timeInSecForIosWeb: 5,
              toastLength: Toast.LENGTH_LONG);
        } else if (state is RegisterDeletedUser) {
          registerCubit.fetchUsers();
          Fluttertoast.showToast(
              webBgColor: "linear-gradient(to right, #dbead5, #dbead5)",
              webPosition: "center",
              backgroundColor: Colors.green[200],
              textColor: Colors.black,
              msg: state.deleteMessage,
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
      child: BlocBuilder<RegisterCubit, RegisterState>(
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
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    if (Responsive.isDesktop(context)) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          RegisterUserWidget(
                              usernameController: usernameController,
                              passwordController: passwordController,
                              registerCubit: registerCubit),
                          Container(
                            height: 600,
                            width: 450,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                //color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8)),
                            child:
                                UsersListWidget(registerCubit: registerCubit),
                          )
                        ],
                      ),
                    ] else ...[
                      RegisterUserWidget(
                          usernameController: usernameController,
                          passwordController: passwordController,
                          registerCubit: registerCubit),
                    ]
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Widget que exibe o formulário de registro de usuário.
///
/// Este widget fornece campos para o nome de usuário e senha, além de botões
/// para cadastrar o usuário e visualizar a lista de usuários. Ele também
/// lida com o processo de registro usando o [RegisterCubit].
class RegisterUserWidget extends StatelessWidget {
  /// Cria uma instância de [RegisterUserWidget].
  ///
  /// [usernameController] controla o campo de texto de nome de usuário,
  /// [passwordController] controla o campo de texto de senha, e
  /// [registerCubit] é usado para gerenciar o estado de registro.
  const RegisterUserWidget({
    super.key,
    required this.usernameController,
    required this.passwordController,
    required this.registerCubit,
  });

  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final RegisterCubit registerCubit;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 450,
        height: 400,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    "CADASTRAR",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  )),
              TextField(
                controller: usernameController,
                onSubmitted: (value) {},
                decoration: const InputDecoration(
                  hoverColor: Colors.transparent,
                  hintText: "Usuário",
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              TextField(
                controller: passwordController,
                onSubmitted: (value) {
                  if (usernameController.text.isNotEmpty &&
                      passwordController.text.isNotEmpty) {
                    registerCubit.register(
                        usernameController.text, passwordController.text);
                    usernameController.clear();
                    passwordController.clear();
                  }
                },
                obscureText: true,
                decoration: const InputDecoration(
                  hoverColor: Colors.transparent,
                  hintText: "Senha",
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (usernameController.text.isNotEmpty &&
                        passwordController.text.isNotEmpty) {
                      registerCubit.register(
                          usernameController.text, passwordController.text);
                      usernameController.clear();
                      passwordController.clear();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonBackgroundColor,
                  ),
                  child: const Text(
                    "Cadastrar",
                    style: TextStyle(color: buttonTextColor),
                  ),
                ),
              ),
              if (!Responsive.isDesktop(context)) ...[
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/users');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonBackgroundColor,
                  ),
                  child: const Text(
                    "Visualizar usuários",
                    style: TextStyle(color: buttonTextColor),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
