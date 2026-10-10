import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const String kAssetPath = 'assets/loader_rebana.lua';
const String kScriptName = 'loader_rebana.lua';
const String kIconPath = 'assets/icon.jpg';
const MethodChannel _access = MethodChannel('rebana/access');

/// Folder tujuan Growtopia untuk [os]. Murni, tanpa I/O -> bisa diuji.
/// [env] dipakai Windows (APPDATA), diabaikan di platform lain.
String targetDirPath(String os, Map<String, String> env) {
  switch (os) {
    case 'windows':
      final appdata = env['APPDATA'];
      if (appdata == null || appdata.isEmpty) {
        throw StateError('Environment variable APPDATA tidak ditemukan');
      }
      return '$appdata\\Growtopia\\scripts';
    case 'android':
      return '/storage/emulated/0/Android/media/com.rtsoft.growtopia/scripts';
    default:
      throw UnsupportedError('Platform tidak didukung: $os');
  }
}

String get _displayTarget => Platform.isWindows
    ? r'%appdata%\Growtopia\scripts'
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
  String _status = 'Menyiapkan...';
  bool _busy = true;

  @override
  void initState() {
    super.initState();
    inject();
  }

  Future<void> inject() async {
    setState(() {
      _busy = true;
      _status = 'Menginject script...';
    });

    String message;
    try {
      if (Platform.isAndroid && !await _allFilesAccessGranted()) {
        message =
            'Akses folder ditolak.\n'
            'Tekan "Akses File" -> nyalakan "Akses semua file" -> Inject ulang.';
      } else {
        final dir =
            Directory(targetDirPath(Platform.operatingSystem, Platform.environment));
        await dir.create(recursive: true);
        final bytes = await rootBundle.load(kAssetPath);
        final out = File('${dir.path}${Platform.pathSeparator}$kScriptName');
        await out.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
        message = 'Berhasil!\n${out.path}';
      }
    } catch (e) {
      message = 'Gagal: $e';
    }

    if (!mounted) return;
    setState(() {
      _status = message;
      _busy = false;
    });
  }

  void _openAccessSettings() {
    _access.invokeMethod<void>('openSettings').catchError((Object _) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton.icon(
                        onPressed: inject,
                        icon: const Icon(Icons.bolt),
                        label: const Text('Inject'),
                      ),
                      if (Platform.isAndroid) ...[
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: _openAccessSettings,
                          icon: const Icon(Icons.settings),
                          label: const Text('Akses File'),
                        ),
                      ],
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