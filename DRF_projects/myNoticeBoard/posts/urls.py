from django.urls import path
from rest_framework import routers
from .views import PostViewSet, CommentViewSet, like_post
'''
게시글 기능 5. url작성
게시글에서 뷰셋을 사용했기 때문에 라우터도 함께 따라옴

'''
router = routers.SimpleRouter()
router.register('posts', PostViewSet)
router.register('comments', CommentViewSet)

urlpatterns = router.urls + [
    path('like/<int:pk>/', like_post, name='like_post')
]
