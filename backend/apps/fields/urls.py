"""
Fields and Home URL configuration.
Reference: docs/api-contract.md
"""
from django.urls import path
from .views import FieldsListView, FieldDetailView, FieldStatusView, HomeSnapshotView

urlpatterns = [
    # GET / POST /api/v1/fields
    path("fields", FieldsListView.as_view(), name="fields_list"),
    # GET /api/v1/fields/{id}
    path("fields/<str:field_id>", FieldDetailView.as_view(), name="field_detail"),
    # GET /api/v1/fields/{id}/status
    path("fields/<str:field_id>/status", FieldStatusView.as_view(), name="field_status"),
    # GET /api/v1/home
    path("home", HomeSnapshotView.as_view(), name="home_snapshot"),
]
