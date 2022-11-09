from rest_framework import serializers
from .models import Post, Comment
from accounts.serializers import ProfileSerializer

'''
게시글 기능 구현 2. serializer 작성
- PostSerializer, PostCreateSerializer 역할이 다르기 때문에 구분해서 구현함

다음은 권한 + vue

'''

class CommentSerializer(serializers.ModelSerializer):
    profile = ProfileSerializer(read_only=True)

    class Meta:
        model = Comment
        fields = ("pk", "profile", "post", "text")


class CommentCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Comment
        fields = ("post", "text")
 
class PostSerializer(serializers.ModelSerializer):
    # 이를 작성하지  않으면 profile필드는 pk 값만 가지게 된다.
    profile = ProfileSerializer(read_only=True)
    # comments = CommentSerializer(many=True, read_only=True)

    class Meta:
        model = Post
        fields = ("pk", "profile", "title", "body", "image", "published_date",
                  "likes",)

# 사용자가 입력한 데이터를 검증하고 이를 Django 데이터로 변환하여 저장하게끔하는 역할
class PostCreateSerializer(serializers.ModelSerializer):
    image = serializers.ImageField(use_url=True, required=False)

    class Meta:
        model = Post
        fields = ("title", "category", "body", "image")
