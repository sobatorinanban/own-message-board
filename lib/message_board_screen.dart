import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'main.dart';
import 'utils/globals.dart';
import 'help_screen.dart';

final messageProvider = StateProvider<String>((ref)=>"- No information -");
final presenceProvider = StateProvider<bool>((ref)=>true);
final updateTimeProvider = StateProvider<int>((ref)=>(DateTime.now().millisecondsSinceEpoch / 1000).floor());

class MessageBoard extends ConsumerStatefulWidget {
  const MessageBoard({Key? key}) : super(key: key);

  @override
  ConsumerState<MessageBoard> createState() => MessageBoardState();
}

class MessageBoardState extends ConsumerState<MessageBoard> {


  // Future<void> getSlackWebSocket() async {
  //   String slackAppsConnectionsOpen = "https://slack.com/api/apps.connections.open";
  //   Uri url = Uri.parse(slackAppsConnectionsOpen);
  //   Map<String, String> headers = {
  //     // 'Content-type' : 'application/json',
  //     'Content-type' : 'application/x-www-form-urlencoded',
  //     'Authorization' : 'Bearer $token'
  //   };
  //
  //   // http.withCr
  //   //
  //   // print(url);
  //   // print(headers);
  //
  //   try {
  //     final response = await http.post(url, headers: headers);
  //     if(response.statusCode == 200 && response.body.isNotEmpty) {
  //       Map responseMap = jsonDecode(response.body);
  //       if(responseMap.containsKey('ok')) {
  //         if(responseMap['ok'] == true && responseMap.containsKey('url')) {
  //           slackWebSocketUrl = responseMap['url'];
  //         } else {
  //           String errorMessage = responseMap.containsKey('error')? responseMap['error'] : "unknown error";
  //           throw Exception('SlackAPI Error : $errorMessage');
  //         }
  //       } else {
  //         throw Exception('Error : Failed to post SlackAPI');
  //       }
  //     } else {
  //       throw Exception('Error : Failed to post SlackAPI');
  //     }
  //   } on http.ClientException catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //         content: Text('$e'), duration: const Duration(seconds: 4)));
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //         content: Text('$e'), duration: const Duration(seconds: 4)));
  //   }
  //   print(slackWebSocketUrl);
  // }
  //
  // void getFromSlackAPI(Timer timer) async {
  //   String receivedMessage = "--";
  //   bool isActive = false;
  //   String uri = "https://slack.com/api/conversations.list";
  //
  //   print("test");
  //
  //   // var response = await http.get(
  //   //   Uri.parse(uri),
  //   //   headers: {
  //   //     "Authorization": "$token",
  //   //     "Content-Type": "application/json"
  //   //   },
  //   // );
  //
  //   getSlackWebSocket();
  //
  //   // print(response);
  //   print("test");
  //
  // }

  @override
  Widget build(BuildContext context) {
    final singleUserMode = ref.watch(singleUserProvider.state);
    final message = ref.watch(messageProvider.state);
    final presence = ref.watch(presenceProvider.state);
    final updateTime = ref.watch(updateTimeProvider.state);

    double mW = min(1000, MediaQuery.of(context).size.width * 0.9);
    double buttonWidth = min(450, mW*0.8);
    double textFieldWidth = min(500, mW*0.9);

    final Uri uri = Uri.parse(wssUri ?? 'wss;//unknown');
    final socketChannel = WebSocketChannel.connect(uri);

    socketChannel.stream.listen((event) {
      var events = json.decode(event);

      if(events.containsKey('type')) {
        if(events['type'] == 'events_api') {
          // event message
          if(events.containsKey('payload')) {
            if(events['payload'].containsKey('event_time')) {
              if(events['payload']['event_time'] >= updateTime.state) {
                // new message
                if(events['payload'].containsKey('event')) {
                  if(events['payload']['event'].containsKey('type') && events['payload']['event'].containsKey('user')) {
                    if(events['payload']['event']['type'] == 'message') {
                      // message
                      if(singleUserMode.state && events['payload']['event']['user'] != memberId) {
                        // discard
                      }else if(events['payload']['event'].containsKey('text')) {
                        message.state = events['payload']['event']['text'];
                        // updateTime.state = events['payload']['event_time'];
                      }
                    }else if(events['payload']['event']['type'] == 'dnd_updated_user') {
                      // do not disturb status
                      if(events['payload']['event'].containsKey('dnd_status')) {
                        if(events['payload']['event']['dnd_status'].contains('dnd_enabled')) {
                          presence.state = !events['payload']['event']['dnd_enabled'];
                          // updateTime.state = events['payload']['event_time'];
                        }
                      }
                    }
                  }
                }
              }
              // duplicate message
              // discard
            }
          }
          updateTime.state = events['payload']['event_time'];
        }
        // other message
        // discard
      }
      // unknown message
      // discard
    },
    onError: (error) {
      // discard
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Message Board'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: mW,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: (mW*4)/6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: Container(
                          width: (mW*4)/6,
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Status"),
                              Text(
                                style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 4,
                                message.state,
                              ),
                            ],
                          ),
                        )
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  width: (mW*2)/6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Clock(),
                      Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Last Updated: ${DateFormat('y/MM/dd HH:mm').format(DateTime.fromMillisecondsSinceEpoch(updateTime.state * 1000))}',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11)
                              )
                            ]
                        ),
                      ),
                    ],
                  ),
                )

              ],
            ),
          ),
        ),
      ),
      bottomSheet: Container(
        height: 50,
        padding: const EdgeInsets.only(bottom: 10),
        child: ListTile(
            title: Text(singleUserMode.state? "Status" : "Status of someone in Workspace"),
            subtitle: Text(presence.state? "Notification is active" : "Do not disturb"),
            leading: Icon(singleUserMode.state? Icons.account_circle : Icons.workspaces),
            trailing: Icon(
              Icons.circle,
              color: presence.state? Colors.green : Colors.red,
            ),
            dense: true,
        ),
      ),
    );
  }
}

class Clock extends StatefulWidget {
  const Clock({super.key});

  @override
  ClockState createState() => ClockState();
}

class ClockState extends State<Clock> {
  Timer? _timer;


  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => setState(() {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('\n\ny / MM / dd\nHH : mm\n\n').format(DateTime.now()),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
