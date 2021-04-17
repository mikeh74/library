from django.forms import CheckboxSelectMultiple, ModelForm

from .models import Book


class BookForm(ModelForm):
    class Meta:
        model = Book
        fields = ['title', 'author', 'tags']

        widgets = {
            'tags': CheckboxSelectMultiple()
        }
