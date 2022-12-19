from django.db import models
from django.urls import reverse

from ..utils import my_function

class Tag(models.Model):
    name = models.CharField(max_length=50)

    def __str__(self) -> str:
        return self.name




BOOK_STATUS_CHOICES = (
    ('i', 'In stock'),
    ('o', 'On Loan'),
)


class BookInStockManager(models.Manager):
    def get_queryset(self):
        q = super().get_queryset()
        q = q.filter(status='i')

        return q


class Book(models.Model):
    title = models.CharField(max_length=120)
    author = models.ForeignKey(Author, on_delete=models.PROTECT)
    tags = models.ManyToManyField(Tag, related_name='book_tags')
    status = models.CharField(
        max_length=50,
        choices=BOOK_STATUS_CHOICES,
        default=BOOK_STATUS_CHOICES[0][0])

    objects = models.Manager()  # The default manager.
    active = BookInStockManager()

    def get_absolute_url(self):
        return reverse("books:detail",
                       kwargs={"book_id": self.pk})

    def __str__(self) -> str:
        return self.title

class Category(models.Model):
    name = models.CharField(max_length=120)
