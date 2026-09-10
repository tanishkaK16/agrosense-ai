"""
Accounts URL configuration.
Reference: docs/api-contract.md
"""
from django.urls import path
from .views import OtpRequestView, OtpVerifyView, FarmerProfileView

urlpatterns = [
    # POST /api/v1/auth/otp/request
    path("auth/otp/request", OtpRequestView.as_view(), name="otp_request"),
    # POST /api/v1/auth/otp/verify
    path("auth/otp/verify", OtpVerifyView.as_view(), name="otp_verify"),
    # GET / PUT /api/v1/me
    path("me", FarmerProfileView.as_view(), name="farmer_profile"),
]
