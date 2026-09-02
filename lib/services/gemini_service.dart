import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_ai/firebase_ai.dart';

// JS interop binding for the custom App Check token helper defined in
// web/index.html — see the comment there for why this exists (it works
// around a bug in Firebase's JS SDK's reCAPTCHA Enterprise integration).
@JS('__studiaGetAppCheckToken')
external JSPromise<JSString> _jsGetAppCheckToken();

const String _webApiKey = 'AIzaSyAnGPN6Lj5a0fN3cudS-phyzdL8YzyHmGM';
const String _projectId = 'studia-48762';

/// Sends [prompt] to Gemini and returns the response text.
///
/// On web this bypasses `firebase_ai`'s built-in App Check handling
/// (broken for reCAPTCHA Enterprise — see the comment in web/index.html)
/// and calls Firebase's AI Logic proxy directly with a token obtained
/// through our own reliable flow. Other platforms use the normal
/// `firebase_ai` package since App Check there uses native attestation
/// (Play Integrity / App Attest), which isn't affected by this bug.
Future<String> askGemini(String prompt, {String model = 'gemini-3.6-flash'}) async {
  if (kIsWeb) {
    return _askGeminiWeb(prompt, model: model);
  }
  final generativeModel = FirebaseAI.googleAI().generativeModel(model: model);
  final response = await generativeModel.generateContent([Content.text(prompt)]);
  return response.text?.trim() ?? "Sorry, I couldn't generate a response.";
}

Future<String> _askGeminiWeb(String prompt, {required String model}) async {
  final token = (await _jsGetAppCheckToken().toDart).toDart;

  final uri = Uri.https(
    'firebasevertexai.googleapis.com',
    '/v1beta/projects/$_projectId/models/$model:generateContent',
  );

  final response = await http.post(
    uri,
    headers: {
      'x-goog-api-key': _webApiKey,
      'Content-Type': 'application/json',
      'X-Firebase-AppCheck': token,
    },
    body: jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt},
          ],
        },
      ],
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Gemini request failed [${response.statusCode}]: ${response.body}');
  }

  final data = jsonDecode(response.body) as Map<String, dynamic>;
  final candidates = data['candidates'] as List<dynamic>?;
  if (candidates == null || candidates.isEmpty) {
    throw Exception('No response candidates: ${response.body}');
  }
  final content = candidates.first['content'] as Map<String, dynamic>?;
  final parts = (content?['parts'] as List<dynamic>?) ?? const [];
  final text = parts.map((p) => (p as Map<String, dynamic>)['text']?.toString() ?? '').join();
  if (text.trim().isEmpty) {
    throw Exception('Empty response text: ${response.body}');
  }
  return text.trim();
}
