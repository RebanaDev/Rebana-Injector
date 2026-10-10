# Rebana Injector

Installer script Growtopia untuk **Android** dan **Windows**. Sekali jalan, script
langsung tersalin ke folder `scripts` Growtopia. Gak ada tombol lain.

| Platform | Tujuan |
| --- | --- |
| Android | `/storage/emulated/0/Android/media/com.rtsoft.growtopia/scripts/` |
| Windows  | `%appdata%\Growtopia\scripts` |

## Cara pakai

1. Buka app. Belum ada yang terjadi — app **tidak** nulis apa pun sampai kamu tekan **Inject**.
2. Android (11+): sekali tekan **Akses File** → nyalakan **Akses semua file** → baru tekan **Inject**.
   Android 10 ke bawah langsung bisa tekan **Inject**.
3. Setelah menulis, app baca balik filenya dan bandingkan byte per byte sama dengan asset.
   Kalau panjang atau isi beda, statusnya **GAGAL**, bukan "Berhasil".

## Build sendiri

Butuh Flutter stable.

```bash
bash tool/ci/prepare.sh   # generate android/ + windows/ (tidak di-commit)
flutter pub get
dart run flutter_launcher_icons
flutter run               # atau: flutter build apk --release / flutter build windows --release
```

`flutter test` ngejalanin `test/target_dir_test.dart`.

## Build lewat GitHub Actions

Push ke `main` → artifact/build masuk Actions. Tag `v1.0.0` → APK + ZIP exe otomatis
upload ke Releases.

```bash
git tag v1.0.0 && git push origin v1.0.0
```

> APK release belum ditandatangani (pakai debug key). Tambahin `key.properties` kalau
> butuh install produksi tanpa reinstall.

## Struktur

```
lib/main.dart              UI + logika copy
test/                      cek path tujuan per platform
assets/icon.jpg            ikon launcher (1024x1024)
assets/loader_rebana.lua   payload yang di-inject
tool/android/              overlay AndroidManifest.xml + MainActivity.kt
tool/ci/prepare.sh         generate scaffolding lalu pasang overlay
```

Scaffolding `android/` dan `windows/` sengaja tidak di-commit karena isinya binary
(`gradle-wrapper.jar`, `.ico`). Semuanya di-generate di CI dari `tool/ci/prepare.sh`.

## Catatan

App ini **cuma nyalin file**. Dia tidak ngunduh dan tidak ngejalanin kode apa pun dari
internet. Kalau nanti `assets/loader_rebana.lua` diganti payload yang menarik kode
remote saat runtime, itu di luar tanggung jawab app ini — read dulu sebelum dipakai.