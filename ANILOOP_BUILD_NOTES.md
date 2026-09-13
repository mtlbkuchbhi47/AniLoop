# AniLoop build notes

This project is the combined starting point requested by the user:

- AniPlay source-driven scraping/catalog/episode extraction/player architecture is retained.
- AnimeDex-inspired AniList metadata/discovery is added as a first-class Home experience.
- Branding is changed to AniLoop, with a new launcher/icon asset.
- The UI is responsive: poster grids use max extents rather than a fixed 3-column layout.
- Dark/light theme is persisted on native platforms and uses a safe in-memory default on web.

## Build locally

Flutter SDK is required on the build machine. The analysis environment used to prepare this archive does not have Flutter installed, so an APK was not compiled here.

```bash
flutter pub get
flutter analyze
flutter build apk --release
```

For iOS, macOS, Windows, Linux and Web, run the corresponding Flutter build command. Streaming extraction is dependent on platform WebView support and the third-party source adapters.
