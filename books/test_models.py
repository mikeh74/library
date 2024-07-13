from django.test import TestCase
from django.urls import reverse

from books.models import Book, Author, Tag


class BookModelTest(TestCase):
    def setUp(self):
        self.author = Author.objects.create(forename="John", surname="Doe")
        self.tag1 = Tag.objects.create(name="Fiction")
        self.tag2 = Tag.objects.create(name="Mystery")
        self.book = Book.objects.create(
            title="Sample Book",
            author=self.author,
            status="i"
        )
        self.book.tags.add(self.tag1, self.tag2)

    def test_book_str(self):
        self.assertEqual(str(self.book), "Sample Book")

    def test_book_absolute_url(self):
        url = reverse("books:detail", kwargs={"book_id": self.book.pk})
        self.assertEqual(self.book.get_absolute_url(), url)

    def test_book_has_author(self):
        self.assertEqual(self.book.author, self.author)

    def test_book_has_tags(self):
        self.assertIn(self.tag1, self.book.tags.all())
        self.assertIn(self.tag2, self.book.tags.all())

    # def test_book_status_choices(self):
    #     self.assertIn(self.book.status, dict(Book.BOOK_STATUS_CHOICES).keys())

    def test_book_manager_active(self):
        active_books = Book.active.all()
        self.assertIn(self.book, active_books)

    def test_book_manager_default(self):
        all_books = Book.objects.all()
        self.assertIn(self.book, all_books)