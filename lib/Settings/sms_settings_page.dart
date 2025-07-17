import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:interest_book/Utils/app_colors.dart';

class SmsSettingsPage extends StatefulWidget {
  const SmsSettingsPage({super.key});

  @override
  State<SmsSettingsPage> createState() => _SmsSettingsPageState();
}

class _SmsSettingsPageState extends State<SmsSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  final _senderIdController = TextEditingController();
  final _businessNameController = TextEditingController();
  
  String _selectedGateway = 'textlocal';
  bool _isLoading = false;
  bool _smsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _senderIdController.dispose();
    _businessNameController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _smsEnabled = prefs.getBool('sms_enabled') ?? false;
      _selectedGateway = prefs.getString('sms_gateway') ?? 'textlocal';
      _apiKeyController.text = prefs.getString('sms_api_key') ?? '';
      _senderIdController.text = prefs.getString('sms_sender_id') ?? 'OMJWLR';
      _businessNameController.text = prefs.getString('business_name') ?? 'Om Jewellers';
    });
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('sms_enabled', _smsEnabled);
      await prefs.setString('sms_gateway', _selectedGateway);
      await prefs.setString('sms_api_key', _apiKeyController.text.trim());
      await prefs.setString('sms_sender_id', _senderIdController.text.trim());
      await prefs.setString('business_name', _businessNameController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SMS settings saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving settings: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS Settings'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _saveSettings,
            icon: _isLoading 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.save),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSmsToggle(),
            const SizedBox(height: 24),
            if (_smsEnabled) ...[
              _buildGatewaySelection(),
              const SizedBox(height: 16),
              _buildApiKeyField(),
              const SizedBox(height: 16),
              _buildSenderIdField(),
              const SizedBox(height: 16),
              _buildBusinessNameField(),
              const SizedBox(height: 24),
              _buildInstructions(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSmsToggle() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.sms,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enable SMS Notifications',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Send automatic SMS reminders to customers',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _smsEnabled,
              onChanged: (value) {
                setState(() {
                  _smsEnabled = value;
                });
              },
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGatewaySelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SMS Gateway',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedGateway,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'textlocal',
                  child: Text('TextLocal (Recommended for India)'),
                ),
                DropdownMenuItem(
                  value: 'msg91',
                  child: Text('MSG91'),
                ),
                DropdownMenuItem(
                  value: 'fast2sms',
                  child: Text('Fast2SMS'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedGateway = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiKeyField() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TextFormField(
          controller: _apiKeyController,
          decoration: const InputDecoration(
            labelText: 'API Key',
            border: OutlineInputBorder(),
            helperText: 'Get this from your SMS gateway provider',
          ),
          validator: (value) {
            if (_smsEnabled && (value == null || value.trim().isEmpty)) {
              return 'API Key is required when SMS is enabled';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildSenderIdField() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TextFormField(
          controller: _senderIdController,
          decoration: const InputDecoration(
            labelText: 'Sender ID',
            border: OutlineInputBorder(),
            helperText: 'Usually 6 characters (e.g., OMJWLR)',
          ),
          maxLength: 6,
          validator: (value) {
            if (_smsEnabled && (value == null || value.trim().isEmpty)) {
              return 'Sender ID is required when SMS is enabled';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildBusinessNameField() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TextFormField(
          controller: _businessNameController,
          decoration: const InputDecoration(
            labelText: 'Business Name',
            border: OutlineInputBorder(),
            helperText: 'This will appear in SMS messages',
          ),
          validator: (value) {
            if (_smsEnabled && (value == null || value.trim().isEmpty)) {
              return 'Business name is required when SMS is enabled';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'Setup Instructions',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '1. Register with your chosen SMS gateway provider\n'
              '2. Get your API key from the provider dashboard\n'
              '3. Register a Sender ID (usually takes 1-2 days)\n'
              '4. Enter the credentials above and save\n'
              '5. Test by sending a reminder SMS',
              style: TextStyle(color: Colors.blue[700]),
            ),
          ],
        ),
      ),
    );
  }
}
