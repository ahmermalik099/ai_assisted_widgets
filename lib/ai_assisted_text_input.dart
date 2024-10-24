import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// A Flutter widget that provides AI-assisted text input suggestions.
class AIAssistedTextInput extends StatefulWidget {
  final String apiUrl;  // The API endpoint for AI suggestions
  final String apiKey;  // The API key for authorization (if needed)
  final InputDecoration? inputDecoration;

  AIAssistedTextInput({
    required this.apiUrl,
    required this.apiKey,
    this.inputDecoration,
    Key? key,
  }) : super(key: key);

  @override
  _AIAssistedTextInputState createState() => _AIAssistedTextInputState();
}

class _AIAssistedTextInputState extends State<AIAssistedTextInput> {
  final TextEditingController _controller = TextEditingController();
  String _suggestion = '';
  bool _isLoading = false;

  Future<void> _fetchSuggestion(String input) async {
    if (input.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(widget.apiUrl),
        headers: {
          'Authorization': 'Bearer ${widget.apiKey}',  // API key for security
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo-instruct',   // Ensure you're specifying the correct model
          'prompt': input,               // Send user input to the AI model
          'max_tokens': 50,              // Customize token limit based on needs
          'temperature': 0.7,            // Adjust creativity level
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _suggestion = data['choices'][0]['text'].trim();
        });
      } else {
        print('Failed to get response: ${response.statusCode}');
        print('Response body: ${response.body}');
        setState(() {
          _suggestion = 'No suggestions available';
        });
      }
    } catch (e) {
      print('Error occurred: $e');
      setState(() {
        _suggestion = 'Error fetching suggestion';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          onChanged: (value) {
            if (value.length > 2) {
              _fetchSuggestion(value);
            } else {
              setState(() {
                _suggestion = '';
              });
            }
          },
          decoration: widget.inputDecoration ??
              InputDecoration(
                labelText: 'Enter text...',
                suffixIcon: _isLoading ? CircularProgressIndicator() : null,
              ),
        ),
        if (_suggestion.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'AI Suggestion: $_suggestion',
              style: TextStyle(color: Colors.grey),
            ),
          ),
      ],
    );
  }
}
