from rest_framework import serializers
from .models import SunshineData

class SunshineSerializer(serializers.ModelSerializer):
    class Meta:
        model = SunshineData
        fields = '__all__'