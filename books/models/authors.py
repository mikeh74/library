from django.db import models

MY_CONSTANT = 'Some string'

class Author(models.Model):
    forename = models.CharField(max_length=60)
    surname = models.CharField(max_length=60)

    def __str__(self) -> str:
        return "{} {}".format(self.forename, self.surname)

    # def get_absolute_url(self):
    #     return reverse("books:author_list")
