# from django_filters.rest_framework import DjangoFilterBackend
from .models import Post, Comment
from accounts.models import Profile
from .permissions import CustomReadOnly
from rest_framework import mixins, viewsets
from rest_framework import generics, status
from rest_framework.response import Response
from rest_framework.generics import get_object_or_404
from rest_framework.permissions import IsAuthenticated
from rest_framework.decorators import api_view, permission_classes
# 뷰마다 필터 설정할 때 사용(setting.py에 이미 등록해서 상관없음)
from django_filters.rest_framework import DjangoFilterBackend
from .serializers import PostSerializer, PostCreateSerializer, CommentSerializer, CommentCreateSerializer

'''
게시글 기능 구현 4. view 작성
'''

class PostViewSet(viewsets.ModelViewSet):
    queryset = Post.objects.all()
    permission_classes = [CustomReadOnly]
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['author', 'likes'] # 필터링할 필드 설정

    def get_serializer_class(self):
        if self.action == 'list' or 'retrieve':
            return PostSerializer
        return PostCreateSerializer

    def perform_create(self, serializer):
        profile = Profile.objects.get(user=self.request.user)
        serializer.save(author=self.request.user, profile=profile)


class CommentViewSet(viewsets.ModelViewSet):
    queryset = Comment.objects.all()
    permission_classes = [CustomReadOnly]

    def get_serializer_class(self):
        if self.action == 'list' or 'retrieve':
            return CommentSerializer
        return CommentCreateSerializer

    def perform_create(self, serializer):
        profile = Profile.objects.get(user=self.request.user)
        serializer.save(author=self.request.user, profile=profile)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def like_post(request, pk):
    post = get_object_or_404(Post, pk=pk)
    if request.user in post.likes.all():
        post.likes.remove(request.user)
    else:
        post.likes.add(request.user)

    return Response({'status': 'ok'})
