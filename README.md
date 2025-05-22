# The Magnificent Three - Brain Tumor Classification System

A powerful and user-friendly application that combines Flutter for the frontend and machine learning for brain tumor classification. This project provides a seamless interface for medical professionals and researchers to classify brain tumor images using various machine learning models.

## 🚀 Features

- **Multiple ML Models**: Support for various classification algorithms:
  - Decision Tree
  - Naive Bayes
  - Logistic Regression
  - Random Forest
  - Support Vector Classification (SVC)
  - K-Nearest Neighbors (KNN)
- **Real-time Classification**: Instant tumor classification results
- **Cross-platform Support**: Works on Windows, macOS, Linux, iOS, and Android
- **User-friendly Interface**: Modern and intuitive UI built with Flutter
- **Confidence Scores**: Provides probability scores for predictions
- **Multiple Tumor Types**: Classifies between:
  - Meningioma
  - Glioma
  - Pituitary Tumor

## 🏗️ Project Structure

```
the-magnificent-three/
├── flutter_ml/           # Flutter frontend application
│   ├── lib/             # Dart source code
│   ├── images/          # Application assets
│   └── pubspec.yaml     # Flutter dependencies
├── ML_Model/            # Backend ML server
│   ├── FlaskForClassification.py  # Classification API
│   ├── FlaskForRegression.py      # Regression API
│   └── Models/          # Trained ML models and code of it 
└── images for test/     # Test images
```

## 🛠️ Prerequisites

- Python 3.x
- Flutter SDK
- Flask
- Required Python packages (install via pip):
  - flask
  - joblib
  - numpy
  - Pillow
- Required Flutter packages (automatically installed via pubspec.yaml)

## 🚀 Getting Started


1. **Setup the Flutter Frontend**
   ```bash
   cd flutter_ml
   flutter pub get
   flutter run
   ```

2. **Run the Application**
   - For Windows users, you can use the provided `run it first.bat` script
   - Or run the Flutter app directly using `flutter run`

## 💻 Usage

1. Launch the application
2. Select or drag-and-drop a brain MRI image
3. Choose your preferred ML model
4. Click "Classify" to get the results
5. View the classification results and confidence scores
## 💻 Screenshots
<img src="https://github.com/user-attachments/assets/617dbec3-4fcf-4e8c-8f39-ae086093c090" width="400"/>
<img src="https://github.com/user-attachments/assets/6c2ea437-639f-404a-b184-dbc5bff3bd82" width="400"/>


## ⚠️ Disclaimer

This application is intended for research and educational purposes only. It should not be used as a substitute for professional medical advice, diagnosis, or treatment.

## 📧 Contact

For any questions or suggestions, please open an issue in the GitHub repository.
