# Studia - Your Personal Student Assistant

A comprehensive Flutter mobile application designed to help students manage their academic life with ease. Studia combines scheduling, file management, productivity tools, and AI-powered features to create an all-in-one study companion.

## Features

### 📚 Academic Management
- **Manageable Class Schedules** - Organize and view your daily/weekly class timetables
- **Real-Time Class Updates** - Stay informed with instant updates about class changes
- **Personalized Profile** - Customize your student profile with avatar and preferences
- **File Management** - Organize and manage course materials for each class

### 🔔 Notifications & Reminders
- **Class Notifications** - Automatic notifications for upcoming classes
- **Event Reminders** - Set reminders for school events and important deadlines
- **Smart Alerts** - Never miss an important class or event

### ⏱️ Productivity Tools
- **Pomodoro Timer** - Boost focus and productivity with interval-based study sessions
- **Audio Recording** - Record lectures and study sessions
- **File Handling** - Open and manage course documents directly in the app

### 🤖 AI Features
- **AI Assistant Chatbot** - Get instant answers and study support powered by AI
- **AI Quiz Maker** - Generate personalized quizzes from your study materials
- **Transcription Support** - Transcribe audio files and convert them into quiz questions
- **Custom Subject Quizzes** - Create AI-generated quizzes for any subject from your files

### 🎨 Additional Features
- **Firebase Integration** - Secure cloud storage and authentication
- **Local Database** - SQLite support for offline functionality
- **Multi-platform Support** - Runs on Android, iOS, Web, Windows, macOS, and Linux

## Tech Stack

- **Framework**: Flutter (Dart)
- **Backend**: Firebase (Authentication, Cloud Firestore)
- **Database**: SQLite (local), Cloud Firestore (cloud)
- **Audio Processing**: flutter_sound, audio_players
- **UI**: Material Design 3, Styled Widget
- **State Management**: Provider
- **Notifications**: flutter_local_notifications
- **File Handling**: file_picker, image_picker
- **Other**: Google Fonts, table_calendar, uuid, just_audio

## Prerequisites

- Flutter SDK (3.7.2 or higher)
- Dart SDK
- Firebase project setup
- Android Studio or Xcode (for mobile development)

## Getting Started

### 1. Clone the Repository
```bash
git clone https://github.com/unknowndevice077/Studia.git
cd Studia
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure Firebase
1. Set up a Firebase project at [firebase.google.com](https://firebase.google.com)
2. Download your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
3. Place them in their respective directories
4. Update `firebase_options.dart` with your Firebase configuration

### 4. Run the App
```bash
flutter run
```

### 5. Build for Production
```bash
# Android
flutter build apk

# iOS
flutter build ios

# Web
flutter build web
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── login/                    # Authentication screens
├── homepage/                 # Main app interface
├── providers/                # State management providers
├── services/                 # Business logic (notifications, etc.)
├── firebase_options.dart     # Firebase configuration
└── ...                       # Other modules
```

## Configuration

The app uses Firebase for backend services. Ensure your Firebase project has:
- **Authentication**: Email/password authentication enabled
- **Cloud Firestore**: Database set up with appropriate security rules
- **Storage**: Cloud Storage for file uploads (if needed)

## API Dependencies

Key packages used:
- `firebase_core` - Firebase initialization
- `firebase_auth` - User authentication
- `cloud_firestore` - Cloud database
- `firebase_ai` - AI features (quiz generation, chatbot)
- `flutter_sound` - Audio recording
- `table_calendar` - Calendar widget
- `provider` - State management

## Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## Contributing

Contributions are welcome! To contribute:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For issues, questions, or suggestions, please [open an issue](https://github.com/unknowndevice077/Studia/issues) on GitHub.

## Author

**unknowndevice077**
- GitHub: [@unknowndevice077](https://github.com/unknowndevice077)

---

**Happy Studying! 📖**
