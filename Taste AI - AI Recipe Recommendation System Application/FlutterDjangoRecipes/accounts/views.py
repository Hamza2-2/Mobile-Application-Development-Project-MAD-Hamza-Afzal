from django.contrib.auth import get_user_model, authenticate, login, logout
from django.http import JsonResponse
from django.middleware.csrf import get_token
from rest_framework.decorators import api_view,permission_classes
from rest_framework.response import Response
from django.views.decorators.csrf import ensure_csrf_cookie, csrf_protect
import random
from .models import OTP
from django.core.mail import send_mail
from django.conf import settings
from django.utils import timezone
from rest_framework.permissions import AllowAny

User = get_user_model()

@api_view(['GET'])
@ensure_csrf_cookie
@permission_classes([AllowAny])
def getCsrfToken(request):
    """Endpoint to get CSRF token for frontend"""
    return JsonResponse({'csrfToken': get_token(request)})

@api_view(['POST'])
@csrf_protect
@permission_classes([AllowAny])
def loginPage(request):
    """Handle user login with email and password"""
    logout(request)
    username = request.data.get('email')
    password = request.data.get('password')

    user = authenticate(request, username=username, password=password)

    if user is not None:
        login(request, user)
        print(user.email)
        return Response({
            "success": True,
            "message": "Login successful",
            "user": {
                "id": user.id,
                "email": user.username,
                "first_name": user.first_name,
                "last_name": user.last_name
            }
        })
    return Response({"success": False, "message": "Invalid credentials"})

@api_view(['POST'])
@csrf_protect
@permission_classes([AllowAny])
def registerPage(request):
    """Handle new user registration"""
    logout(request)
    username = request.data.get('email')
    password = request.data.get('password')
    first_name = request.data.get('first_name')
    last_name = request.data.get('last_name')

    if User.objects.filter(username=username).exists():
        return Response({'success': False, 'message': 'Email already exists'})

    user = User.objects.create_user(
        username=username,
        password=password,
        first_name=first_name,
        last_name=last_name
    )
    login(request, user)
    return Response({
        'success': True,
        'message': 'Registration successful',
        'user': {
            'id': user.id,
            'email': user.username,
            'first_name': user.first_name,
            'last_name': user.last_name
        }
    })

@api_view(['POST'])
@csrf_protect
@permission_classes([AllowAny])
def resetPassword(request):
    """Initiate password reset process"""
    email = request.data.get('email')
    if not User.objects.filter(email=email).exists():
        return Response({'success': False})

    otp = str(random.randint(10000, 99999))
    OTP.objects.update_or_create(
        email=email, 
        defaults={'otp': otp, 'created_at': timezone.now()}
    )
    send_mail(
        "Password Reset OTP",
        f"Your OTP is {otp}. It will expire in 60 seconds.",
        settings.EMAIL_HOST_USER,
        [email]
    )
    return Response({'success': True})

@api_view(['POST'])
@csrf_protect
@permission_classes([AllowAny])
def verifyOTP(request):
    """Verify OTP for password reset"""
    email = request.data.get('email')
    otp_entered = request.data.get('otp')
    
    try:
        otp_record = OTP.objects.get(email=email)
        if otp_record.is_expired():
            return Response({'success': False, 'message': 'OTP expired'}, status=400)
        
        if otp_record.otp == otp_entered:
            return Response({'success': True, 'message': 'OTP verified'})
        return Response({'success': False, 'message': 'Invalid OTP'}, status=400)
    except OTP.DoesNotExist:
        return Response({'success': False, 'message': 'OTP not found'}, status=400)

@api_view(['POST'])
@csrf_protect
@permission_classes([AllowAny])
def updatePassword(request):
    """Update user password after OTP verification"""
    email = request.data.get('email')
    new_password = request.data.get('new_password')
    
    try:
        user = User.objects.get(username=email)
        user.set_password(new_password)
        user.save()
        return Response({'success': True, 'message': 'Password updated'})
    except User.DoesNotExist:
        return Response({'success': False, 'message': 'User not found'}, status=400)