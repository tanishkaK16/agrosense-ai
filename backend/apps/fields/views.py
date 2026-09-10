"""
Fields and Home dashboard stub views for Phase 0.
Full Field CRUD, satellite telemetry, and home snapshots will be implemented in future phases.
See docs/api-contract.md for the complete specification.
"""
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status


class FieldsListView(APIView):
    """
    GET  /api/v1/fields
    POST /api/v1/fields
    Reference: docs/api-contract.md#4-fields--telemetry
    """
    def get(self, request):
        return Response(
            {"detail": "Not implemented"},
            status=status.HTTP_501_NOT_IMPLEMENTED,
        )

    def post(self, request):
        return Response(
            {"detail": "Not implemented"},
            status=status.HTTP_501_NOT_IMPLEMENTED,
        )


class FieldDetailView(APIView):
    """
    GET /api/v1/fields/{id}
    Reference: docs/api-contract.md#4-fields--telemetry
    """
    def get(self, request, field_id):
        return Response(
            {"detail": "Not implemented"},
            status=status.HTTP_501_NOT_IMPLEMENTED,
        )


class FieldStatusView(APIView):
    """
    GET /api/v1/fields/{id}/status
    Reference: docs/api-contract.md#4-fields--telemetry
    """
    def get(self, request, field_id):
        return Response(
            {"detail": "Not implemented"},
            status=status.HTTP_501_NOT_IMPLEMENTED,
        )


class HomeSnapshotView(APIView):
    """
    GET /api/v1/home
    Reference: docs/api-contract.md#5-home-dashboard
    """
    def get(self, request):
        return Response(
            {"detail": "Not implemented"},
            status=status.HTTP_501_NOT_IMPLEMENTED,
        )
