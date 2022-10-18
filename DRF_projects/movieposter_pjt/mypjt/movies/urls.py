from django.urls import path
from . import views

app_name = 'movies'
urlpatterns = [
    path('', views.index, name='index'),
    path('index/', views.index, name='index'),
    path('create/', views.create, name='create'),
    path('detail/<int:movie_pk>', views.detail, name='detail'),
    path('update/<int:movie_pk>', views.update, name='update'),
    path('delete/<int:movie_pk>', views.delete, name='delete'),
    path('<int:movie_pk>/comments/', views.comments_create, name='comments_create'),
    path('<int:movie_pk>/comments/<int:comment_pk>/delete/', views.comments_delete, name='comments_delete'),
    path('likes/<int:movie_pk>', views.likes, name='likes'),
]
