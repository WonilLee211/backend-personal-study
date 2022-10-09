from django.shortcuts import render, redirect
from .models import Todo
from .forms import TodoForm
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