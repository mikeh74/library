from django.db import models
from django.urls import reverse


class Tag(models.Model):
    name = models.CharField(max_length=50)

    def __str__(self) -> str:
        return self.name


class Author(models.Model):
    forename = models.CharField(max_length=60)
    surname = models.CharField(max_length=60)

    def __str__(self) -> str:
        return "{} {}".format(self.forename, self.surname)


class Book(models.Model):
    title = models.CharField(max_length=120)
    author = models.ForeignKey(Author, on_delete=models.PROTECT)
    tags = models.ManyToManyField(Tag)

    def get_absolute_url(self):
        return reverse("books:detail",
                       kwargs={"book_id": self.pk})

    def __str__(self) -> str:
        return self.title
