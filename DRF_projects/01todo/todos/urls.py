from django.urls import path
from . import views
from .views import TodosAPIView, TodoAPIView, DoneTodosAPIView, DoneTodoAPIView
app_name = 'todos'
urlpatterns = [
    path('', TodosAPIView.as_view()),
    path('<int:pk>/', TodoAPIView.as_view()),
    path('done/', DoneTodosAPIView.as_view()),
    path('done/<int:pk>/', DoneTodoAPIView.as_view()),


    # path('', views.todo_list, name='todo_list'),
    # path('todo_detail/<int:pk>/', views.todo_detail, name='todo_detail'),
    # path('post/', views.todo_post, name='todo_post'),
    # path('edit/<int:pk>', views.todo_edit, name='todo_edit'),
    # path('done', views.done_list, name='done_list'),
    # path('done/<int:pk>', views.todo_done, name='todo_done'),
]