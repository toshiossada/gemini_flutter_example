import 'package:fluent_ui/fluent_ui.dart';
import 'package:gemini_example/pages/chat.dart';
import 'package:gemini_example/pages/text.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: const NavigationAppBar(
        title: Text('GEMINI'),
        leading: Icon(FluentIcons.access_logo),
      ),
      pane: NavigationPane(
        onChanged: (index) {
          setState(() {
            selected = index;
          });
        },
        selected: selected,
        displayMode: PaneDisplayMode.compact,
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.text_rotation),
            title: const Text('text'),
            body: const TextPage(),
            onTap: () {
              setState(() {
                selected = 0;
              });
            },
          ),
          PaneItem(
            icon: const Icon(FluentIcons.image_crosshair),
            title: const Text('Chat'),
            body: const ChatPage(),
            onTap: () {
              setState(() {
                selected = 1;
              });
            },
          ),
        ],
      ),
    );
  }
}
