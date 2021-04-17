from django.urls import path
from . import views

from .views import BookList

urlpatterns = [
    path('', BookList.as_view(), name='index'),
    path('add/', views.create, name='create'),
    path('<int:book_id>/edit/', views.edit, name='edit'),
    path('<int:book_id>/', views.detail, name='detail'),
]
