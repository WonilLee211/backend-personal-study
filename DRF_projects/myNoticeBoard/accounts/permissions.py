from rest_framework import permissions

# 커스텀 권한 클래스
# 
class CustomReadOnly(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        # permissions.SAFE_METHODS : 데이터엥 영향을 미치지 않는 메소드
        if request.method in permissions.SAFE_METHODS:
            return True

        return obj.user == request.user