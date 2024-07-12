from django.http import HttpResponse
from django.template import loader


def home(request):
    template = loader.get_template("home.html")
    context = {
        "title": "Home",
        "message": "Welcome to the library!",
    }
    return HttpResponse(template.render(context, request))
