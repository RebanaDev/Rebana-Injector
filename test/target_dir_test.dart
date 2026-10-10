import 'package:flutter_test/flutter_test.dart';
import 'package:rebana_injector/main.dart';

void main() {
  test('windows memakai %APPDATA%', () {
    expect(
      targetDirPath('windows', {'APPDATA': r'C:\Users\me\AppData\Roaming'}),
      r'C:\Users\me\AppData\Roaming\Growtopia\scripts',
    );
  });

  test('windows tanpa APPDATA dilempar, bukan path ngawur', () {
    expect(() => targetDirPath('windows', const {}), throwsStateError);
  });

  test('android memakai shared storage scripts dir', () {
    expect(
      targetDirPath('android', const {}),
      '/storage/emulated/0/Android/media/com.rtsoft.growtopia/scripts',
    );
  });

  test('platform lain ditolak', () {
    expect(() => targetDirPath('linux', const {}), throwsUnsupportedError);
  });
}