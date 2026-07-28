import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/app_provider.dart';
import '../services/supabase_service.dart';
import '../services/localization_service.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isUploading = false;

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocalizationService.translate(context, 'logout_confirm_title')),
        content: Text(LocalizationService.translate(context, 'logout_confirm_msg')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(LocalizationService.translate(context, 'no')),
          ),
          TextButton(
            onPressed: () {
              SupabaseService.signOut();
              Navigator.pop(context);
            },
            child: Text(
              LocalizationService.translate(context, 'yes'),
              style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadImage(AppProvider provider) async {
    final ImagePicker picker = ImagePicker();
    
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image == null) return;

      setState(() => _isUploading = true);

      // Upload using the refactored method (only 1 argument: the file)
      await SupabaseService.uploadAvatar(File(image.path));
      await provider.refreshProfile();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LocalizationService.translate(context, 'upload_success'))),
        );
      }
    } catch (e) {
      debugPrint("UI UPLOAD ERROR: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LocalizationService.translate(context, 'upload_error'))),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        if (!provider.isAuthenticated) {
          return Scaffold(
            appBar: AppBar(
              title: Text(LocalizationService.translate(context, 'profile')),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => provider.setSelectedIndex(0),
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.account_circle_outlined, size: 100, color: Colors.amber),
                    const SizedBox(height: 24),
                    Text(
                      LocalizationService.translate(context, 'login_benefit'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(LocalizationService.translate(context, 'register'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        side: const BorderSide(color: Colors.amber),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(LocalizationService.translate(context, 'login'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.amber)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final profile = provider.profile;

        return Scaffold(
          appBar: AppBar(
            title: Text(LocalizationService.translate(context, 'profile')),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => provider.setSelectedIndex(0), // Go back to Home
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _buildAvatarSection(context, profile?.avatarUrl, provider),
              const SizedBox(height: 32),
              _buildPointsCard(context, profile?.points ?? 0),
              const SizedBox(height: 32),
              
              _buildSectionHeader(context, LocalizationService.translate(context, 'public_profile')),
              _buildInfoTile(Icons.person_outline, LocalizationService.translate(context, 'full_name'), profile?.fullName ?? '...'),
              _buildInfoTile(Icons.work_outline_rounded, LocalizationService.translate(context, 'profession'), _getProfessionName(context, profile?.professionId ?? 0)),
              
              const SizedBox(height: 24),
              _buildSectionHeader(context, LocalizationService.translate(context, 'account_info')),
              _buildInfoTile(Icons.phone_outlined, LocalizationService.translate(context, 'phone_label'), profile?.phone ?? '...'),
              _buildInfoTile(Icons.email_outlined, LocalizationService.translate(context, 'email'), provider.user?.email ?? '...'),
              
              const Divider(height: 48),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                ),
                title: Text(LocalizationService.translate(context, 'logout'), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w800)),
                onTap: () => _showSignOutDialog(context),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatarSection(BuildContext context, String? avatarUrl, AppProvider provider) {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.amber, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.2),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[200],
              backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                  ? NetworkImage(avatarUrl)
                  : null,
              child: avatarUrl == null || avatarUrl.isEmpty
                  ? const Icon(Icons.person_rounded, size: 60, color: Colors.grey)
                  : null,
            ),
          ),
          if (_isUploading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _isUploading ? null : () => _pickAndUploadImage(provider),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt_rounded, size: 20, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getProfessionName(BuildContext context, int id) {
    switch (id) {
      case 1: return LocalizationService.translate(context, 'prof_jeweler');
      case 2: return LocalizationService.translate(context, 'prof_gold_dealer');
      case 3: return LocalizationService.translate(context, 'prof_currency');
      case 4: return LocalizationService.translate(context, 'prof_investor');
      default: return LocalizationService.translate(context, 'prof_other');
    }
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 16, right: 16),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.amber.shade800,
          fontWeight: FontWeight.w800,
          fontSize: 14,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildPointsCard(BuildContext context, int points) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade700, Colors.amber.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(LocalizationService.translate(context, 'total_points'), style: const TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            points.toString(),
            style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text('⭐ Sarraf Gold Puanı', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.amber, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
    );
  }
}
