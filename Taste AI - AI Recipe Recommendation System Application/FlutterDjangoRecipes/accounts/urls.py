from django.urls import path
from . import views
app_name = 'accounts'


urlpatterns = [
    path('', views.loginPage, name='login-page'),
    path('gettingcsrftoken/', views.getCsrfToken, name='get-csrf-token'),
    path('register/', views.registerPage, name='register-page'),
    path('resetPassword/', views.resetPassword, name='reset-password'),
    path('verifyOTP/', views.verifyOTP, name='verify-otp'),
    path('updatePassword/', views.updatePassword, name='update-password'),
]