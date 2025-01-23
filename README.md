# Nutrition App

This is a Flutter-based mobile application designed to help users track their meals and nutritional intake. The app uses Firebase for authentication and Firestore for storing meal data. It also integrates with the Gemini API for image recognition to identify and analyze food items.

## Features

- **User Authentication**: Secure login and registration using Firebase Authentication.
- **Meal Tracking**: Capture and store meal data including name, calories, protein, fat, and carbohydrate content.
- **Image Recognition**: Use the device camera to take pictures of meals and get nutritional information using the Gemini API.
- **Data Storage**: Store meal data in Firestore for easy retrieval and analysis.

## Getting Started

### Prerequisites

- Flutter SDK
- Firebase account
- Gemini API key
- Appwrite account

### Installation

1. **Clone the repository**:

   ```sh
   git clone https://github.com/yourusername/nutrition_app.git
   cd nutrition_app
   ```

2. **Install dependencies**:

   ```sh
   flutter pub get
   ```

3. **Set up Firebase**:

   - Follow the instructions to add Firebase to your Flutter app [here](https://firebase.google.com/docs/flutter/setup).
   - Replace the `firebase_options.dart` file with your Firebase configuration.

4. **Set up Gemini API**:

   - Create a `.env` file in the root directory and add your Gemini API key:
     ```env
     GEMINI_API_KEY=your_gemini_api_key
     ```

5. **Run the app**:
   ```sh
   flutter run
   ```

## Usage

- **Login/Register**: Create an account or log in using your email and password.
- **Scan Meal**: Use the camera button to take a picture of your meal. The app will analyze the image and provide nutritional information.
- **View Meals**: View your logged meals and their nutritional content.

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgements

- [Flutter](https://flutter.dev/)
- [Firebase](https://firebase.google.com/)
- [Gemini API](https://gemini.com/)
- [Appwrite](https://appwrite.io/)
