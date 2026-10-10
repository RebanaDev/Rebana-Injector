import 'package:flutter_test/flutter_test.dart';
import 'package:rebana_injector/main.dart';

void main() {
  test('windows memakai %LOCALAPPDATA%, bukan Roaming', () {
    expect(
      targetDirPath('windows', {
        'LOCALAPPDATA': r'C:\Users\me\AppData\Local',
        'APPDATA': r'C:\Users\me\AppData\Roaming',
      }),
      r'C:\Users\me\AppData\Local\Growtopia\scripts',
    );
  });

  test('windows tanpa LOCALAPPDATA dilempar, bukan path ngawur', () {
    expect(
      () => targetDirPath('windows', {'APPDATA': r'C:\Users\me\AppData\Roaming'}),
      throwsStateError,
    );
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