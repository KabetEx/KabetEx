import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kabetex/features/auth/providers/user_provider.dart';
import 'package:kabetex/providers/theme_provider.dart';
import 'package:kabetex/utils/snackbars.dart';
import '../../data/models/user.dart';

class CommunityEditProfilePage extends ConsumerStatefulWidget {
  final UserProfile user;
  const CommunityEditProfilePage({super.key, required this.user});

  @override
  ConsumerState<CommunityEditProfilePage> createState() =>
      _CommunityEditProfilePageState();
}

class _CommunityEditProfilePageState
    extends ConsumerState<CommunityEditProfilePage> {
  late final TextEditingController nameCtrl;
  late final TextEditingController bioCtrl;
  late final TextEditingController phoneCtrl;
  late final TextEditingController emailCtrl;
  String? selectedYear;

  File? pendingImage;
  String? tempAvatarUrl;

  final List<String> years = ['1st Year', '2nd Year', '3rd Year', '4th Year'];

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.user.name);
    bioCtrl = TextEditingController(text: widget.user.bio);
    phoneCtrl = TextEditingController(text: widget.user.pNumber);
    emailCtrl = TextEditingController(text: widget.user.email);
    tempAvatarUrl = widget.user.avatarUrl;
    selectedYear = widget.user.year;
  }

  Future<void> selectImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    setState(() => pendingImage = File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    final editState = ref.watch(editProfileProvider);
    final isDark = ref.watch(isDarkModeProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Edit Profile",
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            fontSize: 22,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          children: [
            // Avatar
            Center(
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: pendingImage != null
                          ? FileImage(pendingImage!)
                          : CachedNetworkImageProvider(
                              widget.user.avatarUrl.isNotEmpty
                                  ? widget.user.avatarUrl
                                  : '',
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: selectImage,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.deepOrangeAccent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Name field
            _buildTextField(
              controller: nameCtrl,
              label: "Name",
              isDark: isDark,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 20),

            // Phone field
            _buildTextField(
              controller: phoneCtrl,
              label: "Phone Number",
              isDark: isDark,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),

            // Email field
            _buildTextField(
              controller: emailCtrl,
              label: "Email",
              isDark: isDark,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),

            // Year dropdown
            DropdownButtonFormField<String>(
              initialValue: selectedYear,
              items: years
                  .map(
                    (year) => DropdownMenuItem(
                      value: year,
                      child: Text(
                        year,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (val) => setState(() => selectedYear = val!),
              decoration: InputDecoration(
                labelText: "Year",
                labelStyle: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
                filled: true,
                fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.deepOrange),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Bio field
            _buildTextField(
              controller: bioCtrl,
              label: "Bio",
              isDark: isDark,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
              hintText: "Tell people about yourself...",
            ),
            const SizedBox(height: 40),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: editState.isLoading
                    ? null
                    : () async {
                        FocusScope.of(context).unfocus();

                        String? avatarUrl = tempAvatarUrl;

                        // upload avatar if changed
                        if (pendingImage != null) {
                          avatarUrl = await ref
                              .read(editProfileProvider.notifier)
                              .uploadAvatar(widget.user.id!, pendingImage!);
                        }

                        await ref
                            .read(editProfileProvider.notifier)
                            .updateUser(
                              userId: widget.user.id!,
                              name: nameCtrl.text.trim(),
                              bio: bioCtrl.text.trim(),
                              avatarUrl: avatarUrl,
                              pNumber: phoneCtrl.text.trim(),
                              email: emailCtrl.text.trim(),
                              year: selectedYear ?? '1st',
                            );

                        if (mounted) {
                          SuccessSnackBar.show(
                            context: context,
                            message: 'Updated profile successfully!',
                            isDark: isDark,
                          );
                          //refresh user profile
                          ref.refresh(userByIDProvider(widget.user.id!));
                          Navigator.pop(context);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                child: editState.isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      )
                    : const Text(
                        "Update Profile",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required bool isDark,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.done,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int maxLines = 1,
    String? hintText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.grey[300] : Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: hintText,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 20,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: isDark ? Colors.grey[700]! : Colors.grey[400]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.deepOrange),
        ),
        filled: true,
        fillColor: isDark ? Colors.grey[900] : Colors.white12,
      ),
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
    );
  }
}
