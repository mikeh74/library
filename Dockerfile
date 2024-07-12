# Base image to create venv and install requirements
FROM python:3.10-slim AS base-image
ENV PYTHONUNBUFFERED=1
RUN apt-get update \
  && apt-get install -y --no-install-recommends build-essential gcc \
  default-libmysqlclient-dev python3-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /opt/venv
# Make sure we use the virtualenv:
ENV PATH="/opt/venv/bin:$PATH"

WORKDIR /code
RUN pip install --upgrade pip
COPY requirements.txt /code/

# Install python requirements
# We don't need to cache packages
RUN pip install --no-cache-dir -r requirements.txt

FROM python:3.10-slim AS runtime-image
ENV PYTHONUNBUFFERED=1

# Copy venv
COPY --from=base-image /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
WORKDIR /code
# We don't copy code here as we're only using for local development

# Install gcc and libmysqlclient-dev for mysqlclient
RUN apt-get update \
  && apt-get install -y --no-install-recommends build-essential gcc \
  default-libmysqlclient-dev python3-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*


### simple dev image built on top of the base-image ###
FROM runtime-image AS dev

EXPOSE 8000
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]


### Debug image based on base-image with debug.py ###
FROM runtime-image AS debug

# We don't need to cache packages
RUN pip install --no-cache-dir debugpy

EXPOSE 5678

# Run Django with debugpy
CMD ["python", "-m", "debugpy", "--listen", "0.0.0.0:5678", "manage.py", "runserver", "0.0.0.0:8000"]


### Runtime image used for testing and production servers ###
FROM runtime-image AS prod

# copy in the source code
COPY . /code/

# Don't run as root user
RUN groupadd -r django && useradd -r -g django django
USER django

EXPOSE 8000

# run using gunicorn (make sure it's in the requirements)
CMD ["gunicorn", "--bind", ":8000", "--workers", "3", "library.wsgi:application"]
