import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  var question = '';
  var answer = '';
  var isLoading = false;
  final txtController = TextEditingController();
  final ScrollController _controller = ScrollController();
  File? file;

  late final GenerativeModel gemini;
  late final ChatSession _chat;
  @override
  void initState() {
    super.initState();
    gemini = GenerativeModel(
      model: 'gemini-1.5-pro-latest',
      apiKey: const String.fromEnvironment('API_KEY'),
    );
    _chat = gemini.startChat();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('CHAT AI'),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
              itemCount: _chat.history.length,
              controller: _controller,
              itemBuilder: (_, index) {
                final content = _chat.history.toList()[index];
                final isUser = content.role == 'user';
                var text = content.parts
                    .whereType<TextPart>()
                    .map<String>((e) => e.text)
                    .join('');
                return Container(
                  color: isUser ? Colors.green : Colors.blue,
                  child: ListTile(
                    leading: isUser ? null : const Icon(FluentIcons.robot),
                    trailing:
                        !isUser ? null : const Icon(FluentIcons.user_clapper),
                    title: SingleChildScrollView(
                      child: MarkdownBody(
                        data: text,
                      ),
                    ),
                  ),
                );
              }),
        )),
        if (isLoading) const ProgressRing(),
        Row(
          children: [
            if (file != null)
              Row(
                children: [
                  IconButton(
                    icon: const Icon(FluentIcons.delete),
                    onPressed: isLoading
                        ? null
                        : () {
                            setState(() {
                              file = null;
                            });
                          },
                  ),
                  Image.file(
                    file!,
                    height: 50,
                    width: 50,
                  )
                ],
              )
            else
              IconButton(
                icon: const Icon(FluentIcons.file_image),
                onPressed: isLoading
                    ? null
                    : () async {
                        FilePickerResult? result =
                            await FilePicker.platform.pickFiles();

                        if (result != null) {
                          setState(() {
                            file = File(result.files.single.path!);
                          });
                        } else {
                          // User canceled the picker
                        }
                      },
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextBox(
                  controller: txtController,
                  enabled: !isLoading,
                  onSubmitted: (text) async {
                    final message = text;
                    try {
                      setState(() {
                        isLoading = true;
                        txtController.clear();
                      });

                      if (file != null) {
                        final imageBytes = await file!.readAsBytes();
                        final content = Content.multi([
                          TextPart(message),
                          DataPart('image/${file!.path.split('.').last}',
                              imageBytes),
                        ]);

                        final response = await _chat.sendMessage(content);

                        print(response);
                      } else {
                        var response = await _chat.sendMessage(
                          Content.text(message),
                        );
                        var text = response.text;

                        print(text);
                      }
                    } finally {
                      setState(() {
                        txtController.clear();
                        isLoading = false;
                        file = null;
                        _scrollDown();
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _controller.animateTo(
        _controller.position.maxScrollExtent,
        duration: const Duration(
          milliseconds: 750,
        ),
        curve: Curves.easeOutCirc,
      ),
    );
  }
}
