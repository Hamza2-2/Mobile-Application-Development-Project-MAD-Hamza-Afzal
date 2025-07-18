from django.urls import path
from . import views

app_name = 'recipes'

urlpatterns = [
    # GET: List all recipes | POST: Create new recipe
    path('', views.recipe_list, name='recipe-list'),
    
    # GET: Get single recipe | PUT: Update recipe | DELETE: Delete recipe
    path('<int:pk>/', views.recipe_detail, name='recipe-detail'),
    
    path('recommend/', views.recommend_recipes, name='recipe-recommend'),
    path('recommend_calorie_based/', views.recommend_calorie_based, name='calorie-recommend'),
]