from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status


class HealthCheckView(APIView):
    """
    Health check endpoint for container probes and service monitoring.
    GET /api/v1/health/
    """
    authentication_classes = []
    permission_classes = []

    def get(self, request):
        return Response(
            {
                "status": "ok",
                "service": "agrosense-api",
            },
            status=status.HTTP_200_OK,
        )
