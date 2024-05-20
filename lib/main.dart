import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'utils/globals.dart';
import 'utils/color_schemes.g.dart';
import 'help_screen.dart';
import 'message_board_screen.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref)=>ThemeMode.system);
final singleUserProvider = StateProvider<bool>((ref)=>false);

void main() {
  runApp(
      const ProviderScope(
          child: MyApp()
      )
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider.state);
    return MaterialApp(
      title: 'Own Message Board (from Slack API)',
      theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
      themeMode: themeMode.state,
      home: TopPage(),
    );
  }
}

class TopPage extends ConsumerWidget {
  TopPage({Key? key}) : super(key: key);
  final _formKey = GlobalKey<FormState>();

  final slackTokenTextController = TextEditingController();
  final slackConversationTextController = TextEditingController();
  final slackMemberTextController = TextEditingController();



  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider.state);
    final singleUserMode = ref.watch(singleUserProvider.state);
    double mW = min(800, MediaQuery.of(context).size.width * 0.9);
    double buttonWidth = min(450, mW*0.8);
    double textFieldWidth = min(500, mW*0.9);

    // void _changeToggle(bool e) => setState(() => _active = e);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Own Message Board (from Slack API)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sunny),
            tooltip: 'Change Theme',
            onPressed: () {
              themeMode.state = (themeMode.state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light);
            },
          ),
        ],
      ),
      body : SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
            child: SizedBox(
              width: mW*0.9,
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  Card(
                    child: ListTile(
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AboutScreen()),
                        );
                      },
                      title: const Text("How to setup SlackBot to my channel"),
                      subtitle: const Text("Before using this application, please set up Slack Bot in your channel."),
                      trailing: const Icon(Icons.question_mark_rounded),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Divider(),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(
                          width: textFieldWidth,
                          child: TextFormField(
                            controller: slackTokenTextController,
                            decoration: const InputDecoration(
                                labelText: "Slack Socket Mode Endpoint",
                                hintText: "wss://wss-primary.slack.com/link/?ticket=xxx&app_id=xxx",
                                border: OutlineInputBorder()
                            ),
                            validator: (value) {
                              if(value == null || value.isEmpty) {
                                return "Please fill out the form";
                              }
                            },
                          ),
                        ),
                        // const SizedBox(height: 15),
                        // SizedBox(
                        //   width: textFieldWidth,
                        //   child: TextFormField(
                        //     controller: slackConversationTextController,
                        //     decoration: const InputDecoration(
                        //         labelText: "Slack target channel name",
                        //         hintText: 'general',
                        //         border: OutlineInputBorder()
                        //     ),
                        //     validator: (value) {
                        //       if(value == null || value.isEmpty) {
                        //         return "Please fill out the form";
                        //       }
                        //     },
                        //   ),
                        // ),
                        const SizedBox(height: 15),
                        const Divider(),
                        SizedBox(
                          width: textFieldWidth,
                          child: SwitchListTile(
                            value: singleUserMode.state,
                            title: const Text('Single speaker mode'),
                            subtitle: const Text("Enable this to show only message from one user."),
                            onChanged: (bool value) {
                              singleUserMode.state = value;
                            },
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: textFieldWidth,
                          child: TextFormField(
                            controller: slackMemberTextController,
                            enabled: singleUserMode.state,
                            decoration: const InputDecoration(
                                labelText: "Slack target user (Member ID)",
                                hintText: 'C1234567890',
                                border: OutlineInputBorder()
                            ),
                            validator: (value) {
                              if((value == null || value.isEmpty) && singleUserMode.state == true) {
                                return "Please fill out the form";
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Divider(),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: buttonWidth,
                    child: FilledButton(
                      onPressed: () {
                        if(_formKey.currentState!.validate()) {
                          wssUri = slackTokenTextController.text;
                          conversationId =
                              slackConversationTextController.text;
                          if (singleUserMode.state) {
                            memberId = slackMemberTextController.text;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MessageBoard()),
                          );
                        }

                      },
                      child: const Text("Configure"),
                    ),
                  ),
                ]
              ),
            ),
        )
      ),


    );
  }
}

// class InitialPage extends StatefulWidget {
//   const InitialPage({Key? key}) : super(key: key);
//   @override
//   InitialPageState createState() => InitialPageState();
// }
//
// class InitialPageState extends State<InitialPage> {
//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold (
//       body: Column(
//         children: [
//           Text('test2test2test2test2test2')
//         ],
//       ),
//     );
//   }
// }