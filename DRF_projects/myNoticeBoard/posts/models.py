from django.db import models
from django.contrib.auth.models import User
from django.utils import timezone
from accounts.models import Profile
<<<<<<< HEAD
=======
'''
게시글 기능 구현 1. 모델 만들기
저자, 저자프로필, 제목, 카테고리, 본문, 이미지, 좋아요 누른 사람들, 글이 올라간 시간
>>>>>>> cd87ce6554b837886f616edcec499686b1826a9a

다음은 serializer
'''

# Create your models here.
class Post(models.Model):
    # 저자, 저자프로필, 제목, 카테고리, 본문, 이미지, 좋아요 누른 사람들, 글이 올라간 시간
    author = models.ForeignKey(User,
                               on_delete=models.CASCADE,
                               related_name='posts')
    profile = models.ForeignKey(Profile,
                                on_delete=models.CASCADE,
                                blank=True,
                                related_name='author_profile')
    title = models.CharField(max_length=128)
    category = models.CharField(max_length=128)
    body = models.TextField()
    image = models.ImageField(upload_to='post/', default='default.png')
    likes = models.ManyToManyField(User, related_name='like_posts', blank=True)
    published_date = models.DateTimeField(default=timezone.now)

    # def like_count():
    #     return self.likes.count()


class Comment(models.Model):
    author = models.ForeignKey(User, on_delete=models.CASCADE)
    profile = models.ForeignKey(Profile, on_delete=models.CASCADE)
    post = models.ForeignKey(Post,
                             related_name='comments',
                             on_delete=models.CASCADE)
    text = models.TextField()
