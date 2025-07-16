import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskmanagement/services/tts_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  void signUserOut() {
    FirebaseAuth.instance.signOut();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Settings",
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        foregroundColor: colorScheme.onSurface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Accessibility Section
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text("Accessibility",
                style: Theme.of(context).textTheme.titleMedium),
          ),
          Card(
            color: colorScheme.secondary,
            elevation: 2.5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: SwitchListTile(
              title: const Text("Read tasks aloud (TTS)"),
              value: context.watch<TtsProvider>().ttsEnabled,
              onChanged: (val) {
                context.read<TtsProvider>().setTtsEnabled(val);
              },
              secondary: const Icon(Icons.record_voice_over),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),

          // Account Section
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text("Account",
                style: Theme.of(context).textTheme.titleMedium),
          ),
          Card(
            color: colorScheme.secondary,
            elevation: 2.5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text("Sign Out"),
              onTap: signUserOut,
            ),
          ),

          // About Section
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text("About", style: Theme.of(context).textTheme.titleMedium),
          ),
          GestureDetector(
            child: Card(
              color: colorScheme.secondary,
              elevation: 2.5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text("App Version"),
                    subtitle: const Text("1.0.0"),
                  ),
                  Divider(
                    indent: 16,
                    endIndent: 16,
                    thickness: 1,
                    color: Colors.grey.withOpacity(0.8), // Set your desired opacity here
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                          fontSize: 15,
                        ),
                        children: [
                          TextSpan(
                            text: "Stay organized, focused, and in control with our all-in-one "
                          ),
                          TextSpan(
                            text: "Task Management and Schedule Planner app.",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("About This App"),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Stay organized, focused, and in control with our all-in-one Task Management and Schedule Planner app.",
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Features include:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text("• Smart scheduling with reminders and deadlines."),
                        Text("• Task prioritization and custom categories."),
                        Text("• Voice input with automatic date/time detection."),
                        Text("• Attach links or notes to tasks."),
                        Text("• Profile page and personal stats."),
                        Text("• Theme shop with lots of different themes."),
                        Text("• Clean, user-friendly design."),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Close"),
                    ),
                  ],
                ),
              );
            },

          ),
        ],
      ),
    );
  }
}