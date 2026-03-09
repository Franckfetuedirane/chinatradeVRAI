import time

from django.conf import settings
from django.contrib.auth import logout


class SessionIdleTimeoutMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response
        self.timeout = max(60, int(getattr(settings, "SESSION_IDLE_TIMEOUT", 900)))

    def __call__(self, request):
        user = getattr(request, "user", None)
        if user is not None and user.is_authenticated:
            now = int(time.time())
            last_activity = request.session.get("last_activity")
            if last_activity and now - int(last_activity) > self.timeout:
                logout(request)
                request.session.flush()
            else:
                request.session["last_activity"] = now

        response = self.get_response(request)
        return response
