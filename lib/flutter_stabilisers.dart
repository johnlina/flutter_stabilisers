library flutter_stabilisers;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

/// A Calculator.
class Stabilisers {

  static void config({bool supressStack = false}) {

    FlutterError.onError = (details) {
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
          String userMessage = '=====================================================================================================================================\n';
          userMessage += '\n⚠️ Ops, it looks like you ran into a problem with your code 😵. Don’t worry, we got your back! 😄\n';
          userMessage += '🧙 Here are some resources that may help you in your journey to the answer. ⚔️🛡  ';
          userMessage += '\n\n📈 Top related questions on StackOverflow:\n\n';
          // Here we have at max 3 answers from stackoverflow that we can use
          Map jsonResponse = jsonDecode(value) as Map;
          List items = jsonResponse['items'] as List;
          int answerCounter = 1;
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
            userMessage += '${answerCounter == 1 ? '🥇' : answerCounter == 2 ? '🥈' : '🥉' } ${title}\n${link}';
            userMessage += hasAcceptedAnswer ? ' - This link has an accepted answer ✅.\n\n' : '\n\n';
            answerCounter++;
          }

          https://api.github.com/search/issues?q=filteredMessage+type:issue+repo:flutter/flutter&sort=reactions-+1+comments&order=desc
          // Start working on github search by building the params
          Map<String, String> gitHubQuery = {
            'q': filteredMessage + '+type:issue+repo:flutter/flutter',
            'order': 'desc',
            'sort': 'reactions-+1+comments',
          };
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
              int answerCounter = 1;
              items = items.take(3).toList();
              for (var item in items) {
                Map itemMap = item as Map;
                var title = itemMap['title'] as String;
                var link = itemMap['html_url'] as String;
                // Build the message by link
                gitHubUserMessage += '${answerCounter == 1 ? '🥇' : answerCounter == 2 ? '🥈' : '🥉' } ${title}\n${link}\n\n';
                answerCounter++;
              }

              // FINAL PRINT
              print(userMessage);
              print(gitHubUserMessage);
              print('=====================================================================================================================================');
            });
          });
        });

      }).catchError((error) {
        print('NEOMODE Informa: ' + error.toString());
      });
    };

  }

}
