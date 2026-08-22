import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'web_downloader.dart';

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }

  @override
  void close() {
    _client.close();
    super.close();
  }
}

class BackupService {
  static const String _backupFileName = 'sparkbill_backup.json';

  // Set your Google Web Client ID here (if configuring Google Sign-In for Web)
  static const String googleWebClientId = '';

  GoogleSignInAccount? _currentUser;
  GoogleSignInAccount? get currentUser => _currentUser;

  bool _isInitialized = false;

  BackupService() {
    GoogleSignIn.instance.authenticationEvents.listen((event) {
      if (event is GoogleSignInAuthenticationEventSignIn) {
        _currentUser = event.user;
      } else if (event is GoogleSignInAuthenticationEventSignOut) {
        _currentUser = null;
      }
    });
  }

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    if (kIsWeb) {
      if (googleWebClientId.isEmpty) {
        throw Exception(
          'Google Sign-In on Web requires a Client ID.\n'
          'Please configure the "googleWebClientId" constant in lib/services/backup_service.dart.'
        );
      }
      await GoogleSignIn.instance.initialize(
        clientId: googleWebClientId,
      );
    } else {
      await GoogleSignIn.instance.initialize();
    }
    _isInitialized = true;
  }

  /// Silently logs in if a user session exists
  Future<GoogleSignInAccount?> signInSilently() async {
    try {
      await _ensureInitialized();
      _currentUser = await GoogleSignIn.instance.attemptLightweightAuthentication();
      return _currentUser;
    } catch (e) {
      debugPrint('Google Sign-In silent error: $e');
      return null;
    }
  }

  /// Prompts the user to log into Google
  Future<GoogleSignInAccount?> signIn() async {
    try {
      await _ensureInitialized();
      _currentUser = await GoogleSignIn.instance.authenticate();
      return _currentUser;
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      return null;
    }
  }

  /// Logs the user out of Google
  Future<void> signOut() async {
    try {
      await _ensureInitialized();
      await GoogleSignIn.instance.signOut();
      _currentUser = null;
    } catch (e) {
      debugPrint('Google Sign-Out error: $e');
    }
  }

  /// Serializes SharedPreferences backup data as a Map
  Future<Map<String, dynamic>> getLocalBackupData() async {
    final prefs = await SharedPreferences.getInstance();
    final productsJson = prefs.getString('sparkbill_products') ?? '[]';
    final billsJson = prefs.getString('sparkbill_bills') ?? '[]';
    final billCounter = prefs.getInt('sparkbill_bill_counter') ?? 1;

    dynamic decodedProducts = [];
    dynamic decodedBills = [];

    try {
      decodedProducts = json.decode(productsJson);
    } catch (e) {
      debugPrint('Error decoding products for backup: $e');
    }

    try {
      decodedBills = json.decode(billsJson);
    } catch (e) {
      debugPrint('Error decoding bills for backup: $e');
    }

    return {
      'app': 'sparkbill',
      'version': 1,
      'backup_date': DateTime.now().toIso8601String(),
      'products': decodedProducts,
      'bills': decodedBills,
      'bill_counter': billCounter,
    };
  }

  /// Saves a file with the given name and bytes to local storage.
  /// It first tries the public Downloads directory on Android,
  /// then the external storage directory, and falls back to application documents.
  static Future<File?> saveFileToLocalStorage(String fileName, List<int> bytes) async {
    try {
      if (kIsWeb) {
        return null;
      }
      
      File? file;
      
      // 1. Try public Download folder on Android
      if (Platform.isAndroid) {
        try {
          final downloadDir = Directory('/storage/emulated/0/Download');
          if (await downloadDir.exists()) {
            file = File('${downloadDir.path}/$fileName');
            if (await file.exists()) {
              await file.delete();
            }
            await file.writeAsBytes(bytes);
            debugPrint('Saved to public Download folder: ${file.path}');
            return file;
          }
        } catch (e) {
          debugPrint('Error saving to public Download directory: $e');
        }
      }
      
      // 2. Try external storage directory
      try {
        final extDir = await getExternalStorageDirectory();
        if (extDir != null) {
          file = File('${extDir.path}/$fileName');
          if (await file.exists()) {
            await file.delete();
          }
          await file.writeAsBytes(bytes);
          debugPrint('Saved to external storage directory: ${file.path}');
          return file;
        }
      } catch (e) {
        debugPrint('Error saving to external storage directory: $e');
      }
      
      // 3. Fallback to application documents directory
      final appDir = await getApplicationDocumentsDirectory();
      file = File('${appDir.path}/$fileName');
      if (await file.exists()) {
        await file.delete();
      }
      await file.writeAsBytes(bytes);
      debugPrint('Saved to app documents directory: ${file.path}');
      return file;
    } catch (e) {
      debugPrint('All save attempts failed: $e');
      return null;
    }
  }

  /// Exports local backup. On Web, triggers a browser file download and returns null.
  /// On mobile/desktop, writes to the documents directory and returns the File.
  Future<File?> exportLocalBackup() async {
    try {
      final backupData = await getLocalBackupData();
      final backupJson = json.encode(backupData);

      if (kIsWeb) {
        await downloadBackupWeb(backupJson, _backupFileName);
        return null;
      } else {
        final bytes = utf8.encode(backupJson);
        final file = await saveFileToLocalStorage(_backupFileName, bytes);
        return file;
      }
    } catch (e) {
      debugPrint('Local export error: $e');
      rethrow;
    }
  }

  /// Imports a local backup file picked by the user and returns the data.
  Future<Map<String, dynamic>?> importLocalBackup() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        if (kIsWeb) {
          final bytes = result.files.single.bytes;
          if (bytes != null) {
            final content = utf8.decode(bytes);
            final Map<String, dynamic> data = json.decode(content);
            if (data.containsKey('products') || data.containsKey('bills')) {
              return data;
            } else {
              throw const FormatException('Invalid backup file format');
            }
          }
        } else {
          final path = result.files.single.path;
          if (path != null) {
            final file = File(path);
            final content = await file.readAsString();
            final Map<String, dynamic> data = json.decode(content);
            if (data.containsKey('products') || data.containsKey('bills')) {
              return data;
            } else {
              throw const FormatException('Invalid backup file format');
            }
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('Local import error: $e');
      rethrow;
    }
  }

  /// Performs a backup to Google Drive by uploading sparkbill_backup.json
  Future<bool> backupToGoogleDrive() async {
    try {
      await _ensureInitialized();
      var account = _currentUser;
      account ??= await signInSilently();
      account ??= await signIn();

      if (account == null) {
        throw Exception('User is not signed in to Google.');
      }

      final authHeaders = await account.authorizationClient.authorizationHeaders(
        [drive.DriveApi.driveFileScope],
        promptIfNecessary: true,
      );

      if (authHeaders == null) {
        throw Exception('Failed to obtain authorization headers.');
      }

      final authenticateClient = GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(authenticateClient);

      final backupData = await getLocalBackupData();
      final backupJson = json.encode(backupData);
      final bytes = utf8.encode(backupJson);

      final uploadMedia = drive.Media(
        Stream.value(bytes),
        bytes.length,
      );

      // Check if file already exists in Drive
      final fileList = await driveApi.files.list(
        q: "name = '$_backupFileName' and trashed = false",
        spaces: 'drive',
      );

      final existingFile = (fileList.files != null && fileList.files!.isNotEmpty)
          ? fileList.files!.first
          : null;

      if (existingFile != null) {
        final driveFile = drive.File();
        await driveApi.files.update(
          driveFile,
          existingFile.id!,
          uploadMedia: uploadMedia,
        );
      } else {
        final driveFile = drive.File()
          ..name = _backupFileName
          ..mimeType = 'application/json';
        await driveApi.files.create(
          driveFile,
          uploadMedia: uploadMedia,
        );
      }

      authenticateClient.close();
      return true;
    } catch (e) {
      debugPrint('Google Drive backup error: $e');
      rethrow;
    }
  }

  /// Restores a backup file from Google Drive and returns the data.
  Future<Map<String, dynamic>?> restoreFromGoogleDrive() async {
    try {
      await _ensureInitialized();
      var account = _currentUser;
      account ??= await signInSilently();
      account ??= await signIn();

      if (account == null) {
        throw Exception('User is not signed in to Google.');
      }

      final authHeaders = await account.authorizationClient.authorizationHeaders(
        [drive.DriveApi.driveFileScope],
        promptIfNecessary: true,
      );

      if (authHeaders == null) {
        throw Exception('Failed to obtain authorization headers.');
      }

      final authenticateClient = GoogleAuthClient(authHeaders);
      final driveApi = drive.DriveApi(authenticateClient);

      // Query for sparkbill_backup.json in Google Drive
      final fileList = await driveApi.files.list(
        q: "name = '$_backupFileName' and trashed = false",
        spaces: 'drive',
      );

      final existingFile = (fileList.files != null && fileList.files!.isNotEmpty)
          ? fileList.files!.first
          : null;

      if (existingFile == null) {
        authenticateClient.close();
        return null;
      }

      final media = await driveApi.files.get(
        existingFile.id!,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final List<int> bytes = [];
      await for (final chunk in media.stream) {
        bytes.addAll(chunk);
      }

      final String content = utf8.decode(bytes);
      final Map<String, dynamic> data = json.decode(content);

      authenticateClient.close();

      if (data.containsKey('products') || data.containsKey('bills')) {
        return data;
      } else {
        throw const FormatException('Invalid backup file downloaded from Drive');
      }
    } catch (e) {
      debugPrint('Google Drive restore error: $e');
      rethrow;
    }
  }
}
