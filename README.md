# GigFinder

[![Flutter](https://img.shields.io/badge/Flutter-3.27.0-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.6%2B-0175C2?logo=dart&logoColor=white)](https://dart.dev/)
[![Supabase](https://img.shields.io/badge/Backend-Supabase-3ECF8E?logo=supabase&logoColor=white)](https://supabase.com/)
[![Build APK](https://github.com/VorugantiRahul/GIG_FINDER/actions/workflows/build-apk.yml/badge.svg)](https://github.com/VorugantiRahul/GIG_FINDER/actions/workflows/build-apk.yml)

GigFinder is a cross-platform Flutter application that connects people with internships, projects, and job opportunities. Users can create a profile, discover opportunities by category, submit applications, communicate with others, and keep track of notifications and application activity.

## Features

- Email and password authentication with OTP-based flows
- Opportunity discovery across internships, projects, IT jobs, and other categories
- Opportunity details and application submission
- Application history and status tracking
- User profiles with skills, experience, and profile preview
- Real-time chat and notifications powered by Supabase
- Image and file selection for profile and application workflows
- Light and dark theme support
- Android, iOS, Web, Windows, macOS, and Linux targets
- Automated release APK builds through GitHub Actions

## Tech Stack

- **Frontend:** Flutter and Dart
- **State and services:** Provider, custom service layer
- **Backend:** Supabase Auth, PostgreSQL, and Realtime
- **Storage and device data:** Shared Preferences, image picker, and file picker
- **CI/CD:** GitHub Actions

## Project Structure

```text
lib/
├── auth/          Authentication managers and providers
├── models/        Application data models
├── screens/       Login, profile, opportunity, chat, and notification screens
├── services/      Authentication, user, opportunity, application, and chat services
├── supabase/      Supabase configuration, schema, and security policies
├── widgets/       Reusable UI components
├── main.dart      Application entry point
└── theme.dart     Light and dark application themes
```

## Requirements

- Flutter 3.27.0 or later
- Dart 3.6.0 or later
- Android Studio or Xcode for mobile builds
- A Supabase project for authentication and application data

Check your local installation with:

```bash
flutter doctor
flutter --version
```

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/VorugantiRahul/GIG_FINDER.git
cd GIG_FINDER
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure Supabase

1. Create or open a project in [Supabase](https://supabase.com/).
2. Run the SQL in `lib/supabase/supabase_tables.sql` to create the database tables.
3. Apply the policies in `lib/supabase/supabase_policies.sql`.
4. Update the Supabase URL and anonymous key in `lib/supabase/supabase_config.dart` if you are using a different project.
5. Configure email authentication and redirect settings in the Supabase dashboard.

Use the public `anon` key in the Flutter client. Never place a Supabase `service_role` key in the application or commit it to source control.

### 4. Run the application

```bash
flutter run
```

To run on a specific device:

```bash
flutter devices
flutter run -d <device-id>
```

## Building

Build a release APK:

```bash
flutter build apk --release
```

Build for the web:

```bash
flutter build web --release
```

The generated Android APK is written to:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Every push to `main` runs the GitHub Actions workflow in `.github/workflows/build-apk.yml`. A successful workflow uploads the release APK as an artifact and creates a GitHub release.

## Testing and Analysis

Run the test suite:

```bash
flutter test
```

Run static analysis:

```bash
flutter analyze
```

## Configuration Notes

The current Supabase client configuration is stored in `lib/supabase/supabase_config.dart`. For production deployments, consider moving project-specific values to a secure build-time configuration process and rotate any credentials that may have been exposed publicly.

## Contributing

1. Create a feature branch from `main`.
2. Make focused changes and add tests where appropriate.
3. Run `flutter analyze` and `flutter test`.
4. Open a pull request with a clear summary of the change.

## License

No license has been specified for this repository yet. Contact the repository owner before redistributing or using the project commercially.

