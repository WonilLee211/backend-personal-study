from rest_framework import permissions

'''
3. permission 작성
게시글의 요청마다 권한이 다르기 때문에 post app내에 permission.py 작성이 필요함
게시글에 필요한 권한은
- 게시글 조회 : AllowAny
- 게시글 작성 : isAuthenticated
- 게시글 수정/삭제 : Author

'''

class CustomReadOnly(permissions.BasePermission):
    ## 글 조회: 누구나, 생성: 로그인한 유저, 편집: 글 작성자
    def has_permission(self, request, view):                # 각 객체별 권한 뿐만 아니라 전체 객체에 대한 권한(목록 조회/생성)도 포함해야 하기 때문에 작성함
        if request.method == 'GET':                         # get 요청은 항상 허용
            return True
        return request.user.is_authenticated                # 그외 요청은 인증된 사용자인지 검증 결과 반환

    def has_object_permission(self, request, view, obj):    # 게시글에 대한 권한 검증
        if request.method in permissions.SAFE_METHODS:
            return True
        return obj.author == request.user