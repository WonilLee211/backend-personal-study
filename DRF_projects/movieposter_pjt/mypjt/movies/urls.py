from django.urls import path
from . import views

app_name = 'movies'
urlpatterns = [
    path('index/', views.index, name='index'),
    path('create/', views.create, name='create'),
    path('detail/<int:movie_pk>', views.detail, name='detail'),
    path('update/<int:movie_pk>', views.update, name='update'),
    path('delete/<int:movie_pk>', views.delete, name='delete'),
]
