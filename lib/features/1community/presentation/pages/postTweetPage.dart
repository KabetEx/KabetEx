import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/core/snackbars.dart';
import 'package:kabetex/features/1community/data/community_repo.dart';
import 'package:kabetex/features/1community/providers/user_provider.dart';
import 'package:kabetex/features/profile/widgets/not_logged_In.dart';
import 'package:kabetex/providers/theme_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostTweetPage extends ConsumerStatefulWidget {
  const PostTweetPage({super.key});

  @override
  ConsumerState<PostTweetPage> createState() => _PostTweetPageState();
}

class _PostTweetPageState extends ConsumerState<PostTweetPage> {
  final repo = CommunityRepository(client: Supabase.instance.client);
  final _user = Supabase.instance.client.auth.currentUser;
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  String _audience = 'Everyone';
  bool _isPosting = false;

  bool get _canPost => _controller.text.trim().isNotEmpty;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
    final isDark = ref.watch(isDarkModeProvider);
    final userProfile = await ref.watch(currentUserProvider.future);

    if (!_canPost) return;
    setState(() => _isPosting = true);

    final content = _controller.text.trim();

    try {
      await repo.createPost(
        userId: _user!.id,
        content: content,
        full_name: userProfile!.name,
      );
      SuccessSnackBar.show(
        context: context,
        message: 'Posted Successfully',
        isDark: isDark,
      );
    } catch (e) {
      FailureSnackBar.show(context, 'Error posting: $e', isDark);
    }

    setState(() {
      _controller.clear();
      _isPosting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New Post',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
        actions: [
          TextButton(
            onPressed: _canPost && !_isPosting ? _submitPost : null,
            child: _isPosting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.deepOrange,
                    ),
                  )
                : Text(
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
      body: _user == null
          ? const NotLoggedIn()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // User avatar + Text field
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          backgroundImage: NetworkImage(
                            'https://i.pravatar.cc/150?img=12',
                          ), // placeholder
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            key: _formKey,
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
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                              border: InputBorder.none,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Audience selector + character counter
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[850] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.black26
                                    : Colors.grey.withAlpha(100),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _audience,
                              dropdownColor: isDark
                                  ? Colors.grey[900]
                                  : Colors.white,
                              items: ['Everyone', 'Friends', 'Classmates']
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(
                                        e,
                                        style: TextStyle(
                                          fontFamily: 'Open sans',
                                          fontSize: 16,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                if (val != null)
                                  setState(() => _audience = val);
                              },
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),

                        Text(
                          '${_controller.text.length}/280',
                          style: TextStyle(
                            fontSize: 12,
                            color: _controller.text.length > 250
                                ? Colors.deepOrange
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    const Divider(),
                  ],
                ),
              ),
            ),
    );
  }
}
