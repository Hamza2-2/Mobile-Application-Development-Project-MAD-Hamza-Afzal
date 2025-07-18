from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import status
from django.shortcuts import get_object_or_404
from .models import Recipes, RecipeIngredients
from django.views.decorators.csrf import csrf_protect
from .palatte_based import recipe_recommender
from .calorie_based import app as calorie_model

@api_view(['GET', 'POST'])
@permission_classes([IsAuthenticated])
@csrf_protect
def recipe_list(request):
    """List all recipes or create new recipe"""
    if request.method == 'GET':
        recipes = Recipes.objects.filter(user=request.user)
        data = [{
            'id': recipe.id,
            'name': recipe.name,
            'description': recipe.description,
            'ingredients': [
                {'id': i.id, 'name': i.name}
                for i in recipe.recipeingredients_set.all()
            ]
        } for recipe in recipes]
        return Response(data)
    
    elif request.method == 'POST':
        recipe = Recipes.objects.create(
            user=request.user,
            name=request.data.get('name'),
            description=request.data.get('description')
        )
        
        for ingredient in request.data.get('ingredients', []):
            RecipeIngredients.objects.create(
                recipe=recipe,
                name=ingredient
            )
            
        return Response({
            'id': recipe.id,
            'name': recipe.name,
            'description': recipe.description,
            'ingredients': [
                {'id': i.id, 'name': i.name}
                for i in recipe.recipeingredients_set.all()
            ]
        }, status=201)

@api_view(['GET', 'PUT', 'DELETE'])
@permission_classes([IsAuthenticated])
@csrf_protect
def recipe_detail(request, pk):
    """Get, update or delete specific recipe"""
    recipe = get_object_or_404(Recipes, pk=pk, user=request.user)
    
    if request.method == 'GET':
        return Response({
            'id': recipe.id,
            'name': recipe.name,
            'description': recipe.description,
            'ingredients': [
                {'id': i.id, 'name': i.name}
                for i in recipe.recipeingredients_set.all()
            ]
        })
    
    elif request.method == 'PUT':
        recipe.name = request.data.get('name', recipe.name)
        recipe.description = request.data.get('description', recipe.description)
        recipe.save()
        
        # Update ingredients - delete existing and create new ones
        recipe.recipeingredients_set.all().delete()
        for ingredient in request.data.get('ingredients', []):
            RecipeIngredients.objects.create(
                recipe=recipe,
                name=ingredient
            )
            
        return Response({
            'id': recipe.id,
            'name': recipe.name,
            'description': recipe.description,
            'ingredients': [
                {'id': i.id, 'name': i.name}
                for i in recipe.recipeingredients_set.all()
            ]
        })
    
    elif request.method == 'DELETE':
        recipe.delete()
        return Response(status=204)
    
    
@api_view(['POST'])
@permission_classes([IsAuthenticated])
@csrf_protect
def recommend_recipes(request):
    """Handle recipe recommendations"""
    try:
        
        # Get request data
        data = request.data
        ingredients = data.get('ingredients', [])
        palette = data.get('palette', [])
        
        # Validate input
        if not isinstance(ingredients, list) or not isinstance(palette, list):
            return Response(
                {'error': 'Ingredients and palette must be lists'},
                status=status.HTTP_400_BAD_REQUEST
            )
            
        if not ingredients or not palette:
            return Response(
                {'error': 'Both ingredients and palette are required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Transform arrays into comma-separated strings
        ingredients_str = ', '.join([str(i) for i in ingredients])
        palette_str = ', '.join([str(p) for p in palette])
        
        # Get recommendations
        recommendations = recipe_recommender.recommend_recipes(
            input_ingredients_str=ingredients_str,
            input_palette_str=palette_str,
            top_k=5
        )
        
        # Convert DataFrame to list of dictionaries
        results = recommendations.to_dict('records')
        
        return Response(results)
        
    except Exception as e:
        return Response(
            {'error': f'Recommendation failed: {str(e)}'},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
        
        
@api_view(['POST'])
@permission_classes([IsAuthenticated])
@csrf_protect
def recommend_calorie_based(request):
    """Get calorie-based recipe recommendations"""
    try:
        
        data = request.data
        
        # Extract all required features
        input_features = [
            float(data.get('calories', 0)),
            float(data.get('fat', 0)),
            float(data.get('carbs', 0)),
            float(data.get('protein', 0)),
            float(data.get('cholesterol', 0)),
            float(data.get('sodium', 0)),
            float(data.get('fiber', 0)),
            ','.join(data.get('ingredients', [])),
        ]
        
        recommendations = calorie_model.recommend_recipes(input_features)
        
        # Convert to list of dictionaries
        results = recommendations.to_dict('records')
        return Response(results)
        
    except Exception as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )