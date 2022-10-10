from cgitb import reset
from difflib import restore
from django.shortcuts import render, redirect
from .models import Todo
from .forms import TodoForm
from rest_framework import status
from rest_framework import viewsets
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.generics import get_object_or_404
from .serializers import TodoCreateSerializer, TodoSimpleSerializer, TodoDetailSerializer, TodoCreateSerializer

class TodosAPIView(APIView):
    def get(self, request):
        todos = Todo.objects.filter(complete=False)
        serializer = TodoSimpleSerializer(todos, many=todos)
        return Response(serializer.data, status=status.HTTP_200_OK)

    # post 방식으로 통신
    # TodosAPIView 클래스 내에 post메소드에서 전달받은 데이터를 
    def post(self, request):
        # TodoCreateSerializer에 통과시켜 파이썬 모델 객체 생성
        serializer = TodoCreateSerializer(data=request.data)
        if serializer.is_valid(): # 모델에 정의된 필드에 적합한지 확인 후 저장
            serializer.save()  
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        # 유효성 검사 실패 시 에러 반환
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# 논리
# - TodoAPIView라는 클래스를 만들고 
class TodoAPIView(APIView):
    def get(self, request, pk):
        # get메소드에서 todo 객체를 생성하고 
        todo = get_object_or_404(Todo, id = pk)
        # TodoDetailSerializer를 통과시켜 
        serializer = TodoDetailSerializer(todo)
        # Response로 반환
        return Response(serializer.data, status=status.HTTP_200_OK)

    def put(self, request, pk):
        todo = get_object_or_404(Todo, id = pk)
        serializer = TodoCreateSerializer(todo, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class DoneTodosAPIView(APIView):
    def get(self, request):
        dones = Todo.objects.filter(complete=True)
        serializer = TodoSimpleSerializer(dones, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
    
class DoneTodoAPIView(APIView):
    def put(self, request, pk):
        done = get_object_or_404(Todo, id=pk)
        done.complete = True
        done.save()
        serializer = TodoDetailSerializer(done)
        return Response(status=status.HTTP_200_OK)
        


'''

# Create your views here.
def todo_list(request):
    todos = Todo.objects.filter(is_complete=False)
    context = {'todos':todos}
    return render(request, 'todos/todo_list.html', context)

def todo_detail(request, pk):
    todo = Todo.objects.get(pk = pk)
    context = { "todo":todo }
    return render(request, 'todos/todo_detail.html', context)

def todo_post(request):
    if request.method == "POST":
        form = TodoForm(request.POST)
        if form.is_valid():
            form.save()
            return redirect('todos:todo_list')
    else:
        form = TodoForm()
    context = {'form':form}
    return render(request, 'todos/todo_post.html', context)

def todo_edit(request, pk):
    todo = Todo.objects.get(pk = pk)
    if request.method == "POST":
        form = TodoForm(request.POST, instance=todo)
        if form.is_valid():
            todo = form.save()
            return redirect('todos:todo_detail', todo.pk)
    else:
        form = TodoForm(instance=todo)
    context = {
        'form':form,
        'todo':todo,
    }
    return render(request, 'todos/todo_edit.html', context)

def done_list(request):
    dones = Todo.objects.filter(is_complete=True)
    context = { 'dones':dones, }
    return render(request, 'todos/done_list.html', context)

def todo_done(request, pk):
    if request.method == "POST":
        todo = Todo.objects.get(pk=pk)
        todo.is_complete = True
        todo.save()
    return redirect('todos:todo_list')



'''