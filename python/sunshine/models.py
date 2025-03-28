# models.py
from django.db import models

class SunshineData(models.Model):
    date = models.DateField()
    total_hours = models.FloatField()
    hourly_data = models.JSONField()  # e.g., [{"hour": "09:00", "value": 1.2}, ...]