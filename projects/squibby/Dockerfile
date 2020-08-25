FROM python:3.7-alpine

ARG PROJECT_PATH=.
ENV \
APP_HOME /app  \
PORT=3000 \
APP_NAME  Default

WORKDIR $APP_HOME

RUN set -ex && \
    apk add --no-cache \
    python3 \
    bash \
    curl \
  && \
    ln -s /usr/bin/python3 /usr/bin/python

#Copy files and pipenv
COPY ${PROJECT_PATH}/app.py  ./
COPY ${PROJECT_PATH}/Pipfile* ./

RUN python3 -m pip install pipenv

RUN  pipenv install --deploy --system

CMD ["python", "app.py"]

EXPOSE $PORT
