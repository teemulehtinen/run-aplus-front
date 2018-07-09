import os
import sys
import django
from datetime import timedelta
from django.utils import timezone


def create_default_users():
    from django.contrib.auth.models import User

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

def create_default_courses():
    from course.models import Course, CourseInstance

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
        configure_url="http://grader:8080/default/aplus-json",
    )

def create_default_services():
    from external_services.models import LTIService

    service = LTIService.objects.create(
        url="http://localhost:8090/",
        menu_label="Rubyric+",
        menu_icon_class="save-file",
        consumer_key="foo",
        consumer_secret="bar",
    )


if __name__ == '__main__':
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "aplus.settings")
    sys.path.insert(0, '')
    django.setup()

    create_default_users()
    create_default_courses()
    create_default_services()
