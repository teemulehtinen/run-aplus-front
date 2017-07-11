from datetime import timedelta
from django.core.management.base import BaseCommand
from django.contrib.auth.models import User
from django.utils import timezone

from course.models import Course, CourseInstance
from userprofile.models import UserProfile

class Command(BaseCommand):
    help = 'Setup database for testing a default course'

    def handle(self, *args, **options):
        self.create_default_users()
        self.create_default_courses()

    def create_default_users(self):

        u1 = User.objects.create(
            username="root",
            email="root@localhost",
            first_name="Ruth",
            last_name="Robinson",
            is_superuser=True,
            is_staff=True,
        )
        u1.set_password("root")
        u1.save()

        u2 = User.objects.create(
            username="student",
            email="student@localhost",
            first_name="Stacey",
            last_name="Smith",
        )
        u2.set_password("student")
        u2.save()
        u2.userprofile.student_id = "123456"
        u2.userprofile.save()

    def create_default_courses(self):
        course = Course.objects.create(
            name="Def. Course",
            code="DEF000",
            url="def",
        )
        today = timezone.now()
        instance = CourseInstance.objects.create(
            course=course,
            instance_name="Current",
            url="current",
            starting_time=today,
            ending_time=today + timedelta(days=365),
            configure_url="http://grader/default/aplus-json",
        )
