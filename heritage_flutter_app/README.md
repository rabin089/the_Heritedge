# Heritage Flutter App

This Flutter application is designed to showcase heritage sites by fetching data from a Firestore database. The app includes a user-friendly interface with dropdowns for filtering heritage sites based on region and category.

## Project Structure

```
heritage_flutter_app
├── lib
│   ├── main.dart                # Entry point of the application
│   ├── screens
│   │   └── home_screen.dart     # Main UI of the application
│   ├── widgets
│   │   └── filter_section_widget.dart # Widget for filtering heritage sites
│   └── services
│       └── firestore_service.dart # Service for Firestore database interactions
├── pubspec.yaml                 # Project configuration and dependencies
└── README.md                    # Project documentation
```

## Setup Instructions

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd heritage_flutter_app
   ```

2. **Install dependencies:**
   Make sure you have Flutter installed on your machine. Then run:
   ```bash
   flutter pub get
   ```

3. **Configure Firebase:**
   - Create a Firebase project in the [Firebase Console](https://console.firebase.google.com/).
   - Add your Flutter app to the Firebase project.
   - Download the `google-services.json` file and place it in the `android/app` directory.
   - Follow the instructions to set up Firebase for both Android and iOS.

4. **Run the application:**
   Use the following command to run the app:
   ```bash
   flutter run
   ```

## Usage

- Upon launching the app, users will see dropdowns for selecting regions and categories.
- Selecting an option from the dropdown will trigger a fetch from the Firestore database, displaying the relevant heritage sites.

## Dependencies

This project uses the following dependencies:
- `firebase_core`: For initializing Firebase.
- `cloud_firestore`: For interacting with Firestore database.

Make sure to check the `pubspec.yaml` file for the complete list of dependencies and their versions.

## License

This project is licensed under the MIT License - see the LICENSE file for details.