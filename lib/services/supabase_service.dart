import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../models/profession.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // AUTH METHODS
  static User? get currentUser => _client.auth.currentUser;

  static Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required int professionId,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user != null) {
      if (response.session == null) {
        debugPrint("Note: User created but email confirmation is required. Profile will be created after login.");
        return response;
      }

      try {
        await createProfile(UserProfile(
          id: response.user!.id,
          fullName: fullName,
          phone: phone,
          professionId: professionId,
          points: 0,
        ));
      } catch (e) {
        debugPrint("CRITICAL: Auth user created (${response.user!.id}) but profile insertion failed: $e");
        throw 'Profile creation failed: ${e.toString()}';
      }
    }
    return response;
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // DATABASE METHODS
  static Future<void> createProfile(UserProfile profile) async {
    await _client.from('profiles').insert(profile.toJson());
  }

  static Future<UserProfile?> getProfile(String userId) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    
    if (data != null) {
      return UserProfile.fromJson(data);
    }
    return null;
  }

  static Future<void> updateProfile(UserProfile profile) async {
    await _client
        .from('profiles')
        .update(profile.toJson())
        .eq('id', profile.id);
  }

  static Future<List<Profession>> fetchProfessions() async {
    final data = await _client.from('professions').select().order('id');
    return (data as List).map((json) => Profession.fromJson(json)).toList();
  }

  static Future<List<Map<String, dynamic>>> fetchPointsHistory(String userId) async {
    return await _client
        .from('points_history')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
  }

  // STORAGE METHODS
  static Future<String> uploadAvatar(File file) async {
    final user = _client.auth.currentUser;
    final session = _client.auth.currentSession;
    
    if (user == null || session == null) {
      debugPrint("UPLOAD ERROR: No authenticated user or session");
      throw 'Not authenticated';
    }

    final userId = user.id;
    final path = '$userId/profile.jpg';
    
    debugPrint("--- SUPABASE STORAGE UPLOAD TRACE ---");
    debugPrint("Target Bucket: avatars");
    debugPrint("Target Path: $path");
    debugPrint("Auth User ID: ${user.id}");
    debugPrint("Session Valid: ${!session.isExpired}");
    debugPrint("Initiating upload request...");

    try {
      await _client.storage.from('avatars').upload(
        path,
        file,
        fileOptions: const FileOptions(upsert: true),
      );

      final String publicUrl = _client.storage.from('avatars').getPublicUrl(path);
      debugPrint("UPLOAD SUCCESS: $publicUrl");
      
      // Update the profile with the new URL
      await _client.from('profiles').update({'avatar_url': publicUrl}).eq('id', userId);
      
      debugPrint("--- SUPABASE UPLOAD DIAGNOSTIC END (SUCCESS) ---");
      return publicUrl;
    } catch (e) {
      debugPrint("UPLOAD FAILED WITH ERROR: $e");
      debugPrint("--- SUPABASE UPLOAD DIAGNOSTIC END (FAILED) ---");
      rethrow;
    }
  }
}
