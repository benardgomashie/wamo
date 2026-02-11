import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/wamo_toast.dart';

class SupportScreen extends StatefulWidget {
  final String? campaignId;
  final String? campaignTitle;

  const SupportScreen({
    super.key,
    this.campaignId,
    this.campaignTitle,
  });

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedIssueType = 'general';
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _issueTypes = [
    {'value': 'general', 'label': 'General Inquiry', 'icon': Icons.help_outline},
    {'value': 'payment', 'label': 'Payment Issue', 'icon': Icons.payment},
    {'value': 'report', 'label': 'Report Campaign', 'icon': Icons.flag},
    {'value': 'technical', 'label': 'Technical Problem', 'icon': Icons.bug_report},
    {'value': 'account', 'label': 'Account Help', 'icon': Icons.person},
  ];

  final List<Map<String, String>> _quickLinks = [
    {
      'title': 'How to donate?',
      'description': 'Learn about making secure donations',
    },
    {
      'title': 'Starting a campaign?',
      'description': 'Guide to creating your first campaign',
    },
    {
      'title': 'Payment methods',
      'description': 'Supported payment options and fees',
    },
    {
      'title': 'Payout process',
      'description': 'How and when you receive your funds',
    },
    {
      'title': 'Trust & Safety',
      'description': 'Our verification and security measures',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Try to load user profile
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          setState(() {
            _nameController.text = doc.data()?['name'] ?? '';
            _emailController.text = user.email ?? user.phoneNumber ?? '';
          });
        }
      } catch (e) {
        // User not logged in or profile doesn't exist
      }
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      // Create support ticket in Firestore
      await FirebaseFirestore.instance.collection('support_tickets').add({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'message': _messageController.text.trim(),
        'issue_type': _selectedIssueType,
        'campaign_id': widget.campaignId,
        'campaign_title': widget.campaignTitle,
        'user_id': user?.uid,
        'status': 'open',
        'created_at': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        WamoToast.success(
          context,
          'Your message has been submitted. We\'ll respond within 24 hours.',
        );

        // Clear form
        _formKey.currentState!.reset();
        _messageController.clear();

        // Navigate back after a delay
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        WamoToast.error(context, 'Failed to submit: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _launchWhatsApp() async {
    const phoneNumber = '+233123456789'; // Replace with actual support number
    final message = widget.campaignId != null
        ? 'Hi, I need help with campaign: ${widget.campaignTitle ?? widget.campaignId}'
        : 'Hi, I need help with Wamo';

    final uri = Uri.parse(
      'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open WhatsApp'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _launchEmail() async {
    const email = 'support@wamo.app'; // Replace with actual support email
    final subject = widget.campaignId != null
        ? 'Support Request - Campaign: ${widget.campaignTitle ?? widget.campaignId}'
        : 'Support Request';

    final uri = Uri.parse('mailto:$email?subject=${Uri.encodeComponent(subject)}');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open email app'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Text(
            'How can we help you?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a contact method below or browse our help topics',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),

          // Campaign context (if provided)
          if (widget.campaignId != null) ...[
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Regarding Campaign',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.campaignTitle ?? widget.campaignId!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Quick contact methods
          Text(
            'Contact Us',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _ContactMethodCard(
                  icon: Icons.chat,
                  label: 'WhatsApp',
                  color: Colors.green,
                  onTap: _launchWhatsApp,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ContactMethodCard(
                  icon: Icons.email,
                  label: 'Email',
                  color: Colors.blue,
                  onTap: _launchEmail,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Submit a ticket form
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Submit a Support Ticket',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Issue type dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _selectedIssueType,
                      decoration: const InputDecoration(
                        labelText: 'Issue Type',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _issueTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type['value'],
                          child: Row(
                            children: [
                              Icon(type['icon'], size: 20),
                              const SizedBox(width: 8),
                              Text(type['label']),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedIssueType = value!);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Name field
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Your Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email field
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Message field
                    TextFormField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        labelText: 'Message',
                        border: OutlineInputBorder(),
                        hintText: 'Describe your issue or question...',
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      maxLength: 1000,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your message';
                        }
                        if (value.trim().length < 20) {
                          return 'Please provide more details (at least 20 characters)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitReport,
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text('Submit Ticket'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Quick help links
          Text(
            'Quick Help',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),

          ..._quickLinks.map((link) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.help_outline),
                title: Text(link['title']!),
                subtitle: Text(link['description']!),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Navigate to help article or FAQ
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Opening: ${link['title']}'),
                    ),
                  );
                },
              ),
            );
          }),

          const SizedBox(height: 24),

          // Response time info
          Card(
            color: Colors.grey[100],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.access_time, color: Colors.grey[700]),
                  const SizedBox(height: 8),
                  Text(
                    'Average Response Time: 24 hours',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'We typically respond within one business day',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}

class _ContactMethodCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ContactMethodCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(
                icon,
                size: 40,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
