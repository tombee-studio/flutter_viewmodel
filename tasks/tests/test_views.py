from django.test import TestCase, Client
from django.urls import reverse
from django.contrib.auth import get_user_model
from django.utils import timezone
from tasks.models import Task, Category

User = get_user_model()


class TaskListViewTest(TestCase):
    def setUp(self):
        self.client = Client()
        self.user = User.objects.create_user(
            username="testuser",
            email="test@example.com",
            password="testpassword123",
        )
        self.other_user = User.objects.create_user(
            username="otheruser",
            email="other@example.com",
            password="testpassword123",
        )
        self.task1 = Task.objects.create(
            title="Task 1",
            user=self.user,
        )
        self.task2 = Task.objects.create(
            title="Task 2",
            user=self.user,
        )
        self.other_task = Task.objects.create(
            title="Other User Task",
            user=self.other_user,
        )

    def test_task_list_requires_login(self):
        response = self.client.get(reverse("tasks:task_list"))
        self.assertRedirects(
            response,
            f"{reverse('login')}?next={reverse('tasks:task_list')}",
        )

    def test_task_list_view(self):
        self.client.login(username="testuser", password="testpassword123")
        response = self.client.get(reverse("tasks:task_list"))
        self.assertEqual(response.status_code, 200)

    def test_task_list_shows_own_tasks(self):
        self.client.login(username="testuser", password="testpassword123")
        response = self.client.get(reverse("tasks:task_list"))
        self.assertContains(response, "Task 1")
        self.assertContains(response, "Task 2")

    def test_task_list_does_not_show_other_users_tasks(self):
        self.client.login(username="testuser", password="testpassword123")
        response = self.client.get(reverse("tasks:task_list"))
        self.assertNotContains(response, "Other User Task")

    def test_task_list_uses_correct_template(self):
        self.client.login(username="testuser", password="testpassword123")
        response = self.client.get(reverse("tasks:task_list"))
        self.assertTemplateUsed(response, "tasks/task_list.html")


class TaskDetailViewTest(TestCase):
    def setUp(self):
        self.client = Client()
        self.user = User.objects.create_user(
            username="testuser",
            email="test@example.com",
            password="testpassword123",
        )
        self.other_user = User.objects.create_user(
            username="otheruser",
            email="other@example.com",
            password="testpassword123",
        )
        self.task = Task.objects.create(
            title="Test Task",
            description="Test Description",
            user=self.user,
        )
        self.other_task = Task.objects.create(
            title="Other Task",
            user=self.other_user,
        )

    def test_task_detail_requires_login(self):
        response = self.client.get(
            reverse("tasks:task_detail", kwargs={"pk": self.task.pk})
        )
        self.assertRedirects(
            response,
            f"{reverse('login')}?next={reverse('tasks:task_detail', kwargs={'pk': self.task.pk})}",
        )

    def test_task_detail_view(self):
        self.client.login(username="testuser", password="testpassword123")
        response = self.client.get(
            reverse("tasks:task_detail", kwargs={"pk": self.task.pk})
        )
        self.assertEqual(response.status_code, 200)

    def test_task_detail_shows_task_info(self):
        self.client.login(username="testuser", password="testpassword123")
        response = self.client.get(
            reverse("tasks:task_detail", kwargs={"pk": self.task.pk})
        )
        self.assertContains(response, "Test Task")
        self.assertContains(response, "Test Description")

    def test_task_detail_uses_correct_template(self):
        self.client.login(username="testuser", password="testpassword123")
        response = self.client.get(
            reverse("tasks:task_detail", kwargs={"pk": self.task.pk})
        )
        self.assertTemplateUsed(response, "tasks/task_detail.html")

    def test_task_detail_returns_404_for_other_users_task(self):
        self.client.login(username="testuser", password="testpassword123")
        response = self.client.get(
            reverse("tasks:task_detail", kwargs={"pk": self.other_task.pk})
        )
        self.assertEqual(response.status_code, 404)


