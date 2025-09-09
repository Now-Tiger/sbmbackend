from rest_framework import serializers
from .models import UserAnalytics


class UserAnalyticsSerializer(serializers.ModelSerializer):

    class Meta:

        model: type[UserAnalytics] = UserAnalytics
        fields: list[str] = ['date', 'desktop', 'mobile']


# class CryptoMarketDataSerializer(serializers.ModelSerializer):
#     instrument = serializers.CharField()
#     type = serializers.CharField()
#     market = serializers.CharField()
#     ccseq = serializers.IntegerField()
#     value = serializers.FloatField()
#     value_flag = serializers.CharField()
#     value_last_update_ts = serializers.IntegerField()
#     value_last_update_ts_ns = serializers.IntegerField()
#     last_update_quantity = serializers.FloatField()
#     last_update_quote_quantity = serializers.FloatField()
#     # Current period values
#     current_hour_open = serializers.FloatField()
#     current_hour_high = serializers.FloatField()
#     current_hour_low = serializers.FloatField()
#     current_hour_change = serializers.FloatField()
#     current_hour_change_percentage = serializers.FloatField()
# 
#     current_day_open = serializers.FloatField()
#     current_day_high = serializers.FloatField()
#     current_day_low = serializers.FloatField()
#     current_day_change = serializers.FloatField()
#     current_day_change_percentage = serializers.FloatField()
# 
#     current_week_open = serializers.FloatField()
#     current_week_high = serializers.FloatField()
#     current_week_low = serializers.FloatField()
#     current_week_change = serializers.FloatField()
#     current_week_change_percentage = serializers.FloatField()
# 
#     current_month_open = serializers.FloatField()
#     current_month_high = serializers.FloatField()
#     current_month_low = serializers.FloatField()
#     current_month_change = serializers.FloatField()
#     current_month_change_percentage = serializers.FloatField()
# 
#     current_year_open = serializers.FloatField()
#     current_year_high = serializers.FloatField()
#     current_year_low = serializers.FloatField()
#     current_year_change = serializers.FloatField()
#     current_year_change_percentage = serializers.FloatField()
# 
#     # Moving periods
#     moving_24_hour_open = serializers.FloatField()
#     moving_24_hour_high = serializers.FloatField()
#     moving_24_hour_low = serializers.FloatField()
#     moving_24_hour_change = serializers.FloatField()
#     moving_24_hour_change_percentage = serializers.FloatField()
# 
#     moving_7_day_open = serializers.FloatField()
#     moving_7_day_high = serializers.FloatField()
#     moving_7_day_low = serializers.FloatField()
#     moving_7_day_change = serializers.FloatField()
#     moving_7_day_change_percentage = serializers.FloatField()
# 
#     moving_30_day_open = serializers.FloatField()
#     moving_30_day_high = serializers.FloatField()
#     moving_30_day_low = serializers.FloatField()
#     moving_30_day_change = serializers.FloatField()
#     moving_30_day_change_percentage = serializers.FloatField()
# 
#     moving_90_day_open = serializers.FloatField()
#     moving_90_day_high = serializers.FloatField()
#     moving_90_day_low = serializers.FloatField()
#     moving_90_day_change = serializers.FloatField()
#     moving_90_day_change_percentage = serializers.FloatField()
# 
#     moving_180_day_open = serializers.FloatField()
#     moving_180_day_high = serializers.FloatField()
#     moving_180_day_low = serializers.FloatField()
#     moving_180_day_change = serializers.FloatField()
#     moving_180_day_change_percentage = serializers.FloatField()
# 
#     moving_365_day_open = serializers.FloatField()
#     moving_365_day_high = serializers.FloatField()
#     moving_365_day_low = serializers.FloatField()
#     moving_365_day_change = serializers.FloatField()
#     moving_365_day_change_percentage = serializers.FloatField()
# 
#     class Meta:
# 
#         model: type[CryptoMarketData] = CryptoMarketData
#         fields: str = "__all__"
