import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/pos_provider.dart';
import '../services/backup_service.dart';

class BackupSettingsScreen extends StatefulWidget {
  const BackupSettingsScreen({super.key});

  @override
  State<BackupSettingsScreen> createState() => _BackupSettingsScreenState();
}

class _BackupSettingsScreenState extends State<BackupSettingsScreen> {
  final BackupService _backupService = BackupService();
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
  }

  void _showSnackBar(String message, bool isSuccess) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.workSans(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _exportLocal() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Preparing local backup file...';
    });

    try {
      final file = await _backupService.exportLocalBackup();
      setState(() => _isLoading = false);

      String msg = 'Backup file exported successfully!';
      if (file != null) {
        if (file.path.contains('/Download/')) {
          msg = 'Backup saved automatically to Downloads folder!';
        } else if (file.path.contains('/Android/data/')) {
          msg = 'Backup saved to App External Storage!';
        } else {
          msg = 'Backup saved to app documents!';
        }

        // Open sharing dialog to allow the user to save it locally/send it
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'SparkBill Backup',
          text: 'SparkBill backup file containing products, bills, and settings.',
        );
      }

      _showSnackBar(msg, true);
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Local backup failed: $e', false);
    }
  }

  Future<void> _importLocal() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Opening file picker...';
    });

    try {
      final data = await _backupService.importLocalBackup();
      if (data != null) {
        if (mounted) {
          context.read<POSProvider>().importBackupData(data);
        }
        _showSnackBar('Backup restored and merged successfully!', true);
      } else {
        _showSnackBar('Import canceled', false);
      }
    } catch (e) {
      _showSnackBar('Restore failed: $e', false);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Google Drive cloud backup methods removed.

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Backup & Restore',
          style: GoogleFonts.workSans(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: -0.5,
            color: const Color(0xFFF43F5E),
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFF43F5E)),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            height: 1,
          ),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Appearance / Dark Mode Section
              _buildSectionHeader('Appearance'),
              const SizedBox(height: 8),
              _buildCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          context.watch<POSProvider>().isDarkMode ? Icons.dark_mode : Icons.light_mode,
                          color: const Color(0xFFF43F5E),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Dark Mode',
                          style: GoogleFonts.workSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: context.watch<POSProvider>().isDarkMode,
                      onChanged: (value) {
                        context.read<POSProvider>().setDarkMode(value);
                      },
                      activeThumbColor: const Color(0xFFF43F5E),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Local Storage Section
              _buildSectionHeader('Local Backup & Restore'),
              const SizedBox(height: 8),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Export data to a local JSON file or import a previously saved JSON file to restore products and invoices.',
                      style: GoogleFonts.workSans(
                        fontSize: 13,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _exportLocal,
                            icon: const Icon(Icons.download, size: 18, color: Colors.white),
                            label: const Text('Export Local'),
                            style: _buttonStyle(const Color(0xFFF43F5E)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isLoading ? null : _importLocal,
                            icon: const Icon(Icons.upload, size: 18, color: Color(0xFFF43F5E)),
                            label: const Text('Import Local'),
                            style: _outlinedButtonStyle(const Color(0xFFF43F5E)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),


            ],
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: Center(
                child: Card(
                  color: Theme.of(context).colorScheme.surface,
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF43F5E)),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _statusMessage.isEmpty ? 'Please wait...' : _statusMessage,
                          style: GoogleFonts.workSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      title,
      style: GoogleFonts.workSans(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF515F74),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  ButtonStyle _buttonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: GoogleFonts.workSans(
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
    );
  }

  ButtonStyle _outlinedButtonStyle(Color color) {
    return OutlinedButton.styleFrom(
      foregroundColor: color,
      side: BorderSide(color: color),
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: GoogleFonts.workSans(
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
    );
  }
}
