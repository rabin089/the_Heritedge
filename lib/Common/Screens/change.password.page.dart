import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      final email = user?.email;

      if (user == null || email == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'User not signed in.',
        );
      }

      // ✅ Step 1: Re-authenticate with current password
      final credential = EmailAuthProvider.credential(
        email: email,
        password: _currentPasswordController.text.trim(),
      );

      await user.reauthenticateWithCredential(credential);

      // ✅ Step 2: Update password
      await user.updatePassword(_newPasswordController.text.trim());

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully')),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String message = "Something went wrong.";
      if (e.code == 'wrong-password') {
        message = 'Current password is incorrect.';
      } else if (e.code == 'weak-password') {
        message = 'New password is too weak.';
      } else {
        message = e.message ?? message;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Enter a new password";
    }
    if (value.length < 6) {
      return "At least 6 characters";
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return "Include at least one uppercase letter";
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return "Include at least one lowercase letter";
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return "Include at least one number";
    }
    if (!RegExp(r'[!@#\$&*~]').hasMatch(value)) {
      return "Include at least one special character";
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Confirm your new password";
    }
    if (value != _newPasswordController.text) {
      return "Passwords do not match";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Password"),
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _currentPasswordController,
                obscureText: !_showCurrent,
                decoration: InputDecoration(
                  labelText: "Current Password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_showCurrent ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _showCurrent = !_showCurrent),
                  ),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter your current password" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                obscureText: !_showNew,
                decoration: InputDecoration(
                  labelText: "New Password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_showNew ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _showNew = !_showNew),
                  ),
                ),
                validator: _validateNewPassword,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_showConfirm,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_showConfirm ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _showConfirm = !_showConfirm),
                  ),
                ),
                validator: _validateConfirmPassword,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(color: Colors.white),
                  ),
                  onPressed: _isLoading ? null : _handleChangePassword,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Change Password"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}