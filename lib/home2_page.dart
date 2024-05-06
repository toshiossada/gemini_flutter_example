import 'package:fluent_ui/fluent_ui.dart';
import 'package:gemini_example/pages/chat.dart';
import 'package:gemini_example/pages/text.dart';

class Home2Page extends StatefulWidget {
  const Home2Page({super.key});

  @override
  State<Home2Page> createState() => _Home2PageState();
}

class _Home2PageState extends State<Home2Page> {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    return TabView(
      currentIndex: selected,
      onChanged: (index) {
        setState(() {
          selected = index;
        });
      },
      tabs: [
        Tab(
          icon: const Icon(FluentIcons.airplane),
          text: const Text(
            "Tab 1",
          ),
          body: Container(
            color: Colors.white,
            child: const TextPage(),
          ),
        ),
        Tab(
          icon: const Icon(FluentIcons.add_event),
          text: const Text("Tab 2"),
          body: Container(
            color: Colors.white,
            child: const ChatPage(),
          ),
        )
      ],
    );
  }
}