class TaskCreateViewTest(TestCase):
    def setUp(self):
        self.client = Client()
        self.user = User.objects.create_user(
            username="testuser",
            email="test@example.com",
            password="testpassword123",
        )
        self.category = Category.objects.create(
            name="Work",
            user=self.user,
        )

    def test_task_create_requires_login(self):
        response = self.client.get(reverse("tasks:task_create"))
        self.assertRedirects(
            response,
            f"{reverse('login')}?next={reverse('tasks:task_create')}",
        )

    def test_task_create_view_get(self):
        self.client.login(username="testuser", password="testpassword123")
        response = self.client.get(reverse("tasks:task_create"))
        self.assertEqual(response.status_code, 200)

    def test_task_create_view_uses_correct_template(self):
        self.client.login(username="testuser", password="testpassword123")
        response = self.client.get(reverse("tasks:task_create"))
        self.assertTemplateUsed(response, "tasks/task_form.html")

    def test_task_create_post(self):
        self.client.login(username="testuser", password="testpassword123")
        response = self.client.post(
            reverse("tasks:task_create"),
            {
                "title": "New Task",
                "description": "New Description",
                "priority": "medium",
            },
        )
        self.assertEqual(Task.objects.filter(user=self.user).count(), 1)
        task = Task.objects.get(user=self.user, title="New Task")
        self.assertEqual(task.title, "New Task")

    def test_task_create_redirects_on_success(self):
        self.client.login(username="testuser", password="testpassword123")
        response = self.client.post(
            reverse("tasks:task_create"),
            {
                "title": "New Task",
                "description": "New Description",
                "priority": "medium",
            },
        )
        self.assertRedirects(response, reverse("tasks:task_list"))

    def test_task_create_assigns_to_current_user(self):
        self.client.login(username="testuser", password="testpassword123")
        self.client.post(
            reverse("tasks:task_create"),
            {
                "title": "New Task",
                "priority": "medium",
            },
        )
        task = Task.objects.get(title="New Task")
        self.assertEqual(task.user, self.user)

    def test_task_create_with_invalid_data(self):
        self.client.login(username="testuser", password="testpassword123")
        response = self.client.post(
            reverse("tasks:task_create"),
            {"title": ""},
        )
        self.assertEqual(response.status_code, 200)
        self.assertEqual(Task.objects.filter(user=self.user).count(), 0)


class TaskUpdateViewTest(TestCase):
    def setUp(self):
        self.client = Client()
        self.user = User.objects.create_user(
            username="testuser",
            email="test@example.com",
            password="testpassword123",
        )
        self.other_user = User.objects.create_user(
            username="otheruser",
            email="other@example.com",
            password="testpassword123",
        )
        self.task = Task.objects.create(
            title="Original Title",
            description="Original Description",
            user=self.user,
            priority="medium",
        )
        self.other_task = Task.objects.create(
            title="Other Task",
            user=self.other_user,
            priority="medium",
        )

    def test_task_update_requires_login(self):
        response = self.client.get(
            reverse("tasks:task_update", kwargs={"pk": self.task.pk})
        )
        self.assertRedirects(
            response,
            f"{reverse('login')}?next={reverse('tasks:task_update', kwargs={'pk': self.task.pk})}",
        )

    def test_task_update_view_get(self):
        self.client.login(username="testuser", password="testpassword123")
        response = self.client.get(
            reverse("tasks:task_update", kwargs={"pk": self.task.pk})
        )
        self.assertEqual(response.status_code, 200)

    def test_task_update_view_uses_correct_template(self):
        self.client.login(username="testuser", password="testpassword123")
        response = self.client.get(
            reverse("tasks:task_update", kwargs={"pk": self.task.pk})
        )
        self.assertTemplateUsed(response, "tasks/task_form.html")

    def test_task_update_post(self):
        self.client.login(username="testuser", password="testpassword123")
        self.client.post(
            reverse("tasks:task_update", kwargs={"pk": self.task.pk}),
            {
                "title": "Updated Title",
                "description": "Updated Description",
                "priority": "high",
            },
        )
        self.task.refresh_from_db()
        self.assertEqual(self.task.title, "Updated Title")
        self.assertEqual(self.task.description, "Updated Description")

    def test_task_update_redirects_on_success(self):
        self.client.login(username="testuser", password="testpassword123")
        response = self.client.post(
            reverse("tasks:task_update", kwargs={"pk": self.task.pk}),
            {
                "title": "Updated Title",
                "priority": "high",
            },
        )
        self.assertRedirects(response, reverse("tasks:task_list"))

    def test_task_update_returns_404_for_other_users_task(self):
        self.client.login(username="testuser", password="testpassword123")
        response = self.client.get(
            reverse("tasks:task_update", kwargs={"pk": self.other_task.pk})
        )
        self.assertEqual(response.status_code, 404)


