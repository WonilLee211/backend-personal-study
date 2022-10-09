from urllib import response
from rest_framework import viewsets, permissions, generics, status
# Response : DRF 결과 반환 방식
# response.data(응답에 포함된 정보), response.status(응답에 대한 상태)
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.decorators import api_view
from rest_framework.generics import get_object_or_404
from .models import Book
from .serializers import BookSerializer

# GET 요청을 받을 수 있는 함수임을 명시
@api_view(['GET'])
def HelloAPI(request):
    return Response("hello world!")

# FBV
@api_view(['GET', 'POST'])
def booksAPI(request):
    # 도서 전체 정보 요청
    if request.method == "GET":
        books = Book.objects.all()
        # 시리얼라이저에 전체 데이터를 한꺼번에 집어넣기
        # (직렬화, many=True)
        serializer = BookSerializer(books, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
    # 도서 정보 저장
    elif request.method == "POST":
        # 역직렬화
        # 포스트 요청으로 들어온 정보를 시리얼라이저로 넣기
        serializer = BookSerializer(data=request.data)
        # 모델에 맞는 유효한 데이터인지 검증
        if serializer.is_valid():
            # 시리얼라이저 역직렬화를 통해 save()
            # 모델 시리얼라이저의 기본 create() 함수가 동작
            serializer.save()
            # 201 메세지 보내면서 성공
            return Response(serializer.data, status=status.HTTP_201_CREATED)
    # 잘못된 요청
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET'])
def bookAPI(request, id):
    print('here-----------------')
    book = get_object_or_404(Book, id=id)
    # 시리얼라이저에 데이터 집어넣기(직렬화)
    serializer = BookSerializer(book)
    return Response(serializer.data, status=status.HTTP_200_OK)

# CBV
# GET인지 POST인지 조건문이 필요없음
class BooksAPI(APIView):
    def get(self, request):
        books = Book.objects.all()
        serializer = BookSerializer(books, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
    
    def post(self, request):
        serializer = BookSerializer(data=request.data)
    
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class BookAPI(APIView):
    def get(self, request, id):
        book = get_object_or_404(Book, id=id)
        serializer = BookSerializer(book)
        return Response(serializer.data, status=status.HTTP_200_OK)
