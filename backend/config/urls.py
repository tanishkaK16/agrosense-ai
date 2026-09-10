"""
Root URL configuration for AgroSense AI backend.
Prefix: /api/v1/ matches Flutter client contract.
See docs/api-contract.md for details.
"""
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path("admin/", admin.site.urls),
    # /api/v1/ API endpoints
    path(
        "api/v1/",
        include(
            [
                path("", include("apps.common.urls")),
                path("", include("apps.accounts.urls")),
                path("", include("apps.fields.urls")),
                path("", include("apps.alerts.urls")),
                path("", include("apps.ingest.urls")),
            ]
        ),
    ),
]
