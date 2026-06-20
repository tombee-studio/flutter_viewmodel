from django.test import TestCase
from django.contrib.auth import get_user_model
from django.utils import timezone
from tasks.forms import TaskForm, CategoryForm
from tasks.models import Category

User = get_user_model()


class TaskFormTest(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username="testuser",
            email="test@example.com",
            password="testpassword123",
        )
        self.category = Category.objects.create(
            name="Work",
            user=self.user,
        )

    def test_task_form_valid_with_required_fields(self):
        form = TaskForm(
            data={
                "title": "Test Task",
                "priority": "medium",
            },
            user=self.user,
        )
        self.assertTrue(form.is_valid())

    def test_task_form_invalid_without_title(self):
        form = TaskForm(
            data={
                "priority": "medium",
            },
            user=self.user,
        )
        self.assertFalse(form.is_valid())
        self.assertIn("title", form.errors)

    def test_task_form_valid_with_all_fields(self):
        due_date = timezone.now() + timezone.timedelta(days=7)
        form = TaskForm(
            data={
                "title": "Test Task",
                "description": "Test Description",
                "priority": "high",
                "due_date": due_date.strftime("%Y-%m-%d %H:%M:%S"),
                "category": self.category.pk,
            },
            user=self.user,
        )
        self.assertTrue(form.is_valid())

    def test_task_form_only_shows_users_categories(self):
        other_user = User.objects.create_user(
            username="otheruser",
            email="other@example.com",
            password="testpassword123",
        )
        other_category = Category.objects.create(
            name="Other Category",
            user=other_user,
        )
        form = TaskForm(data={}, user=self.user)
        category_choices = form.fields["category"].queryset
        self.assertIn(self.category, category_choices)
        self.assertNotIn(other_category, category_choices)

    def test_task_form_title_max_length(self):
        form = TaskForm(
            data={
                "title": "a" * 256,
                "priority": "medium",
            },
            user=self.user,
        )
        self.assertFalse(form.is_valid())
        self.assertIn("title", form.errors)


class CategoryFormTest(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username="testuser",
            email="test@example.com",
            password="testpassword123",
        )

    def test_category_form_valid(self):
        form = CategoryForm(
            data={"name": "Work"},
        )
        self.assertTrue(form.is_valid())

    def test_category_form_invalid_without_name(self):
        form = CategoryForm(data={})
        self.assertFalse(form.is_valid())
        self.assertIn("name", form.errors)

    def test_category_form_name_max_length(self):
        form = CategoryForm(
            data={"name": "a" * 101},
        )
        self.assertFalse(form.is_valid())
        self.assertIn("name", form.errors)
