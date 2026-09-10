"""
Alerts URL configuration.
Reference: docs/api-contract.md
"""
from django.urls import path
from .views import AlertsListView, AlertDetailView, AlertSeenView

urlpatterns = [
    # GET /api/v1/alerts
    path("alerts", AlertsListView.as_view(), name="alerts_list"),
    # GET /api/v1/alerts/{id}
    path("alerts/<str:alert_id>", AlertDetailView.as_view(), name="alert_detail"),
    # POST /api/v1/alerts/{id}/seen
    path("alerts/<str:alert_id>/seen", AlertSeenView.as_view(), name="alert_seen"),
]
