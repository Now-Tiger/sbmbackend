# sbm_backend/apis/models.py
from django.db import models


class UserAnalytics(models.Model):
    """
    User analytics object/model
    """

    id = models.AutoField(primary_key=True)
    date = models.DateField()
    desktop = models.IntegerField()
    mobile = models.IntegerField()

    class Meta:
        """
        Meta data about the object
        """

        managed: bool = False
        db_table: str = 'user_analytics'


# class CryptoMarketData(models.Model):
#     """
#     Crypto market data object/model
#     """
# 
#     instrument = models.CharField(max_length=50, primary_key=True)  # e.g. BTC-USD
#     type = models.CharField(max_length=50, null=True, blank=True)
#     market = models.CharField(max_length=50, null=True, blank=True)
#     ccseq = models.BigIntegerField(null=True, blank=True)
#     value = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     value_flag = models.CharField(max_length=20, null=True, blank=True)
#     value_last_update_ts = models.BigIntegerField(null=True, blank=True)
#     value_last_update_ts_ns = models.BigIntegerField(null=True, blank=True)
#     last_update_quantity = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     last_update_quote_quantity = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
# 
#     # Current period values
#     current_hour_open = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     current_hour_high = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     current_hour_low = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     current_hour_change = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     current_hour_change_percentage = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
# 
#     current_day_open = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     current_day_high = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     current_day_low = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     current_day_change = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     current_day_change_percentage = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
# 
#     current_week_open = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     current_week_high = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     current_week_low = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     current_week_change = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     current_week_change_percentage = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
# 
#     current_month_open = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     current_month_high = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     current_month_low = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     current_month_change = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     current_month_change_percentage = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
# 
#     current_year_open = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     current_year_high = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     current_year_low = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     current_year_change = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     current_year_change_percentage = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
# 
#     # Moving periods
#     moving_24_hour_open = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     moving_24_hour_high = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     moving_24_hour_low = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     moving_24_hour_change = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     moving_24_hour_change_percentage = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
# 
#     moving_7_day_open = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     moving_7_day_high = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     moving_7_day_low = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     moving_7_day_change = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     moving_7_day_change_percentage = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
# 
#     moving_30_day_open = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     moving_30_day_high = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     moving_30_day_low = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     moving_30_day_change = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     moving_30_day_change_percentage = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
# 
#     moving_90_day_open = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     moving_90_day_high = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     moving_90_day_low = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     moving_90_day_change = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     moving_90_day_change_percentage = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
# 
#     moving_180_day_open = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     moving_180_day_high = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     moving_180_day_low = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     moving_180_day_change = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     moving_180_day_change_percentage = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
# 
#     moving_365_day_open = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     moving_365_day_high = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     moving_365_day_low = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     moving_365_day_change = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
#     moving_365_day_change_percentage = models.DecimalField(max_digits=30, decimal_places=10, null=True, blank=True)
# 
#     class Meta:
#         managed = False
#         db_table = 'crypto_market_data'

