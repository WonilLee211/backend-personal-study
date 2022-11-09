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
<<<<<<< HEAD
    # 아래 필드를 override하지않으면 pk값만 얻게 됨
    profile = ProfileSerializer(read_only=True)
    # nested serializer
    comments = CommentSerializer(many=True, read_only=True)
=======
    # 이를 작성하지  않으면 profile필드는 pk 값만 가지게 된다.
    profile = ProfileSerializer(read_only=True)
    # comments = CommentSerializer(many=True, read_only=True)
>>>>>>> cd87ce6554b837886f616edcec499686b1826a9a

    class Meta:
        model = Post
        fields = ("pk", "profile", "title", "body", "image", "published_date",
<<<<<<< HEAD
                  "likes", "comments")

# 직렬화 역직렬화할 때 주고받는 정보, 즉 필드가 다르기 때문에 
# 클래스를 나눈다
=======
                  "likes",)

# 사용자가 입력한 데이터를 검증하고 이를 Django 데이터로 변환하여 저장하게끔하는 역할
>>>>>>> cd87ce6554b837886f616edcec499686b1826a9a
class PostCreateSerializer(serializers.ModelSerializer):
    image = serializers.ImageField(use_url=True, required=False)

    class Meta:
        model = Post
        fields = ("title", "category", "body", "image")
