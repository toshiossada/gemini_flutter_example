import 'package:fluent_ui/fluent_ui.dart';
import 'package:gemini_example/app_widget.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

void main() async {
  Gemini.init(apiKey: const String.fromEnvironment('API_KEY'));

  runApp(const AppWidget());
}
