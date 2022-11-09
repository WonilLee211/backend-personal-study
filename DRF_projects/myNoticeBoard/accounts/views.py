from django.shortcuts import render

# Create your views here.
# 회원가입의 경우 POST, 즉 회원 생성 기능만 있기 때문에 굳이 Viewset을 사용해 API 요청을 처리할 필요 없음
# generics의 CreateAPIView를 사용해 작성
from django.contrib.auth.models import User
from rest_framework import generics, status
from rest_framework.response import Response
from .serializers import RegisterSerializer, LoginSerializer, ProfileSerializer

'''
회원가입의 경우 POST, 회원 생성기능만 있기 때문에 굳이 viewset을 이용하여 다른 API요청을 처리할 필요가 없음
generics의 CreateAPIView를 사용하여 작성
'''
class RegisterView(generics.CreateAPIView): # CreateAPIView(generics) 사용 구현
    queryset = User.objects.all()
    serializer_class = RegisterSerializer

# login은 모델에 영향을 주지 않기 때문에 GenericAPIView로 구현하기
# 1차 보안 - POST 요청. 
class LoginView(generics.GenericAPIView):
    serializer_class = LoginSerializer
    def post(self, request):
        # 시리얼라이저를 통과하여 얻어온 토큰을 그대로 응답해주는 방식
        # 시리얼라이저에서 검증 과정을 모두 처리해 줌
        serializer = self.get_serializer(data=request.data)             # LoginView 객체의 get_serializer메서드를 통해 사용자 입력 정보 전달
        serializer.is_valid(raise_exception=True)                       # 사용자 입력 정보 유효성 검사
        token = serializer.validated_data                               # validate 리턴값인 token을 받아옴
        return Response({"token":token.key}, status=status.HTTP_200_OK) # 토큰 전달



from .models import Profile
# 프로필 관련 기능 : 가져오기와 수정하기 기능
class ProfileView(generics.RetrieveUpdateAPIView):      # 프로필을 조회하는 것은 누구나 가능
    queryset = Profile.objects.all()
    serializer_class = ProfileSerializer

