import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../core/animated_markdown.dart';

class TextPage extends StatefulWidget {
  const TextPage({super.key});

  @override
  State<TextPage> createState() => _TextPageState();
}

class _TextPageState extends State<TextPage> {
  late final GenerativeModel gemini;
  var question = '';
  var answer = '';
  var isLoading = false;
  final txtController = TextEditingController();

  @override
  void initState() {
    super.initState();
    gemini = GenerativeModel(
      model: 'gemini-pro',
      apiKey: const String.fromEnvironment('API_KEY'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('TEXT AI'),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(question),
                Visibility(
                  visible: isLoading,
                  child: const ProgressRing(),
                ),
                Visibility(
                  visible: !isLoading,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: AnimatedTextKit(
                      key: ValueKey(answer),
                      displayFullTextOnTap: true,
                      isRepeatingAnimation: false,
                      animatedTexts: [
                        TyperMarkdownAnimatedText(
                          answer
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: question.isEmpty && !isLoading,
                  child: const Center(
                    child: Text('Faça uma pergunta ao GEMINI!'),
                  ),
                )
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextBox(
            controller: txtController,
            onSubmitted: (text) async {
              setState(() {
                question = text;
                isLoading = true;
              });
              txtController.clear();

              final content = [Content.text(question)];
              final response = await gemini.generateContent(content);

              setState(() {
                answer = response.text ?? '';
                isLoading = false;
              });
            },
          ),
        ),
      ],
    );
  }
}
