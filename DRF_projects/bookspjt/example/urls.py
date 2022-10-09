from django.urls import path

from example.serializers import BookSerializer
from .views import (
    HelloAPI, bookAPI, booksAPI, BookAPI, BooksAPI,
    BooksAPIMixins, BookAPIMixins,
    BooksAPIGenerics, BookAPIGenerics
    )

urlpatterns = [
    path('hello/', HelloAPI),
    path('fbv/books/', booksAPI),
    path('fbv/book/<int:id>/', bookAPI),
    path('cbv/books/', BooksAPI.as_view()),
    path('cbv/book/<int:id>/', BookAPI.as_view()),
    path('mixin/books/', BooksAPIMixins.as_view()),
    path('mixin/book/<int:id>/', BookAPIMixins.as_view()),
    path('generics/books/', BooksAPIGenerics.as_view()),
    path('generics/book/<int:id>/', BookAPIGenerics.as_view()),
]

from rest_framework import routers
from .views import BookViewSet

router = routers.SimpleRouter()
router.register('books', BookViewSet)
# urlpatterns = router.urls
