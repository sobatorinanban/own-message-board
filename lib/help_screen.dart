import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

import 'utils/globals.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key : key);
  // static const routeName = '/about';

  @override
  Widget build(BuildContext context) {
    var _screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Own Message Board (from Slack API)"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const ListTile(
              title: Text('About'),
              leading: Icon(Icons.info),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                children: [
                  Container(
                      padding: const EdgeInsets.all(15),
                      child: const Text.rich(
                          TextSpan(
                              children: [
                                TextSpan(
                                  text: "\nこのサイトについて\n",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                    text: "Own Message Board (from Slack API) は，SlackAPIを利用した伝言板です．\n"
                                ),
                                TextSpan(
                                    text: "Socket Modeを用いてコネクションを貼り，取得したメッセージを画面に表示します．\n"
                                ),
                                TextSpan(
                                    text: "余っているスマートフォンやRaspberryPiなどを利用して，在籍/離席状況を表示する伝言板を作成することを想定していますが，色々な使い方ができると思います．"
                                ),
                              ]
                          )
                      )
                  ),
                ],
              ),
            ),
            const ListTile(
              title: Text('How to use and setup SlackBot to my channel'),
              leading: Icon(Icons.settings_applications),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: "\nこのアプリの使い方，SlackBotのセッティング方法\n",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(
                            text: "このアプリを使うためには，目的のSlackチャンネルにSlackBotをセットアップし，チャンネル内のメッセージを取得できるようにする必要があります．\n"
                          ),
                          const TextSpan(
                            text: "サーバーレスアプリケーションであるため．取得したメッセージはクライアント側でAPIを叩いてメッセージを表示することのみに利用されます．取得したメッセージがサーバーに保存・保管されることはありません．\n"
                          ),
                          const TextSpan(
                            text: "\n# Slack Appの準備\n"
                          ),
                          const TextSpan(
                            text: "Slack App (SlackBot) を以下のSlack公式サイトにて作成します．詳しい作成方法については公式サイトのドキュメントを参考にしてください．\n"
                          ),
                          TextSpan(
                              text: "Unlock your productivity potential with Slack Platform | Slack\n",
                              style: const TextStyle(color: Colors.blue),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  final url = Uri.parse('https://api.slack.com/');
                                  webLaunchUrl(url);
                                }
                          ),
                          const TextSpan(
                              text: "\n  ## このアプリを利用するためにSlack Appに必要なもの\n"
                          ),
                          const TextSpan(
                              text: "    ### Socket Mode\n"
                          ),
                          const TextSpan(
                            text: "      デフォルトではオフなので，オンにしてください．\n\n"
                          ),
                          const TextSpan(
                              text: "    ### Event Subscriptions\n"
                          ),
                          const TextSpan(
                            text: "      ・Subscribe to events on behalf of users \n        ・message.channels \n        ・dnd_updated_user \n"
                          ),
                          const TextSpan(
                            text: "      購読するイベントについてです．message.channelsはメッセージの取得に，dnd_updated_userはDo not disturbの取得に使います．\n\n"
                          ),
                          const TextSpan(
                              text: "    ### Scopes\n"
                          ),
                          const TextSpan(
                            text: "      ・Bot Token Scopes \n        ・channels:history \n        ・dnd:read \n"
                          ),
                          const TextSpan(
                              text: "      Botに許可する権限についてです．channels:historyはメッセージの取得に，dnd:readはDo not disturbの取得に使います．\n"
                          ),
                          const TextSpan(
                              text: "\n# App Level Tokenの取得\n"
                          ),
                          const TextSpan(
                              text: "  Socket Modeを使うため，App Level Tokenを取得しておく必要があります．．'Basic Information > App-Level Tokens'から取得し，大切に保管してください．後ほど使います．．\n"
                          ),
                          const TextSpan(
                              text: "\n# Slack Appの追加\n"
                          ),
                          const TextSpan(
                            text: "  Slack Appに必要な設定ができたところで，実際にAppを利用したいSlackチャンネルに追加してあげる必要があります．'Features > Oauth & Permission'ページの'OAuth Tokens for Your Workspace'を実行します．\n"
                          ),
                          const TextSpan(
                            text: "\n# 作成したSlack Appを用いて本アプリを利用する \n"
                          ),
                          const TextSpan(
                            text: "  先ほど入手したOAuth Tokenを用いてSlack Socket ModeのEnd pointを取得し，トップページに入力します．\n\n"
                          ),
                          const TextSpan(
                            text: 'curl -sSX POST "https://slack.com/api/apps.connections.open" -H "Content-type: application/x-www-form-urlencoded" -H "Authorization: Bearer [先ほど取得したApp-Level Tokens]"\n\n',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const TextSpan(
                            text: "  チャンネルに複数人いる場合など，その中から特定の人物の発言のみを取り出したい場合には，'Single Speaker Mode'をオンにし，目的の人物のMember IDを入力します．\n"
                          ),
                          const TextSpan(
                            text: "  Member IDは．Slackアプリの'プロフィール > メンバーIDをコピー'から取得できます．\n"
                          ),
                        ]
                      )
                    ),
                  )
                ],
              ),
            ),
            const ListTile(
              title: Text('How to contribute'),
              leading: Icon(Icons.note_add),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                children: [
                  Container(
                      padding: const EdgeInsets.all(15),
                      child: Text.rich(
                          TextSpan(
                              children: [
                                const TextSpan(
                                  text: "\nバグの修正や機能の追加・向上\n",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const TextSpan(
                                  text: "このサイトは，",
                                ),
                                TextSpan(
                                    text: "GitHub",
                                    style: const TextStyle(color: Colors.blue),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        final url = Uri.parse('');
                                        webLaunchUrl(url);
                                      }
                                ),
                                const TextSpan(
                                    text: "にてオープンソースソフトウェアとして公開されています．PullRequest等お待ちしています．またバグの報告や意見等については，Issueからお願いします．\n"
                                )
                              ]
                          )
                      )
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}