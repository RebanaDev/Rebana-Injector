import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const String kAssetPath = 'assets/loader_rebana.lua';
const String kScriptName = 'loader_rebana.lua';
const String kIconPath = 'assets/icon.jpg';
const MethodChannel _access = MethodChannel('rebana/access');

/// Folder tujuan Growtopia untuk [os]. Murni, tanpa I/O -> bisa diuji.
/// [env] dipakai Windows (LOCALAPPDATA), diabaikan di platform lain.
String targetDirPath(String os, Map<String, String> env) {
  switch (os) {
    case 'windows':
      final local = env['LOCALAPPDATA'];
      if (local == null || local.isEmpty) {
        throw StateError('Environment variable LOCALAPPDATA tidak ditemukan');
      }
      return '$local\\Growtopia\\scripts';
    case 'android':
      return '/storage/emulated/0/Android/media/com.rtsoft.growtopia/scripts';
    default:
      throw UnsupportedError('Platform tidak didukung: $os');
  }
}

String get _displayTarget => Platform.isWindows
    ? r'%LOCALAPPDATA%\Growtopia\scripts'
    : 'Android/media/com.rtsoft.growtopia/scripts';

Future<bool> _allFilesAccessGranted() async {
  try {
    return await _access.invokeMethod<bool>('granted') ?? false;
  } on MissingPluginException {
    return true; // desktop: tidak ada konsep all-files-access
  } on PlatformException {
    return false;
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RebanaApp());
}

class RebanaApp extends StatelessWidget {
  const RebanaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rebana Injector',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF10B981),
        scaffoldBackgroundColor: const Color(0xFF0B0F14),
      ),
      home: const InjectPage(),
    );
  }
}

class InjectPage extends StatefulWidget {
  const InjectPage({super.key});

  @override
  State<InjectPage> createState() => _InjectPageState();
}

class _InjectPageState extends State<InjectPage> {
  String _status = 'Belum di-inject.\nTekan Inject untuk menyalin script.';
  bool _busy = false;

  Directory get _target =>
      Directory(targetDirPath(Platform.operatingSystem, Platform.environment));

  Future<void> inject() async {
    setState(() {
      _busy = true;
      _status = 'Menginject script...';
    });

    String message;
    try {
      if (Platform.isAndroid && !await _allFilesAccessGranted()) {
        message =
            'GAGAL: akses folder belum diizinkan.\n'
            'Tekan "Akses File" -> nyalakan "Akses semua file" -> Inject ulang.';
      } else {
        final dir = _target;
        await dir.create(recursive: true);
        if (!dir.existsSync()) {
          throw StateError('folder tujuan tidak terbentuk: ${dir.path}');
        }

        final expected = (await rootBundle.load(kAssetPath)).buffer.asUint8List();
        final out = File('${dir.path}${Platform.pathSeparator}$kScriptName');
        await out.writeAsBytes(expected, flush: true);

        // Jangan percaya writeAsBytes: baca balik dan bandingkan byte per byte.
        if (!out.existsSync()) {
          throw StateError('file tidak ada setelah ditulis: ${out.path}');
        }
        final written = out.readAsBytesSync();
        if (written.length != expected.length || !listEquals(written, expected)) {
          throw StateError(
              'isi file tidak cocok (tertulis ${written.length} dari ${expected.length} byte)');
        }

        message = 'OK\n${out.path}\n${written.length} byte, isi terverifikasi.';
      }
    } catch (e) {
      message = 'GAGAL: $e';
    }

    if (!mounted) return;
    setState(() {
      _status = message;
      _busy = false;
    });
  }

  Future<void> _openFolder() async {
    try {
      final dir = _target;
      if (!dir.existsSync()) await dir.create(recursive: true);
      if (Platform.isWindows) {
        await Process.run('explorer.exe', [dir.path]);
      } else {
        final relative =
            dir.path.replaceFirst('/storage/emulated/0/', '').replaceAll('\\', '/');
        await Process.run('am', [
          'start',
          '-a',
          'android.intent.action.VIEW',
          '-d',
          'content://com.android.externalstorage.documents/document/primary%3A'
              '${Uri.encodeComponent(relative)}',
        ]);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _status = 'GAGAL buka folder: $e');
    }
  }

  void _copyPath() {
    Clipboard.setData(ClipboardData(text: _target.path));
    if (!mounted) return;
    setState(() => _status = 'Path disalin:\n${_target.path}');
  }

  void _openAccessSettings() {
    _access.invokeMethod<void>('openSettings').catchError((Object _) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(kIconPath, width: 128, height: 128),
                ),
                const SizedBox(height: 20),
                const Text(
                  'REBANA INJECTOR',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 3),
                ),
                const SizedBox(height: 6),
                Text(
                  _displayTarget,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: const TextStyle(height: 1.5),
                ),
                const SizedBox(height: 24),
                if (_busy)
                  const CircularProgressIndicator()
                else
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.icon(
                        onPressed: inject,
                        icon: const Icon(Icons.bolt),
                        label: const Text('Inject'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _openFolder,
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Buka Folder'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _copyPath,
                        icon: const Icon(Icons.copy),
                        label: const Text('Salin Path'),
                      ),
                      if (Platform.isAndroid)
                        OutlinedButton.icon(
                          onPressed: _openAccessSettings,
                          icon: const Icon(Icons.settings),
                          label: const Text('Akses File'),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}