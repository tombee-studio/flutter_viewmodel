from django.test import TestCase
from django.urls import reverse, resolve
from tasks.views import (
    TaskListView,
    TaskDetailView,
    TaskCreateView,
    TaskUpdateView,
    TaskDeleteView,
    TaskCompleteView,
)


class TaskURLsTest(TestCase):
    def test_task_list_url(self):
        url = reverse("tasks:task_list")
        self.assertEqual(url, "/tasks/")

    def test_task_list_resolves(self):
        resolver = resolve("/tasks/")
        self.assertEqual(resolver.func.view_class, TaskListView)

    def test_task_detail_url(self):
        url = reverse("tasks:task_detail", kwargs={"pk": 1})
        self.assertEqual(url, "/tasks/1/")

    def test_task_detail_resolves(self):
        resolver = resolve("/tasks/1/")
        self.assertEqual(resolver.func.view_class, TaskDetailView)

    def test_task_create_url(self):
        url = reverse("tasks:task_create")
        self.assertEqual(url, "/tasks/create/")

    def test_task_create_resolves(self):
        resolver = resolve("/tasks/create/")
        self.assertEqual(resolver.func.view_class, TaskCreateView)

    def test_task_update_url(self):
        url = reverse("tasks:task_update", kwargs={"pk": 1})
        self.assertEqual(url, "/tasks/1/update/")

    def test_task_update_resolves(self):
        resolver = resolve("/tasks/1/update/")
        self.assertEqual(resolver.func.view_class, TaskUpdateView)

    def test_task_delete_url(self):
        url = reverse("tasks:task_delete", kwargs={"pk": 1})
        self.assertEqual(url, "/tasks/1/delete/")

    def test_task_delete_resolves(self):
        resolver = resolve("/tasks/1/delete/")
        self.assertEqual(resolver.func.view_class, TaskDeleteView)

    def test_task_complete_url(self):
        url = reverse("tasks:task_complete", kwargs={"pk": 1})
        self.assertEqual(url, "/tasks/1/complete/")

    def test_task_complete_resolves(self):
        resolver = resolve("/tasks/1/complete/")
        self.assertEqual(resolver.func.view_class, TaskCompleteView)
