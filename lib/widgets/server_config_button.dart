import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServerConfigButton extends StatelessWidget {
  final VoidCallback? onSaved;
  const ServerConfigButton({super.key, this.onSaved});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings),
      tooltip: 'Server Settings',
      onPressed: () async {
        final bool? saved = await showDialog<bool>(
          context: context,
          builder: (context) => const _ServerConfigDialog(),
        );
        if (saved == true) {
          onSaved?.call();
        }
      },
    );
  }
}

class _ServerConfigDialog extends StatefulWidget {
  const _ServerConfigDialog();

  @override
  State<_ServerConfigDialog> createState() => _ServerConfigDialogState();
}

class _ServerConfigDialogState extends State<_ServerConfigDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _controller.text = prefs.getString('server_base_url') ?? '';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_base_url', _controller.text.trim());
    if (mounted) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Server address updated')));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Server Configuration'),
      content: _isLoading
          ? const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          : TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Server Address',
                hintText: 'http://ip:port',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.dns),
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _saveConfig,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
