"""
Alerts stub views for Phase 0.
Full Alert aggregation, severity sorting, and acknowledgment will be implemented in future phases.
See docs/api-contract.md for the complete specification.
"""
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status


class AlertsListView(APIView):
    """
    GET /api/v1/alerts
    Reference: docs/api-contract.md#6-alerts
    """
    def get(self, request):
        return Response(
            {"detail": "Not implemented"},
            status=status.HTTP_501_NOT_IMPLEMENTED,
        )


class AlertDetailView(APIView):
    """
    GET /api/v1/alerts/{id}
    Reference: docs/api-contract.md#6-alerts
    """
    def get(self, request, alert_id):
        return Response(
            {"detail": "Not implemented"},
            status=status.HTTP_501_NOT_IMPLEMENTED,
        )


class AlertSeenView(APIView):
    """
    POST /api/v1/alerts/{id}/seen
    Reference: docs/api-contract.md#6-alerts
    """
    def post(self, request, alert_id):
        return Response(
            {"detail": "Not implemented"},
            status=status.HTTP_501_NOT_IMPLEMENTED,
        )
