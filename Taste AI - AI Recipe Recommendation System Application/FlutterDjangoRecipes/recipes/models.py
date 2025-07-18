from django.db import models
from django.contrib.auth.models import User

class Recipes(models.Model):
    id = models.BigAutoField(db_column="id", primary_key=True)
    name = models.CharField(max_length=300, blank=True)
    description = models.TextField(blank=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    
class RecipeIngredients(models.Model):
    id = models.BigAutoField(db_column="id", primary_key=True)
    name = models.CharField(max_length=300,blank=True)
    recipe = models.ForeignKey(Recipes, on_delete=models.CASCADE)