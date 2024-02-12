import 'package:fluent_ui/fluent_ui.dart';
import 'package:gemini_example/home_page.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const FluentApp(
      title: 'Gemini App',
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
