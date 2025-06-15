import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  factory TokenManager() => _instance;

  TokenManager._internal();

  late SupabaseClient _supabaseClient;
  late SharedPreferences _prefs;

  String? _currentToken;
  DateTime? _lastFetchedTime;

  final String _supabaseUrl = 'https://lficmsegsbvglhdmbbbt.supabase.co'; // Constructed from project ID
  final String _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxmaWNtc2Vnc2J2Z2xoZG1iYmJ0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk5MTU1NjcsImV4cCI6MjA2NTQ5MTU2N30.f1vqGLq7L2s0W3e6mvClITKqPZ8yvyFo8JADXB5qhQc'; // Provided API key
  final String _tokenTableName = 'api_tokens'; // Assuming your table name is 'api_tokens'
  final String _tokenColumnName = 'token_value'; // Assuming your token column name is 'token_value'
  final String _localTokenKey = 'api_token';

  Future<void> initialize() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
    );
    _supabaseClient = Supabase.instance.client;
    _prefs = await SharedPreferences.getInstance();
    _currentToken = _prefs.getString(_localTokenKey);
  }

  Future<String?> getApiToken() async {
    // Implement caching and refresh logic here
    // For simplicity, let's always fetch from Supabase for now
    // In a real app, you'd add logic to check _lastFetchedTime and refresh periodically

    try {
      final response = await _supabaseClient
          .from(_tokenTableName)
          .select(_tokenColumnName)
          .single();

      final newToken = response[_tokenColumnName] as String?;

      if (newToken != null && newToken != _currentToken) {
        _currentToken = newToken;
        await _prefs.setString(_localTokenKey, newToken);
        print('API Token updated from Supabase.');
      } else if (newToken == null) {
        print('No token found in Supabase.');
      }
    } catch (e) {
      print('Error fetching token from Supabase: $e');
      // Fallback to locally stored token if Supabase fetch fails
      if (_currentToken == null) {
        _currentToken = _prefs.getString(_localTokenKey);
      }
    }
    return _currentToken;
  }

  // Optional: Method to force refresh token
  Future<String?> forceRefreshApiToken() async {
    _currentToken = null; // Clear current token to force fetch
    return await getApiToken();
  }
}


