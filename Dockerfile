FROM python:3.7
LABEL maintainer="James Turk <james@openstates.org>"

# global environment settings
ENV PYTHONUNBUFFERED=1 PYTHONDONTWRITEBYTECODE=1 PYTHONIOENCODING='utf-8' LANG='C.UTF-8'
STOPSIGNAL SIGINT

EXPOSE 8000

RUN BUILD_DEPS=" \
      python3-dev \
      git \
      build-essential \
      libpq-dev \
      libgeos-dev \
      libgdal-dev \
      libcap-dev \
      wget \
      postgresql-client \
      uwsgi \
      uwsgi-src \
    " \
    && apt-get update && apt-get install -y --no-install-recommends $BUILD_DEPS

RUN cd /usr/lib/uwsgi/plugins && uwsgi --build-plugin "/usr/src/uwsgi/plugins/python python37"

# copy code and entrypoint in
ADD . /code/
WORKDIR /code/
COPY docker/uwsgi/custom-entrypoint /usr/local/bin
RUN chmod a+x /usr/local/bin/custom-entrypoint

RUN wget https://deb.nodesource.com/setup_10.x -O nodesource.sh \
    && bash nodesource.sh \
    && apt install -y nodejs \
    && npm ci \
    && npm run build
RUN pip install poetry


# everything after here as openstates user
RUN groupadd -r openstates && useradd --no-log-init -r -g openstates openstates
RUN mkdir /home/openstates && chown openstates:openstates /home/openstates
USER openstates:openstates

RUN poetry install

# uwsgi config
ENV UWSGI_HTTP=:8000 UWSGI_MASTER=1 UWSGI_HTTP_AUTO_CHUNKED=1 UWSGI_HTTP_KEEPALIVE=1 UWSGI_LAZY_APPS=1 UWSGI_WSGI_ENV_BEHAVIOR=holy
ENV UWSGI_MODULE=openstates.wsgi:application 
ENV UWSGI_PLUGIN=python37
ENV UWSGI_SOCKET=127.0.0.1:9999

ENTRYPOINT ["custom-entrypoint"]
CMD ["uwsgi", "--show-config"]
