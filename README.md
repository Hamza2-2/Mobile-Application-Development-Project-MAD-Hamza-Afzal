# 🍽️ Taste AI - Smart Food Recommendation Flutter Application

Taste AI is an intelligent food recommendation system built with **Flutter** for the frontend and **Django (Python)** for the backend. It leverages AI and ML models to suggest recipes based on user preferences, ingredients, dietary requirements, and taste profiles.

## 📂 Project Structure
Taste AI - AI Recipe Recommendation System Application/
│

├── FlutterDjangoRecipes/ # Backend (Django)

│ ├── manage.py

│ ├── FlutterDjangoRecipes/ # Django project settings

│ ├── recommendation/ # Main AI logic and API views

│ ├── recipe_model.joblib # Trained ML model

│ └── requirements.txt

│

└── flutter_django_recipes_frontend/ # Frontend (Flutter)
├── lib/

├── pubspec.yaml

└── android/ios/...

 ## 🧠 Features

- 🍴 Personalized recipe recommendations
- 📊 AI/ML-based taste prediction using trained `.joblib` model
- 🧾 REST API backend with Django
- 📱 Cross-platform mobile app using Flutter
- 🔄 Real-time data communication with backend server
- 🧑‍🍳 Ingredient and dietary-based filtering

## 🚀 Getting Started

### 1. Clone the repository

``` 
git clone https://github.com/Hamza2-2/Taste-AI-Smart-Food-Recommendation-Flutter-Application.git
cd Taste-AI-Smart-Food-Recommendation-Flutter-Application
```

### 2. Backend Setup (Django)
```
cd FlutterDjangoRecipes
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
```
Ensure joblib is enabled via Git LFS for large model file tracking.

### 3. Frontend Setup (Flutter)
```
cd flutter_django_recipes_frontend
flutter pub get
flutter run
```
## 🛠️ Tech Stack

| Layer      | Tech                       |
| ---------- | -------------------------- |
| Frontend   | Flutter (Dart)             |
| Backend    | Django (Python)            |
| ML Model   | Scikit-learn (Joblib)      |
| API Comm   | REST API (Django Views)    |
| Deployment | Localhost / Future: Heroku |

## 📂 Backend API Endpoints
- POST /recommend/ — Sends input features and receives food suggestions

- GET /health/ — Returns server status

- Model is loaded via Joblib and served in-memory

## 📸 Screenshots

<img width="262" height="582" alt="image" src="https://github.com/user-attachments/assets/819bec8e-2d3f-4b99-b9f9-e780dd90a88a" />

<img width="260" height="572" alt="image" src="https://github.com/user-attachments/assets/93362baf-0f28-4c64-8c38-3c7cf20e8fe3" />

<img width="253" height="583" alt="image" src="https://github.com/user-attachments/assets/b51e0720-c0c3-44dd-b42d-015a4bf73ddb" />

<img width="262" height="572" alt="image" src="https://github.com/user-attachments/assets/a51140fa-40c0-4b89-8fdb-999bd216044f" />

<img width="260" height="572" alt="image" src="https://github.com/user-attachments/assets/e0417681-de9a-410f-8c18-0e579af4dd58" />

<img width="262" height="577" alt="image" src="https://github.com/user-attachments/assets/e554b96b-7851-4592-9e7b-d444d2f28543" />

<img width="332" height="757" alt="image" src="https://github.com/user-attachments/assets/fcbd22c7-5b78-400e-87cd-a35074f153ad" />

<img width="253" height="567" alt="image" src="https://github.com/user-attachments/assets/d06027ff-a100-46fe-82e2-0ac45d1583fe" />

<img width="253" height="563" alt="image" src="https://github.com/user-attachments/assets/4709078f-0a18-493c-8369-8949b209b0cf" />

<img width="257" height="552" alt="image" src="https://github.com/user-attachments/assets/f3788236-4aa8-4ae6-bf7b-dda972e2fc2d" />

<img width="256" height="582" alt="image" src="https://github.com/user-attachments/assets/3fa52471-6501-43ed-a7c2-7a15170ae295" />

<img width="257" height="567" alt="image" src="https://github.com/user-attachments/assets/b96c4d46-9c71-43ab-859f-542d0bcceca4" />



## 👨‍💻 Author
Developed by Hamza Afzal
📍 BSCS Student, Bahria University
🔗 GitHub: Hamza2-2

