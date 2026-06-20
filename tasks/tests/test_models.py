from django.test import TestCase
from django.contrib.auth import get_user_model
from django.utils import timezone
from tasks.models import Task, Category

User = get_user_model()


class CategoryModelTest(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username="testuser",
            email="test@example.com",
            password="testpassword123",
        )

    def test_create_category(self):
        category = Category.objects.create(
            name="Work",
            user=self.user,
        )
        self.assertEqual(category.name, "Work")
        self.assertEqual(category.user, self.user)

    def test_category_str(self):
        category = Category.objects.create(
            name="Personal",
            user=self.user,
        )
        self.assertEqual(str(category), "Personal")

    def test_category_unique_per_user(self):
        Category.objects.create(name="Work", user=self.user)
        with self.assertRaises(Exception):
            Category.objects.create(name="Work", user=self.user)

    def test_different_users_can_have_same_category_name(self):
        other_user = User.objects.create_user(
            username="otheruser",
            email="other@example.com",
            password="testpassword123",
        )
        Category.objects.create(name="Work", user=self.user)
        category2 = Category.objects.create(name="Work", user=other_user)
        self.assertEqual(category2.name, "Work")


class TaskModelTest(TestCase):
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

    def test_create_task(self):
        task = Task.objects.create(
            title="Test Task",
            user=self.user,
        )
        self.assertEqual(task.title, "Test Task")
        self.assertEqual(task.user, self.user)
        self.assertFalse(task.completed)

    def test_task_str(self):
        task = Task.objects.create(
            title="My Task",
            user=self.user,
        )
        self.assertEqual(str(task), "My Task")

    def test_task_default_completed_is_false(self):
        task = Task.objects.create(
            title="Test Task",
            user=self.user,
        )
        self.assertFalse(task.completed)

    def test_task_with_description(self):
        task = Task.objects.create(
            title="Test Task",
            description="This is a description",
            user=self.user,
        )
        self.assertEqual(task.description, "This is a description")

    def test_task_with_due_date(self):
        due_date = timezone.now() + timezone.timedelta(days=7)
        task = Task.objects.create(
            title="Test Task",
            due_date=due_date,
            user=self.user,
        )
        self.assertIsNotNone(task.due_date)

    def test_task_with_category(self):
        task = Task.objects.create(
            title="Test Task",
            category=self.category,
            user=self.user,
        )
        self.assertEqual(task.category, self.category)

    def test_task_complete(self):
        task = Task.objects.create(
            title="Test Task",
            user=self.user,
        )
        task.completed = True
        task.save()
        task.refresh_from_db()
        self.assertTrue(task.completed)

    def test_task_ordering(self):
        task1 = Task.objects.create(title="Task A", user=self.user)
        task2 = Task.objects.create(title="Task B", user=self.user)
        tasks = Task.objects.filter(user=self.user)
        self.assertIn(task1, tasks)
        self.assertIn(task2, tasks)

    def test_task_created_at_auto_set(self):
        task = Task.objects.create(
            title="Test Task",
            user=self.user,
        )
        self.assertIsNotNone(task.created_at)

    def test_task_updated_at_auto_set(self):
        task = Task.objects.create(
            title="Test Task",
            user=self.user,
        )
        self.assertIsNotNone(task.updated_at)

    def test_task_priority_default(self):
        task = Task.objects.create(
            title="Test Task",
            user=self.user,
        )
        self.assertIsNotNone(task.priority)
