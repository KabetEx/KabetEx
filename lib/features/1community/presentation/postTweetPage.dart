import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/providers/theme_provider.dart';

class PostTweetPage extends ConsumerStatefulWidget {
  const PostTweetPage({super.key});

  @override
  ConsumerState<PostTweetPage> createState() => _PostPageState();
}

class _PostPageState extends ConsumerState<PostTweetPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  bool get _canPost => _controller.text.trim().isNotEmpty;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitPost() {
    if (_formKey.currentState!.validate()) {
      final text = _controller.text.trim();
      // send to DB / Supabase
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New Post',
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: isDark ? Colors.black : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        centerTitle: false,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _canPost ? _submitPost : null,
            child: Text(
              'Post',
              style: TextStyle(
                color: _canPost ? const Color(0xFFFF6F00) : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile pic
              const CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/150?img=12', // placeholder
                ),
              ),
              const SizedBox(width: 12),
              // Text input
              Expanded(
                child: TextFormField(
                  controller: _controller,
                  autofocus: true,
                  maxLines: null,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: "What's happening?",
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    border: InputBorder.none,
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return null; // we handle button state, no error text
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
