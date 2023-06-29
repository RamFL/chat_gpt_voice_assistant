import 'dart:convert';

import 'package:chat_gpt_voice_assistant/secrets.dart';
import 'package:http/http.dart' as http;

class OpenAIService {
  final List<Map<String, String>> messages = [];

  // To call chat gpt api to decide the message is for chatGPT or dallE
  Future<String> isArtPromptAPI(String prompt) async {
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPIKey'
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {
              "role": "user",
              "content":
                  "Does this message want to generate an AI picture, image, art or anything similar? $prompt.Simply answer with a yes or no."
            }
          ]
        }),
      );
      print("Encoded prompt: $prompt");
      print('GPT Responce:- ${res.body}');

      if (res.statusCode == 200) {
        String content =
            jsonDecode(res.body)['choices'][0]['message']['content'];
        content = content.trim();

        switch (content) {
          case 'Yes':
          case 'yes':
          case 'Yes.':
          case 'yes.':
            final res = await dallEAPI(prompt);
            return res;
          default:
            final res = await chatGPTAPI(prompt);
            return res;
        }
      }
      return 'An internal error occurred';
    } catch (e) {
      throw e.toString();
    }
  }

  // To chat with chatGPT Api (Post and get response )
  Future<String> chatGPTAPI(String prompt) async {
    print("chatGPT API called");

    messages.add({
      "role": "user",
      "content": prompt,
    });

    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPIKey'
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {
              "role": "user",
              "content": prompt,
            }
          ]
        }),
      );
      print("Encoded prompt: $prompt");
      print('GPT Responce:- ${res.body}');

      if (res.statusCode == 200) {
        String content =
            jsonDecode(res.body)['choices'][0]['message']['content'];
        content = content.trim();

        messages.add({
          'role': 'assistant',
          'content': content,
        });
        return content;
      }
      return 'An internal error occurred in ChatGPT : ${res.statusCode}';
    } catch (e) {
      throw e.toString();
    }
  }

  // To generate any image with dallE api (post request and get response as url)
  Future<String> dallEAPI(String prompt) async {
    print("DallE API called");

    messages.add({
      "role": "user",
      "content": prompt,
    });

    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPIKey'
        },
        body: jsonEncode({
          "prompt": prompt,
          "n": 1,
          "size": "512x512",
        }),
      );
      print("Encoded prompt: $prompt");
      print('GPT Responce:- ${res.body}');

      if (res.statusCode == 200) {
        String imageUrl = jsonDecode(res.body)['data'][0]['url'];
        imageUrl = imageUrl.trim();

        messages.add({
          'role': 'assistant',
          'content': imageUrl,
        });
        return imageUrl;
      }
      return 'An internal error occurred in ChatGPT';
    } catch (e) {
      throw e.toString();
    }
  }
}
