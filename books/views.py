from django.shortcuts import get_object_or_404, render
from django.http import HttpResponseRedirect
from django.views.generic import ListView
from django.urls import reverse_lazy

from django.views.generic.edit import CreateView, DeleteView, UpdateView

from .models import Author, Book
from .forms import BookForm

class BookList(ListView):
    model = Book
    context_object_name = 'books'

class AuthorList(ListView):
    model = Author
    context_object_name = 'authors'


class AuthorCreateView(CreateView):
    model = Author
    fields = ['forename', 'surname']
    success_url = reverse_lazy('books:author_list')

class AuthorUpdateView(UpdateView):
    model = Author
    fields = ['forename', 'surname']
    success_url = reverse_lazy('books:author_list')


def index(request):
    books = Book.objects.all()
    context = {'books': books}
    return render(request, 'books/index.html', context)

def detail(request, book_id):
    book = get_object_or_404(Book, pk=book_id)
    context = {'book': book}
    return render(request, 'books/detail.html', context)

def create(request):

    if request.method == "POST":
          #Get the posted form
          form = BookForm(request.POST)

          if form.is_valid():
              form.save()

              url = '/books/'
              return HttpResponseRedirect(url)

    else:
          form = BookForm()

    context = {'form': form}
    return render(request, 'books/edit.html', context)

def edit(request, book_id):
    book = get_object_or_404(Book, pk=book_id)
    if request.method == "POST":
          #Get the posted form
          form = BookForm(request.POST, instance=book)

          if form.is_valid():
              form.save()

              url = '/books/{}'.format(form.instance.id)
              return HttpResponseRedirect(url)

    else:
          form = BookForm(instance=book)

    context = {'form': form}
    return render(request, 'books/edit.html', context)
