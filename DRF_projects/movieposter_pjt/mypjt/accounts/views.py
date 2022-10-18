from django.shortcuts import render, redirect
from django.contrib.auth.forms import (
    AuthenticationForm,
    PasswordChangeForm,
)
from django.contrib.auth import login as auth_login
from django.contrib.auth import logout as auth_logout
from django.contrib.auth import  update_session_auth_hash
from .forms import CustomUserChangeForm, CustomUserCreationForm
from django.views.decorators.http import (
    require_safe,
    require_POST,
    require_http_methods,
)
from django.contrib.auth.decorators import login_required
from .models import User
# Create your views here.

@require_http_methods(["POST", "GET"])
def login(request):
    if request.user.is_authenticated:
        return redirect('movies:index')

    if request.method=="POST":
        form = AuthenticationForm(request, request.POST)
        if form.is_valid():
            auth_login(request, form.get_user())
            next = request.GET.get('next')
            return redirect(next or 'movies:index')
    else:
        form = AuthenticationForm()
    context = {
        'form':form,
        'title':'login',
        'btn_title':'로그인',
    }
    return render(request, 'accounts/form.html', context)

@require_http_methods(["POST", "GET"])
def signup(request):
    if request.method=="POST":
        form = CustomUserCreationForm(request.POST)
        if form.is_valid():
            user = form.save()
            # return redirect('accounts:login')
            # 회원가입 후 로그인
            auth_login(request, user)
            return redirect('movies:index')
    else:
        form = CustomUserCreationForm()
    context = {
        'form':form,
        'title':'SIGNUP',
        'btn_title':'가입',
    }
    return render(request, 'accounts/form.html', context)

# @login_required
@require_POST
def logout(request):
    # if request.method =="POST":
    if request.user.is_authenticated:
        auth_logout(request)
        return redirect('movies:index')

@require_POST
def delete(request):
    # if request.method=="POST":
    if request.user.is_authenticated:
        request.user.delete()
        auth_logout(request)
        return redirect('movies:index')

@login_required
@require_http_methods(["POST", "GET"])
def update(request):
    
    if request.method=="POST":
        form = CustomUserChangeForm(request.POST, instance=request.user)
        if form.is_valid():
            form.save()
            return redirect('movies:index')
    else:
        form = CustomUserChangeForm(instance=request.user)
    context = {
        'form':form,
        'title':'회원정보수정',
        'btn_title':'수정',
    }
    return render(request, 'accounts/form.html', context)

@login_required
@require_http_methods(["POST", "GET"])
def change_password(request):
    if request.method=="POST":
        form = PasswordChangeForm(request.user, request.POST)
        if form.is_valid():
            user = form.save()
            update_session_auth_hash(request, user)
            return redirect('movies:index') 
    else:
        form = PasswordChangeForm(request.user)
    context = {
        'form':form,
        'title':'change_password',
        'btn_title':'변경',
    }
    return render(request, 'accounts/form.html', context)

def profile(request, username):
    person = User.objects.get(username=username)
    context = {
        'person':person,
    }
    return render(request, 'accounts/profile.html', context)