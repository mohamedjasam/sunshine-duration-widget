# Generated by Django 5.1.5 on 2025-03-26 01:16

from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='SunshineData',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('date', models.DateField()),
                ('total_hours', models.FloatField()),
                ('hourly_data', models.JSONField()),
            ],
        ),
    ]
