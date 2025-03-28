from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .models import SunshineData
from .serializers import SunshineSerializer
import random
from datetime import datetime, timedelta

class SunshineAPIView(APIView):
    def get(self, request):
        # Try to get data from database
        try:
            data = SunshineData.objects.latest('date')
            serializer = SunshineSerializer(data)
            return Response(serializer.data)
        
        except SunshineData.DoesNotExist:
            # Generate realistic mock data
            now = datetime.now()
            hourly_data = []
            
            # Generate data for each hour (6AM to 6PM)
            for hour in range(6, 19):
                time_str = f"{hour}:00"
                value = round(random.uniform(0.1, 1.5), 1)
                hourly_data.append({"hour": time_str, "value": value})
            
            # Calculate total as sum of hourly values
            total = round(sum([x['value'] for x in hourly_data]), 1)
            
            mock_data = {
                'date': now.isoformat(),
                'total_hours': total,
                'hourly_data': hourly_data
            }
            
            # Create and save mock data
            SunshineData.objects.create(
                date=now.date(),
                total_hours=total,
                hourly_data=hourly_data
            )
            
            return Response(mock_data, status=status.HTTP_200_OK)