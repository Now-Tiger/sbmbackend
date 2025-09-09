from typing import ClassVar
from django.db.models import QuerySet
import psycopg2
from django.conf import settings
from rest_framework import status
from rest_framework import generics
from rest_framework.request import Request
from rest_framework.response import Response
from rest_framework.serializers import BaseSerializer
from rest_framework.views import APIView

from .models import UserAnalytics
from .serializers import UserAnalyticsSerializer

class HealthCheckApiView(APIView):
    """
    Simple network health checker api
    """
    def get(self, req: Request) -> Response:
        return Response({'success': True, 'message': 'Health check done!'}, status=status.HTTP_200_OK)


class UserAnalyticsListView(generics.ListCreateAPIView):
    """
    API endpoint returns all records from user_analytics table
    """
    # NOTE: Add pagination & sorting based on months
    queryset: ClassVar[QuerySet[UserAnalytics]] = UserAnalytics.objects.all()
    serializer_class: ClassVar[type[BaseSerializer]] = UserAnalyticsSerializer
        

# class CryptoMarketDataListView(generics.ListAPIView):
#     """
#     API endpoint returns all records from crypto_market_data table from postgres
#     """
#     queryset: ClassVar[QuerySet[CryptoMarketData]] = CryptoMarketData.objects.all()
#     serializer_class: ClassVar[type[BaseSerializer]] = CryptoMarketDataSerializer
# 
#     def list(self, request: Request, *args, **kwargs) -> Response:
#         queryset = self.get_queryset()
#         serializer = self.get_serializer(queryset, many=True)
# 
#         data = serializer.data
#         if not data:
#             return Response(
#                 {"Data": {}, "Err": {"success": False, "message": "Failed to fetch data"}},
#                 status=status.HTTP_400_BAD_REQUEST,
#             )
# 
#         # Transform into dict keyed by instrument
#         transformed = {
#             item["instrument"]: {k: v for k, v in item.items() if k != "instrument"}
#             for item in data
#         }
#         return Response({"Data": transformed, "Err": {}}, status=status.HTTP_200_OK)
