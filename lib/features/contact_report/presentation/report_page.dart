import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kabetex/features/contact_report/data/report_services.dart';
import 'package:kabetex/providers/theme_provider.dart';

class ReportPage extends ConsumerStatefulWidget {
  const ReportPage({super.key});

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage> {
  final _formKey = GlobalKey<FormState>();
  final reportServices = ReportServices();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _suggestionsController = TextEditingController();
  bool isReporting = false;

  String selectedType = 'Bug';
  final types = [
    'Bug',
    'Suggestion',
    'Account Issue',
    'Product Problem',
    'Other',
  ];

  void submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isReporting = true);
    try {
      await reportServices.sendReport(
        _messageController.text,
        _suggestionsController.text,
        selectedType,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Report sent successfully 💌',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(48),
          padding: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32), // <-- here
          ),
          duration: const Duration(seconds: 1),
        ),
      );
      setState(() => isReporting = false);
    } catch (e) {
      print('Error; $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to send report ❌',
            style: TextStyle(fontSize: 16),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
        ),
      );
    } finally {
      setState(() => isReporting = false);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
    _suggestionsController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Report')),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // later upload images
                //report type
                DropdownButton<String>(
                  value: selectedType,
                  icon: const Icon(Icons.arrow_drop_down, size: 36),
                  items: types
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  onChanged: (v) {
                    setState(() => selectedType = v!);
                  },
                ),

                //message
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    maxLines: 4,
                    autofocus: false,
                    enableSuggestions: true,
                    textCapitalization: TextCapitalization.sentences,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.deepOrange),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: Colors.deepOrange),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      hintText: 'Message',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[800],
                      ),
                    ),
                    style: const TextStyle(
                      height: 1.5,
                      fontSize: 18,
                      fontFamily: 'Sans',
                      fontWeight: FontWeight.w500,
                    ),
                    controller: _messageController,
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length < 6) {
                        return 'please enter valid message';
                      }
                      return null;
                    },
                  ),
                ),

                //suggestions
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    maxLines: 3,
                    autofocus: false,
                    enableSuggestions: true,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.deepOrange),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: Colors.deepOrange),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      hintText: 'Any suggestions?',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[800],
                      ),
                    ),
                    style: const TextStyle(
                      height: 1.5,
                      fontSize: 18,
                      fontFamily: 'Sans',
                    ),
                    controller: _suggestionsController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'please enter something';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: ElevatedButton(
                      onPressed: isReporting ? null : submitReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      child: isReporting
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Report',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
