from django import forms
from django.contrib import admin
from django.contrib.admin.widgets import FilteredSelectMultiple
from .models import Tag, Author, Book
# Register your models here.

# admin.site.register(Tag)

@admin.register(Book)
class BookAdmin(admin.ModelAdmin):
    list_display = ['title', 'status', 'author']
    filter_horizontal = ('tags',)
    actions = ['make_loaned', 'make_instock']
    list_filter = ['tags', 'status']
    search_fields = ['title', 'author__forename', 'author__surname']

    # @admin.action(description='Indicate as out on loan')
    def make_loaned(self, request, queryset):
        queryset.update(status='o')

    # @admin.action(description='Indicate as in stock')
    def make_instock(self, request, queryset):
        queryset.update(status='i')


class TagAdminForm(forms.ModelForm):
    books = forms.ModelMultipleChoiceField(
        queryset=Book.objects.all(),
        required=False,
        widget=FilteredSelectMultiple(
            verbose_name='Books',
            is_stacked=False
        )
    )

    class Meta:
        model = Tag
        fields = '__all__'

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        if self.instance and self.instance.pk:
            self.fields['books'].initial = self.instance.book_tags.all()

    def save(self, commit=True):
        tag = super().save(commit=False)

        if commit:
            tag.save()
        # We need to save the initial object before we can add related records

        tag.save()
        tag.book_tags.set(self.cleaned_data['books'])
        self.save_m2m()

        return tag


@admin.register(Tag)
class TagAdmin(admin.ModelAdmin):
    form = TagAdminForm

admin.site.register(Author)
