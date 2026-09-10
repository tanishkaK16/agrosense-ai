"""
Accounts and authentication stub views for Phase 0.
Full OTP verification, session tokens, and profile CRUD will be implemented in Phase 1.
See docs/api-contract.md for the complete specification.
"""
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status


class OtpRequestView(APIView):
    """
    POST /api/v1/auth/otp/request
    Reference: docs/api-contract.md#2-authentication
    """
    authentication_classes = []
    permission_classes = []

    def post(self, request):
        return Response(
            {"detail": "Not implemented"},
            status=status.HTTP_501_NOT_IMPLEMENTED,
        )


class OtpVerifyView(APIView):
    """
    POST /api/v1/auth/otp/verify
    Reference: docs/api-contract.md#2-authentication
    """
    authentication_classes = []
    permission_classes = []

    def post(self, request):
        return Response(
            {"detail": "Not implemented"},
            status=status.HTTP_501_NOT_IMPLEMENTED,
        )


class FarmerProfileView(APIView):
    """
    GET /api/v1/me
    PUT /api/v1/me
    Reference: docs/api-contract.md#3-farmer-profile
    """
    def get(self, request):
        return Response(
            {"detail": "Not implemented"},
            status=status.HTTP_501_NOT_IMPLEMENTED,
        )

    def put(self, request):
        return Response(
            {"detail": "Not implemented"},
            status=status.HTTP_501_NOT_IMPLEMENTED,
        )
