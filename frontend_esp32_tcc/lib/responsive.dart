// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });


  /// Verifica se a largura da tela é de um dispositivo móvel.
  ///
  /// Retorna `true` se a largura for menor que 850 pixels.
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 850;

  /// Verifica se a largura da tela é de um tablet.
  ///
  /// Retorna `true` se a largura estiver entre 850 e 1100 pixels.
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width < 1100 &&
      MediaQuery.of(context).size.width >= 850;

  /// Verifica se a largura da tela é de um desktop.
  ///
  /// Retorna `true` se a largura for maior ou igual a 1100 pixels.
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    if (_size.width >= 1100) {
      return desktop;
    }
    else if (_size.width >= 850 && tablet != null) {
      return tablet!;
    }
    else {
      return mobile;
    }
  }
}