from rest_framework import serializers
from .models import Post, Comment
from accounts.serializers import ProfileSerializer


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
    # 아래 필드를 override하지않으면 pk값만 얻게 됨
    profile = ProfileSerializer(read_only=True)
    # nested serializer
    comments = CommentSerializer(many=True, read_only=True)

    class Meta:
        model = Post
        fields = ("pk", "profile", "title", "body", "image", "published_date",
                  "likes", "comments")

# 직렬화 역직렬화할 때 주고받는 정보, 즉 필드가 다르기 때문에 
# 클래스를 나눈다
class PostCreateSerializer(serializers.ModelSerializer):
    image = serializers.ImageField(use_url=True, required=False)

    class Meta:
        model = Post
        fields = ("title", "category", "body", "image")
