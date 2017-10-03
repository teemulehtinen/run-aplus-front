from datetime import timedelta
from django.core.management.base import BaseCommand
from django.contrib.auth.models import User
from django.utils import timezone

from course.models import CourseInstance
from edit_course.operations.configure import configure_content

class Command(BaseCommand):
    help = 'Configure test content for the default course'

    def handle(self, *args, **options):
        instance = CourseInstance.objects.get(
            course__url="def",
            url="current",
        )
        errors = configure_content(instance, instance.configure_url)
        if errors:
            print("\n".join(errors))
            print("Failed!")
        else:
            print("Ok")
