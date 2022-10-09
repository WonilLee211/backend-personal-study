from django.db import models

# Create your models here.
class Movie(models.Model):
    title = models.CharField(max_length=20)
    audience = models.IntegerField()
    release_date = models.DateField()
    gerne = models.CharField(max_length=30)
    score = models.FloatField(default=5)
    poster_url = models.TextField()
    description = models.TextField()

    def __str__(self):
        return self.title