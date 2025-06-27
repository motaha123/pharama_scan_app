# Pharma Scan - Handwritten Prescription Recognition

## Description
PharmaScan is a mobile application designed to digitize and interpret handwritten medical prescriptions using advanced AI recognition technology. The app addresses the common challenge of deciphering doctors' handwriting, helping users to accurately understand their medication details.

## Key Features
- **Prescription Scanning**: Capture images of handwritten prescriptions through the device camera or upload from gallery
- **AI-Powered Recognition**: Advanced machine learning algorithms to recognize and interpret handwritten medical text
- **Prescription History**: Securely store and access past prescriptions for reference
- **User Authentication**: Secure login and signup system to protect sensitive medical information
- **Intuitive UI/UX**: Clean, accessible interface designed for users of all ages and technical abilities

## Technology Stack
### Frontend
- **Flutter**: Cross-platform framework for building the mobile application
- **Dart**: Programming language for Flutter development
- **Shared Preferences**: Local storage for user session management
- **HTTP Package**: For API communication


### Backend
- **FastApi**: Server-side Python Backend
- **MongoDB**: NoSQL database for storing user and prescription data
- **Bcrypt**: Password hashing for secure user data storage
- 
## Installation

### Prerequisites

- Flutter SDK (2.10.0 or higher)
- Dart SDK (2.16.0 or higher)
- FastAPI (14.x or higher)
- MongoDB (4.4 or higher)


### Backend Setup

1. Clone the repository

```
git clone https://github.com/omr-ql/pharma-scan.git
```

2. Navigate to the backend directory

```
cd pharma-scan/pharma-scan-backend
```

3. Install dependencies

```
npm install
```

4. Create a .env file with the following variables

```
PORT=5000
MONGO_URI=mongodb://localhost:27017/pharmascan
```

5. Start the server

```
uvicorn main-no-auth:app --host
```

### Frontend Setup

1. Navigate to the frontend directory

```
cd ../pharma_scan_app
```

2. Install Flutter dependencies

```
flutter pub get
```

3. Run the app

```
flutter run
```


## Project Structure

```
pharma_scan_app/
├── lib/
│   ├── main.dart                   # App entry point
│   ├── models/                     # Data models
│   │   ├── Medication.dart         # Medication Data model
│   │   └── prescription.dart       # Prescription Data model   
│   ├── screens/                    # App screens
│   │   ├── auth/
│   │   │   ├── welcome_screen.dart # Welcome screen
│   │   │   ├── login_page.dart     # Login screen
│   │   │   └── signup_page.dart    # Signup screen
│   │   ├── home/
│   │   │   └── home_screen.dart    # Home screen
│   │   └── prescription/
│   │       └── history_screen.dart  # History screen
|   |       └── results_screen.dart  # Results from an AI screen
│   ├── services/        
│   │       ├── auth_service.dart 
```
## Usage
1. **Registration/Login**: Create an account or log in with existing credentials
2. **Scan Prescription**: Use the camera to capture a prescription image
3. **View Results**: See the digitized text and extracted medication details
4. **Access History**: Review past prescriptions in the history section

## Project Status
This application is currently under development. The authentication system is fully implemented, and the prescription scanning and recognition features are being refined.

## Contributing
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License
This project is licensed under the MIT License - see the LICENSE file for details.

## Authors 
 - [MHD TAHA](https://github.com/motaha123/) : Contributed in implementing the computer vision model and enhance the accuracy.
 - [OMR ABDULLAH](https://github.com/omr-ql/) : Contributed in implementing the flutter designing and backend programming using node js.  
 - [Sanad Ali]() : Contributed in writing the documentation and presentation. 
 - [Mazen Bahie](https://github.com/MazenBahie) : Contributed in implementing connect the AI model to our flutter app.س 
 - [Malik Yahya](https://github.com/Malekyahya) : Contributed implementing the natural language processing model and enhance the segmentation.

## Acknowledgements

- [Flutter](https://flutter.dev/)
- [FastAPI](https://fastapi.tiangolo.com/)
- [MongoDB](https://www.mongodb.com/)