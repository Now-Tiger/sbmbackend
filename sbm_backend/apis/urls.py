from .views import CryptoMarketDataListView, HealthCheckApiView, UserAnalyticsListView
from django.urls import path

urlpatterns = [
    path("", view=HealthCheckApiView.as_view(), name="health-check"),
    path("user-analytics/", view=UserAnalyticsListView.as_view(), name="user-analytics"),
    path("crypto-market-data/", view=CryptoMarketDataListView.as_view(), name="crypto-data"),
]
