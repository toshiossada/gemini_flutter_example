import 'dart:developer';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:markdown_widget/widget/markdown_block.dart';

class TextPage extends StatefulWidget {
  const TextPage({super.key});

  @override
  State<TextPage> createState() => _TextPageState();
}

class _TextPageState extends State<TextPage> {
  final gemini = Gemini.instance;
  var message = '';
  final txtController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('TEXT AI'),
        Expanded(
            child: SingleChildScrollView(
          child: Column(
            children: [
              Text(message),
              GeminiResponseTypeView(
                builder: (context, child, response, loading) {
                  if (loading) {
                    /// show loading animation or use CircularProgressIndicator();
                    return const ProgressRing();
                  }

                  /// The runtimeType of response is String?
                  if (response != null) {
                    return SingleChildScrollView(
                      child: MarkdownBlock(data: response),
                    );
                  } else {
                    /// idle state
                    return const Center(child: Text('Search something!'));
                  }
                },
              ),
            ],
          ),
        )),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextBox(
            controller: txtController,
            onSubmitted: (text) {
              setState(() {
                message = text;
              });
              txtController.clear();

              gemini.streamGenerateContent(text).listen((value) {
                if (value.output != null) {
                  log(value.output!);
                }
              }).onError((e) {
                log('streamGenerateContent exception', error: e);
              });
            },
          ),
        ),
      ],
    );
  }
}
