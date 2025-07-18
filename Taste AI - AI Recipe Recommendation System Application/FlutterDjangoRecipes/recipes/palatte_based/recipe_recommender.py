



from scipy.sparse import hstack
import joblib
from scipy import sparse
import pandas as pd
from sklearn.metrics.pairwise import cosine_similarity

from scipy.sparse import hstack

ingredient_vectorizer = joblib.load("D:\\Django Projects\\FlutterDjangoRecipes\\recipes\\palatte_based\\ingredient_vectorizer.joblib")
palette_binarizer = joblib.load("D:\\Django Projects\\FlutterDjangoRecipes\\recipes\\palatte_based\\palette_binarizer.joblib")
X_combined = sparse.load_npz("D:\\Django Projects\\FlutterDjangoRecipes\\recipes\\palatte_based\\X_combined.npz")
knn = joblib.load("D:\\Django Projects\\FlutterDjangoRecipes\\recipes\\palatte_based\\knn_model_palette.joblib")

file_path = 'D:\\Django Projects\\FlutterDjangoRecipes\\recipes\\palatte_based\\foodrecsys_v1_with_palette.csv'
df = pd.read_csv(file_path)


from sklearn.metrics.pairwise import cosine_similarity
from scipy.sparse import hstack
import numpy as np

# Global variable to track shown indices
shown_indices = set()

def recommend_recipes(input_ingredients_str, input_palette_str, top_k=3, show_more=False):
    global shown_indices

    # Prepare input ingredients
    input_ingredients = ', '.join(sorted([i.strip().lower() for i in input_ingredients_str.split(',')]))
    ingredient_vec = ingredient_vectorizer.transform([input_ingredients])

    # Prepare palette
    input_palette = [p.strip().lower() for p in input_palette_str.split(',') if p.strip()]
    palette_vec = palette_binarizer.transform([input_palette])

    # Combine sparse features
    input_vec = hstack([ingredient_vec, palette_vec])

    # Compute cosine similarity
    similarities = cosine_similarity(input_vec, X_combined).flatten()
    sorted_indices = similarities.argsort()[::-1]

    # Filter out already shown recipes
    new_indices = [i for i in sorted_indices if i not in shown_indices]

    # Take top_k new results
    top_indices = new_indices[:top_k]
    shown_indices.update(top_indices)  # Mark these as shown

    # Compute match score
    input_set = set(i.strip().lower() for i in input_ingredients_str.split(','))
    df['match_score'] = df['ingredients_list'].apply(
        lambda ing: len(input_set & set(i.strip().lower() for i in ing.split(',')))
    )

    # Return sorted recommendations
    results = df.iloc[top_indices].copy()
    results = results.sort_values(by='match_score', ascending=False)
    return results[['recipe_name', 'ingredients_list', 'palette']]
