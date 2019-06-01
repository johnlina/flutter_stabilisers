library flutter_stabilisers;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

class Stabilisers {

  static void config({bool suppressStack = true}) {

    FlutterError.onError = (details) {
      // Print the stack if not suppressed
      if(!suppressStack) FlutterError.dumpErrorToConsole(details);
      // Work on the exception and make it more readable
      final assertionError = details.exception as AssertionError;
      final regExp = RegExp('Failed assertion:[^:]*: ');
      final match = regExp.firstMatch(assertionError.toString());
      var filteredMessage = "";
      if (match == null) {
        filteredMessage = assertionError.toString();
      } else {
        filteredMessage = assertionError.toString().substring(match.end);
      }
      filteredMessage = filteredMessage.replaceAll(RegExp(' [0-9]+ '), ' ');
      // Open stackoverflow on accepted answer https://stackoverflow.com/a/{accepted_answer_id}
      // Start working on stackoverflow search by building the params
      Map<String, String> query = {
        'pagesize': '3',
        'order': 'desc',
        'sort': 'relevance',
        'q': filteredMessage,
        'answers': '1',
        'tagged': 'flutter;dart',
        'site': 'stackoverflow',
      };
      // Do the request
      final uri = Uri.http('api.stackexchange.com', '/2.2/search/advanced', query);
      HttpClient client = HttpClient();
      client.getUrl(uri).then((request) => request.close()).then((response) {
        // Transform the response into a JSON
        response.transform(Utf8Decoder()).join().then((value) {
          // Start building the message that will be shown to the user later
          String generalUserMessage = '';
          generalUserMessage += '\n⚠️ Ops, it looks like you ran into a problem with your code 😵. Don’t worry, we got your back! 😄\n';
          generalUserMessage += '🧙 Here are some resources that may help you in your journey to the answer: ⚔️🛡  ';
          String stackoverflowUserMessage = '';
          stackoverflowUserMessage += '\n📈 Top related questions on StackOverflow:\n\n';
          // Here we have at max 3 answers from stackoverflow that we can use
          Map jsonResponse = jsonDecode(value) as Map;
          List items = jsonResponse['items'] as List;
          int stackAnswerCounter = 0;
          for (var item in items) {
            Map itemMap = item as Map;
            var title = itemMap['title'] as String;
            var link = itemMap['link'] as String;
            var accepted_answer_id = itemMap['accepted_answer_id'];
            bool hasAcceptedAnswer = false;
            // Check if we have an accepted answer on stackoverflow. If yes use the link to the answer.
            if (accepted_answer_id != null) {
              hasAcceptedAnswer = true;
              link = 'https://stackoverflow.com/a/${accepted_answer_id as int}';
            }
            // Build the message by link
            stackAnswerCounter++;
            stackoverflowUserMessage += '${stackAnswerCounter == 1 ? '🥇' : stackAnswerCounter == 2 ? '🥈' : '🥉' } ${title}\n${link}';
            stackoverflowUserMessage += hasAcceptedAnswer ? ' - This link has an accepted answer ✅.\n\n' : '\n\n';
          }

          https://api.github.com/search/issues?q=filteredMessage+type:issue+repo:flutter/flutter&sort=reactions-+1+comments&order=desc
          // Start working on github search by building the params
          // final gitHubUri = Uri.http('api.github.com', '/search/issues', gitHubQuery);
          final gitHubUri = Uri.parse('https://api.github.com/search/issues?q=${filteredMessage}+type:issue+repo:flutter/flutter&sort=reactions-+1+comments&order=desc');
          client.getUrl(gitHubUri).then((request) => request.close()).then((response) {
            // Transform the response into a JSON
            response.transform(Utf8Decoder()).join().then((value) {
              // Continue by building the message
              String gitHubUserMessage = '';
              gitHubUserMessage += '📈 Top related issues on GitHub:\n\n';
              // Work on the JSON
              Map jsonResponse = jsonDecode(value) as Map;
              List items = jsonResponse['items'] as List;
              int gitAnswerCounter = 0;
              items = items.take(3).toList();
              for (var item in items) {
                Map itemMap = item as Map;
                var title = itemMap['title'] as String;
                var link = itemMap['html_url'] as String;
                // Build the message by link
                gitAnswerCounter++;
                gitHubUserMessage += '${gitAnswerCounter == 1 ? '🥇' : gitAnswerCounter == 2 ? '🥈' : '🥉' } ${title}\n${link}\n\n';
              }

              // FINAL PRINT
              print('===========================================================================\n');
              print('                              = Stabilisers =                              \n');
              print('===========================================================================');
              if (stackAnswerCounter == 0 && gitAnswerCounter == 0) {
                // Empty results
                print('\n\n');
                print('⚠️ Ops, it looks like you ran into a problem with your code.\n');
                print('😢 Unfortunately, Flutter-Stabilisers could not find any resources to help you with this quest. But don’t worry, there is still hope!\n');
                print('👨‍💻 Submit a question to StackOverflow. There are lot of developers around the world willing to help you! 🌎\n');
                print('https://stackoverflow.com/questions/ask/wizard\n');
                print('👨‍🔬 If you think there is something wrong with the platform you can open an issue on GitHub, where specialists will take a better look!\n');
                print('https://github.com/flutter/flutter/issues/new/choose\n');
                print('💌 If none of this helps you can also get in touch with us\n');
                print('joao@neomode.com.br\n\n');
              } else {
                print(generalUserMessage);
                if (stackAnswerCounter > 0) print(stackoverflowUserMessage);
                if (gitAnswerCounter > 0) print(gitHubUserMessage);
              }
              print('===========================================================================');
            });
          });
        });

      }).catchError((error) {
        print('NEOMODE Informa: ' + error.toString());
      });
    };

  }

}
