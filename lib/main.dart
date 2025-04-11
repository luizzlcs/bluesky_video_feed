import 'package:flutter/material.dart';
import 'core/services/service_locator.dart';
import 'app.dart';

void main() {
  // Inicializa o GetIt antes de executar o app
  setupServiceLocator();
  runApp(const MyApp());
}