from django.shortcuts import render, redirect, get_object_or_404
from .models import Movie, Comment
from .forms import MovieForm, CommentForm
from django.views.decorators.http import (
    require_safe,
    require_POST,
    require_http_methods,
)
# Create your views here.
def index(request):
    if request.user.is_authenticated:
        movies = Movie.objects.all()
        context = {
            'movies':movies,
        }
        return render(request, 'movies/index.html', context)
    return render(request, 'movies/index.html')

def create(request):
    if request.method == 'POST':
        form = MovieForm(request.POST)
        if form.is_valid():
            form.save()
            return redirect('movies:index')
    else:
        form = MovieForm()
    context = {
        'form':form,
    }
    return render(request, 'movies/create.html', context)

def detail(request, movie_pk):
    movie = Movie.objects.get(pk=movie_pk)
    comments = movie.comment_set.all()
    comment_form = CommentForm()
    context = {
        'movie':movie,
        'comment_form':comment_form,
        'comments':comments,
    }
    return render(request, 'movies/detail.html', context)

def update(request, movie_pk):
    movie = get_object_or_404(Movie, pk=movie_pk)
    if request.method == 'POST':
        form = MovieForm(request.POST, instance=movie)
        if form.is_valid():
            form.save()
            return redirect('movies:detail', movie.pk)
    else:
        # Creating a form to change an existing article.
        form = MovieForm(instance=movie)
    context = {
        'movie': movie,
        'form': form,
    }
    return render(request, 'movies/update.html', context)
    
def delete(request, movie_pk):
    movie = get_object_or_404(Movie, pk=movie_pk)
    movie.delete()
    return redirect('movies:index')

def comments_create(request, movie_pk):
    comment_form = CommentForm(request.POST)
    movie = get_object_or_404(Movie, pk=movie_pk)
    
    if comment_form.is_valid():
        
        comment = comment_form.save(commit=False)
        comment.movie = movie
        comment.user = request.user
        comment.save()
    return redirect('movies:detail', movie.pk)


def comments_delete(request, movie_pk, comment_pk):
    movie = get_object_or_404(Movie, pk=movie_pk)
    comment = get_object_or_404(Comment, pk=comment_pk)
    if request.user.pk==comment.user.pk and request.user.is_authenticated:
        comment.delete()
        
        return redirect('movies:detail', movie.pk)
    
def likes(request, movie_pk):
    movie = Movie.objects.get(pk=movie_pk)
    User = request.user
    if User in movie.like_users.all():
        movie.like_users.remove(User)
    else:
        movie.like_users.add(User)
    return redirect('movies:detail', movie.pk)


    
    
    