class TaskDeleteViewTest(TestCase):
    def setUp(self):
        self.client = Client()
        self.user = User.objects.create_user(
            username="testuser",
            email="test@example.com",
            password="testpassword123",
        )
        self.other_user = User.objects.create_user(
            username="otheruser",
            email="other@example.com",
            password="testpassword123",
        )
        self.task = Task.objects.create(
            title="Task to Delete",
            user=self.user,
        )
        self.other_task = Task.objects.create(
            title="Other Task",
            user=self.other_user,
        )

    def test_task_delete_requires_login(self):
        response = self.client.post(
            reverse("tasks:task_delete", kwargs={"pk": self.task.pk})
        )
        self.assertRedirects(
            response,
            f"{reverse('login')}?next={reverse('tasks:task_delete', kwargs={'pk': self.task.pk})}",
        )

    def test_task_delete_view_get(self):
        self.client.login(username="testuser", password="testpassword123")
        response = self.client.get(
            reverse("tasks:task_delete", kwargs={"pk": self.task.pk})
        )
        self.assertEqual(response.status_code, 200)

    def test_task_delete_view_uses_correct_template(self):
        self.client.login(username="testuser", password="testpassword123")
        response = self.client.get(
            reverse("tasks:task_delete", kwargs={"pk": self.task.pk})
        )
        self.assertTemplateUsed(response, "tasks/task_confirm_delete.html")

    def test_task_delete_post(self):
        self.client.login(username="testuser", password="testpassword123")
        self.client.post(
            reverse("tasks:task_delete", kwargs={"pk": self.task.pk})
        )
        self.assertFalse(Task.objects.filter(pk=self.task.pk).exists())

    def test_task_delete_redirects_on_success(self):
        self.client.login(username="testuser", password="testpassword123")
        response = self.client.post(
            reverse("tasks:task_delete", kwargs={"pk": self.task.pk})
        )
        self.assertRedirects(response, reverse("tasks:task_list"))

    def test_task_delete_returns_404_for_other_users_task(self):
        self.client.login(username="testuser", password="testpassword123")
        response = self.client.post(
            reverse("tasks:task_delete", kwargs={"pk": self.other_task.pk})
        )
        self.assertEqual(response.status_code, 404)
        self.assertTrue(Task.objects.filter(pk=self.other_task.pk).exists())


class TaskCompleteViewTest(TestCase):
    def setUp(self):
        self.client = Client()
        self.user = User.objects.create_user(
            username="testuser",
            email="test@example.com",
            password="testpassword123",
        )
        self.other_user = User.objects.create_user(
            username="otheruser",
            email="other@example.com",
            password="testpassword123",
        )
        self.task = Task.objects.create(
            title="Test Task",
            user=self.user,
            completed=False,
        )
        self.other_task = Task.objects.create(
            title="Other Task",
            user=self.other_user,
            completed=False,
        )

    def test_task_complete_requires_login(self):
        response = self.client.post(
            reverse("tasks:task_complete", kwargs={"pk": self.task.pk})
        )
        self.assertRedirects(
            response,
            f"{reverse('login')}?next={reverse('tasks:task_complete', kwargs={'pk': self.task.pk})}",
        )

    def test_task_complete_post(self):
        self.client.login(username="testuser", password="testpassword123")
        self.client.post(
            reverse("tasks:task_complete", kwargs={"pk": self.task.pk})
        )
        self.task.refresh_from_db()
        self.assertTrue(self.task.completed)

    def test_task_complete_redirects_on_success(self):
        self.client.login(username="testuser", password="testpassword123")
        response = self.client.post(
            reverse("tasks:task_complete", kwargs={"pk": self.task.pk})
        )
        self.assertRedirects(response, reverse("tasks:task_list"))

    def test_task_complete_returns_404_for_other_users_task(self):
        self.client.login(username="testuser", password="testpassword123")
        response = self.client.post(
            reverse("tasks:task_complete", kwargs={"pk": self.other_task.pk})
        )
        self.assertEqual(response.status_code, 404)
