import 'package:dashboard_flutter/cubit/OTACubit/ota_cubit.dart';
import 'package:flutter/material.dart';
import 'package:dashboard_flutter/constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OtaPage extends StatefulWidget {
  const OtaPage({super.key});

  @override
  State<OtaPage> createState() => _OtaPageState();
}

class _OtaPageState extends State<OtaPage> {
  @override
  Widget build(BuildContext context) {
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
              BlocConsumer<OtaCubit, OtaState>(
                listener: (context, state) {
                  if (state is OtaDone) {
                    Fluttertoast.showToast(
                        webBgColor: "linear-gradient(to right, #dbead5, #dbead5)",
                        webPosition: "center",
                        backgroundColor: Colors.green[200],
                        textColor: Colors.black,
                        msg: "Arquivo enviado.",
                        timeInSecForIosWeb: 5,
                        toastLength: Toast.LENGTH_LONG);
                  } else if (state is OtaError) {
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
                builder: (context, state) {
                  if (state is OtaLoading) {
                    return Center(
                        child: SizedBox(
                            width: 50, child: CircularProgressIndicator()));
                  }
                  return Center(
                    child: SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<OtaCubit>().uploadFirmware();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonBackgroundColor,
                        ),
                        child: const Text(
                          'Selecionar arquivo',
                          style: TextStyle(color: buttonTextColor),
                        ),
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
