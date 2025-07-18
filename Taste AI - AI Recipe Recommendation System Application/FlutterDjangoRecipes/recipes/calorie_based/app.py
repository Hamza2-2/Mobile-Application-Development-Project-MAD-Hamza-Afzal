import numpy as np
import pandas as pd
import joblib

# Load assets
data = pd.read_csv("D:/Django Projects/FlutterDjangoRecipes/recipes/calorie_based/recipe_final.csv")
vectorizer = joblib.load("D:/Django Projects/FlutterDjangoRecipes/recipes/calorie_based/vectorizer.joblib")
scaler = joblib.load("D:/Django Projects/FlutterDjangoRecipes/recipes/calorie_based/scaler.joblib")
knn = joblib.load("D:/Django Projects/FlutterDjangoRecipes/recipes/calorie_based/knn_model.joblib")

# Recommend function
def recommend_recipes(input_features):
    input_features_scaled = scaler.transform([input_features[:7]])
    input_ingredients_transformed = vectorizer.transform([input_features[7]])
    input_combined = np.hstack([input_features_scaled, input_ingredients_transformed.toarray()])
    distances, indices = knn.kneighbors(input_combined)
    recommendations = data.iloc[indices[0]]
    return recommendations[['recipe_name', 'ingredients_list']].head(5)

