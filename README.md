# 🛍️ Local Shopping List App

A cross-platform shopping list application built with **Flutter**. This app allows users to manage their shopping items efficiently with features like adding, editing, and deleting items. The `add-item-screen` branch introduces a dedicated screen for adding new items to the shopping list.

## 📸 Screenshots

![Add Item Screen](./assets/add_item_screen.png) <!-- Replace with actual screenshot path -->

## 🚀 Features

- **Add Items**: Quickly add new items to your shopping list.
- **Edit Items**: Modify existing items to update details.
- **Delete Items**: Remove items that are no longer needed.
- **Cross-Platform Support**: Runs seamlessly on Android, iOS, Web, Windows, macOS, and Linux.

## 🛠️ Installation

1. **Clone the repository**

   ```bash
   git clone -b add-item-screen https://github.com/girish54321/local-shoping-list.git
   cd local-shoping-list
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the app**

   - For Android:
     ```bash
     flutter run -d android
     ```
   - For iOS:
     ```bash
     flutter run -d ios
     ```
   - For Web:
     ```bash
     flutter run -d chrome
     ```
   - For Desktop (Windows/macOS/Linux):
     ```bash
     flutter run -d windows  # or macos/linux
     ```

## 📂 Project Structure

```
├── lib/
│   ├── main.dart           # Entry point of the application
│   ├── screens/            # Contains all the screens
│   │   ├── home_screen.dart
│   │   └── add_item_screen.dart
│   └── widgets/            # Reusable widgets
├── assets/                 # Images and other assets
├── pubspec.yaml            # Project metadata and dependencies
└── README.md               # Project documentation
```

## 🧪 Testing

To run tests:

```bash
flutter test
```

Ensure that all functionalities work as expected, especially the add item feature introduced in this branch.

## 📄 License

This project is licensed under the [MIT License](./LICENSE).

## 🙌 Acknowledgements

Thanks to [Girish Parate](https://github.com/girish54321) for developing and maintaining this project.

---

Feel free to customize this `README.md` further to suit your project's needs. If you have any specific questions or need assistance with additional features, don't hesitate to ask!
