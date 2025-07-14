import 'package:dashboard_flutter/constants.dart';
import 'package:dashboard_flutter/cubit/HTTPCubit/http_cubit.dart';
import 'package:dashboard_flutter/cubit/LoginCubit/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';


/// Página de login da aplicação.
///
/// Esta página permite que o usuário se autentique na aplicação. Utiliza o [LoginCubit]
/// para gerenciar o estado do login e o [HttpCubit] para reiniciar o estado HTTP após o login.
/// Exibe uma tela de login com campos para usuário e senha, e um botão para autenticação.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Color loginBoxColor = Colors.white;
  Color cadastroBoxColor = primaryColor;

  var usernameController = TextEditingController();
  var passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    LoginCubit loginCubit = BlocProvider.of<LoginCubit>(context);
    HttpCubit httpCubit = BlocProvider.of<HttpCubit>(context);
    return BlocBuilder<LoginCubit, LoginState>(builder: (context, state) {
      return Material(
        child: Scaffold(
          body: BlocListener<LoginCubit, LoginState>(
            listener: (context, state) {
              if (state is LoginDone) {
                // Navega para a página inicial e remove todas as rotas anteriores da pilha
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/', (route) => false);
                });
                httpCubit
                    .resetState(); // Necessário para reiniciar a página caso tenha feito logout anteriormente
              } else if (state is LoginError) {
                Fluttertoast.showToast(
                    webBgColor: "linear-gradient(to right, #FFBEBE, #FFBEBE)",
                    webPosition: "center",
                    backgroundColor: Colors.red[300],
                    textColor: Colors.black,
                    msg: state.errorMessage,
                    timeInSecForIosWeb: 5,
                    toastLength: Toast.LENGTH_LONG);
              }
            },
            child: SafeArea(
              child: Center(
                child: Container(
                  height: 400,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  width: 450,
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Padding(
                            padding: EdgeInsets.only(bottom: 20.0),
                            child: Text(
                              "LOGIN",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
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
                            if (usernameController.text.isNotEmpty) {
                              loginCubit.login(usernameController.text,
                                  passwordController.text);
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
                              loginCubit.login(usernameController.text,
                                  passwordController.text);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonBackgroundColor,
                            ),
                            child: const Text(
                              "Entrar",
                              style: TextStyle(color: buttonTextColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
