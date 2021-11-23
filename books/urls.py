from django.urls import path
from . import views

from .views import BookList, AuthorList, AuthorCreateView

urlpatterns = [
    path('', BookList.as_view(), name='index'),
    path('add/', views.create, name='create'),
    path('<int:book_id>/edit/', views.edit, name='edit'),
    path('<int:book_id>/', views.detail, name='detail'),
    path('authors/', AuthorList.as_view(), name='author_list'),
    path('author/add/', AuthorCreateView.as_view(), name='author_add'),
]
