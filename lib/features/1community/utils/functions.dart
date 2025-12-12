//show report dialog
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kabetex/features/1community/data/community_repo.dart';
import 'package:kabetex/utils/snackbars.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> showReportDialog(
  BuildContext context,
  String postId,
  bool isDark,
) async {
  String? selectedReason;
  final controller = TextEditingController();
  final repo = CommunityRepository(client: Supabase.instance.client);

  await showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Report Post',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //items selector
            DropdownButtonFormField<String>(
              items: ['Spam', 'Offensive content', 'Harassment', 'Other']
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                setState(() {
                  selectedReason = val;
                });
              },
              decoration: InputDecoration(
                labelText: 'Reason',
                labelStyle: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                ),
                filled: true,
                fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              dropdownColor: isDark ? Colors.grey[850] : Colors.white,
            ),
            const SizedBox(height: 12),

            // details textfield
            if (selectedReason == 'Other')
              TextField(
                controller: controller,
                maxLines: 3,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: 'Details (optional)',
                  labelStyle: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        //actions
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: selectedReason == null
                ? null
                : () async {
                    try {
                      await repo.submitReport(
                        postId,
                        selectedReason!,
                        controller.text.trim(),
                        context,
                      );
                      Navigator.pop(context);

                      SuccessSnackBar.show(
                        context: context,
                        isDark: isDark,
                        message: 'Report submitted successfully, thank you!',
                      );
                    } catch (e) {
                      FailureSnackBar.show(
                        context: context,
                        isDark: isDark,
                        message: 'Failed to submit report: $e',
                      );
                    }
                  },
            child: Text(
              'Submit',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selectedReason == null ? Colors.grey[900] : Colors.white,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
