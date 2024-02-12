import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:markdown_widget/widget/markdown_block.dart';

import '../models/chat_model.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final gemini = Gemini.instance;
  final messages = <ChatModel>[];
  final txtController = TextEditingController();
  final ScrollController _controller = ScrollController();
  var isLoading = false;
  File? file;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('CHAT AI'),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
              itemCount: messages.length,
              controller: _controller,
              itemBuilder: (_, index) {
                final message = messages[index];
                final isUser = (message.actor == MessageActor.user);

                return Container(
                  color: isUser ? Colors.green : Colors.blue,
                  child: ListTile(
                    leading: isUser ? null : const Icon(FluentIcons.robot),
                    trailing:
                        !isUser ? null : const Icon(FluentIcons.user_clapper),
                    title: SingleChildScrollView(
                      child: MarkdownBlock(
                        data: message.message,
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
                    try {
                      setState(() {
                        messages.add(
                            ChatModel(message: text, actor: MessageActor.user));
                        isLoading = true;
                        txtController.clear();
                      });

                      _scrollDown();
                      late final String answer;

                      if (file != null) {
                        final result = await gemini.textAndImage(
                            text: text, images: [file!.readAsBytesSync()]);

                        if (result?.output != null) {
                          answer = result?.output ?? '';
                        }
                      } else {
                        var chat = messages
                            .map((e) => Content(
                                parts: [Parts(text: e.message)],
                                role: e.actor.role))
                            .toList();
                        final result = await gemini.chat(chat);
                        if (result?.output != null) {
                          answer = result?.output ?? '';
                        }
                      }
                      setState(() {
                        messages.add(ChatModel(
                            message: answer, actor: MessageActor.gemini));
                      });
                    } finally {
                      setState(() {
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
    _controller.jumpTo(_controller.position.maxScrollExtent);
  }
}
