import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../models/profession.dart';
import '../services/localization_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  
  // Professions are now localized
  String _getProfessionName(BuildContext context, int id) {
    switch (id) {
      case 1: return LocalizationService.translate(context, 'prof_jeweler');
      case 2: return LocalizationService.translate(context, 'prof_gold_dealer');
      case 3: return LocalizationService.translate(context, 'prof_currency');
      case 4: return LocalizationService.translate(context, 'prof_investor');
      default: return LocalizationService.translate(context, 'prof_other');
    }
  }

  List<Profession> _professions = [
    Profession(id: 1, name: 'Jeweler'),
    Profession(id: 2, name: 'Gold Dealer'),
    Profession(id: 3, name: 'Currency Exchange'),
    Profession(id: 4, name: 'Investor'),
    Profession(id: 5, name: 'Other'),
  ];
  int? _selectedProfessionId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfessions();
  }

  Future<void> _loadProfessions() async {
    try {
      final data = await SupabaseService.fetchProfessions();
      if (data.isNotEmpty) {
        setState(() => _professions = data);
      }
    } catch (e) {
      debugPrint("Professions error: $e");
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return LocalizationService.translate(context, 'required');
    }
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value.trim())) {
      return LocalizationService.translate(context, 'invalid_email_format');
    }
    return null;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate() || _selectedProfessionId == null) return;

    setState(() => _isLoading = true);
    try {
      final phone = _phoneController.text.trim();
      final formattedPhone = phone.startsWith('+') ? phone : '+$phone';

      await SupabaseService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        fullName: _nameController.text.trim(),
        phone: formattedPhone,
        professionId: _selectedProfessionId!,
      );
      
      if (!mounted) return;
      
      Navigator.popUntil(context, (route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocalizationService.translate(context, 'registration_success'))),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      String message = LocalizationService.translate(context, 'unknown_error');
      
      if (e.message.contains('rate limit')) {
        message = LocalizationService.translate(context, 'rate_limit_error');
      } else if (e.message.contains('email')) {
        message = LocalizationService.translate(context, 'invalid_email_format');
      }
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      String message = LocalizationService.translate(context, 'unknown_error');
      
      final errorStr = e.toString();
      if (errorStr.contains('Profile creation failed')) {
        message = errorStr; 
      }
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocalizationService.translate(context, 'register'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: LocalizationService.translate(context, 'full_name'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.name,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'[0-9!@#\$%^&*(),.?":{}|<>]')),
                ],
                validator: (v) => v!.trim().isEmpty ? LocalizationService.translate(context, 'required') : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: LocalizationService.translate(context, 'email'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: LocalizationService.translate(context, 'password'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                obscureText: true,
                validator: (v) => v!.length < 6 ? LocalizationService.translate(context, 'min_characters') : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: LocalizationService.translate(context, 'phone_field'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixText: '+',
                  hintText: '90 5XX XXX XXXX',
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(15),
                ],
                validator: (v) {
                  if (v == null || v.isEmpty) return LocalizationService.translate(context, 'required');
                  if (v.length < 7) return LocalizationService.translate(context, 'min_characters'); // Simplified E.164 min
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: _selectedProfessionId,
                decoration: InputDecoration(
                  labelText: LocalizationService.translate(context, 'profession'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: _professions.map((p) => DropdownMenuItem(
                  value: p.id,
                  child: Text(_getProfessionName(context, p.id)),
                )).toList(),
                onChanged: (val) => setState(() => _selectedProfessionId = val),
                validator: (v) => v == null ? LocalizationService.translate(context, 'required') : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : Text(LocalizationService.translate(context, 'register'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
