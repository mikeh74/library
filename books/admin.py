from django.contrib import admin
from .models import Tag, Author, Book
# Register your models here.

admin.site.register(Tag)
admin.site.register(Author)

@admin.register(Book)
class BookAdmin(admin.ModelAdmin):
    filter_horizontal = ('tags',)