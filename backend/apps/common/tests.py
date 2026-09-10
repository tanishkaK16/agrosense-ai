from django.test import TestCase
from rest_framework import status
from rest_framework.test import APIClient


class HealthCheckTests(TestCase):
    def setUp(self):
        self.client = APIClient()

    def test_health_check_endpoint(self):
        """GET /api/v1/health/ returns 200 with service and ok status."""
        response = self.client.get("/api/v1/health/")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(
            response.json(),
            {
                "status": "ok",
                "service": "agrosense-api",
            },
        )


class ContractStubRoutesTests(TestCase):
    """
    Verifies that all routes specified in docs/api-contract.md are routed
    and return HTTP 501 Not Implemented in Phase 0.
    """
    def setUp(self):
        self.client = APIClient()

    def test_auth_routes_exist_and_return_501(self):
        res_req = self.client.post("/api/v1/auth/otp/request", {"phone": "+919876543210"}, format="json")
        self.assertEqual(res_req.status_code, status.HTTP_501_NOT_IMPLEMENTED)
        self.assertEqual(res_req.json(), {"detail": "Not implemented"})

        res_ver = self.client.post("/api/v1/auth/otp/verify", {"phone": "+919876543210", "code": "1234"}, format="json")
        self.assertEqual(res_ver.status_code, status.HTTP_501_NOT_IMPLEMENTED)
        self.assertEqual(res_ver.json(), {"detail": "Not implemented"})

    def test_profile_routes_exist_and_return_501(self):
        res_get = self.client.get("/api/v1/me")
        self.assertEqual(res_get.status_code, status.HTTP_501_NOT_IMPLEMENTED)

        res_put = self.client.put("/api/v1/me", {"name": "Ramesh"}, format="json")
        self.assertEqual(res_put.status_code, status.HTTP_501_NOT_IMPLEMENTED)

    def test_fields_and_home_routes_exist_and_return_501(self):
        res_list = self.client.get("/api/v1/fields")
        self.assertEqual(res_list.status_code, status.HTTP_501_NOT_IMPLEMENTED)

        res_post = self.client.post("/api/v1/fields", {"name": "Field 1"}, format="json")
        self.assertEqual(res_post.status_code, status.HTTP_501_NOT_IMPLEMENTED)

        res_detail = self.client.get("/api/v1/fields/field_001")
        self.assertEqual(res_detail.status_code, status.HTTP_501_NOT_IMPLEMENTED)

        res_status = self.client.get("/api/v1/fields/field_001/status")
        self.assertEqual(res_status.status_code, status.HTTP_501_NOT_IMPLEMENTED)

        res_home = self.client.get("/api/v1/home")
        self.assertEqual(res_home.status_code, status.HTTP_501_NOT_IMPLEMENTED)

    def test_alerts_routes_exist_and_return_501(self):
        res_list = self.client.get("/api/v1/alerts")
        self.assertEqual(res_list.status_code, status.HTTP_501_NOT_IMPLEMENTED)

        res_detail = self.client.get("/api/v1/alerts/alert_001")
        self.assertEqual(res_detail.status_code, status.HTTP_501_NOT_IMPLEMENTED)

        res_seen = self.client.post("/api/v1/alerts/alert_001/seen")
        self.assertEqual(res_seen.status_code, status.HTTP_501_NOT_IMPLEMENTED)
