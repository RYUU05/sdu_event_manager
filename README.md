# 🎓 SDU Event Manager
A high-performance, cross-platform mobile application designed for SDU students and clubs. This app simplifies campus life by centralizing event discovery, club management, and AI-powered assistance.
---
### 🚀 Features
*   **Smart Event Feed** – Discover academic, sports, and cultural events with personalized recommendations.
*   **Club Management** – Clubs can create events, manage posters, and track participant counts.
*   **UniBuddy (AI Chat)** – An integrated AI assistant to help students with campus-related questions.
*   **Role-Based Access** – Dynamic UI for Students, Club Admins, and Super Admins.
*   **Multilingual Support** – Switch seamlessly between English, Kazakh, and Russian.
*   **Modern Profile** – Customizable user profiles with avatars, banners, and interest tags.
---
### 🧠 Architecture
This project is built using **Clean Architecture** principles to ensure the code is testable, scalable, and easy to maintain.
**State Management:** [BLoC (Business Logic Component)](https://pub.dev/packages/flutter_bloc)
**Flow:**
`UI ➔ Event ➔ BLoC ➔ Repository ➔ Data Source (Firebase/API) ➔ State ➔ UI`
---
### 🛠 Tech Stack
*   **Frontend:** [Flutter](https://flutter.dev) & [Dart](https://dart.dev)
*   **Backend:** [Firebase](https://firebase.google.com) (Auth, Firestore, Storage)
*   **AI Backend:** [FastAPI](https://fastapi.tiangolo.com) (UniBuddy Integration)
*   **Navigation:** [AutoRoute](https://pub.dev/packages/auto_route)
*   **Dependency Injection:** [GetIt](https://pub.dev/packages/get_it)
---
### 📦 Project Structure
```text
lib/
├── core/             # Design system, constants, and DI
├── features/         # Feature-first structure
│   ├── auth/         # Login & Registration
│   ├── events/       # Event creation & Participation
│   ├── home/         # Main feed & UniBuddy
│   ├── settings/     # Profile & Preferences
│   └── applications/ # Club approval logic
└── l10n/             # Multilingual ARB files
```

---
### 📸 Screenshots

<table>
  <tr>
    <td><img src="https://raw.githubusercontent.com/RYUU05/sdu_event_manager/main/screenshots/1.png" width="200"/></td>
    <td><img src="https://raw.githubusercontent.com/RYUU05/sdu_event_manager/main/screenshots/2.png" width="200"/></td>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/RYUU05/sdu_event_manager/main/screenshots/3.png" width="200"/></td>
    <td><img src="https://raw.githubusercontent.com/RYUU05/sdu_event_manager/main/screenshots/4.png" width="200"/></td>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/RYUU05/sdu_event_manager/main/screenshots/5.png" width="200"/></td>
    <td><img src="https://raw.githubusercontent.com/RYUU05/sdu_event_manager/main/screenshots/6.png" width="200"/></td>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/RYUU05/sdu_event_manager/main/screenshots/7.png" width="200"/></td>
    <td><img src="https://raw.githubusercontent.com/RYUU05/sdu_event_manager/main/screenshots/8.png" width="200"/></td>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/RYUU05/sdu_event_manager/main/screenshots/9.png" width="200"/></td>
    <td></td>
  </tr>
</table>

---
### ⚙️ How to Run

Clone the project:
```bash
git clone https://github.com/RYUU05/sdu_event_manager.git
cd sdu_event_manager
```
Install dependencies:
```bash
flutter pub get
```
Generate code (Routes & DI):
```bash
flutter run
```
