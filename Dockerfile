ARG python_version=3.8

FROM python:${python_version}-slim

LABEL maintainer="kleinoeder@time4oss.de"
LABEL vendor="time4oss"
LABEL version="20231021"

ENV \
  DEBIAN_FRONTEND=noninteractive \
  # python:
  PYTHONFAULTHANDLER=1 \
  PYTHONUNBUFFERED=1 \
  PYTHONHASHSEED=random \
  PYTHONDONTWRITEBYTECODE=1 \
  # tini:
  TINI_VERSION=v0.19.0 \
  # PATH \
  PATH=/app/.venv/bin:$PATH \
  # PYTHONPATH \
  PYTHONPATH=/app \
  # POETRY \
  POETRY_VIRTUALENVS_CREATE=true \
  POETRY_VIRTUALENVS_IN_PROJECT=true

RUN set -eux \
  && apt-get update && apt-get upgrade -y \
  && apt-get install --no-install-recommends -y \
    tini git \
  && pip install -U pip ; pip install poetry; pip install pipenv \
  && pip install git+https://github.com/thmsklndr/iot-utils.git@main#egg=iot_utils \
  && apt-get purge -y \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false git \
  && apt-get clean -y && rm -rf /var/lib/apt/lists/* 

ENTRYPOINT ["/usr/bin/tini", "--" ]

CMD python

WORKDIR /app
