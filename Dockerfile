ARG python_version=3.10

FROM python:${python_version}-slim

LABEL maintainer="kleinoeder@time4oss.de"
LABEL vendor="time4oss"

ARG UID=""
ARG GID=""

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
  PYTHONPATH=/app

RUN set -eux \
  && apt-get update && apt-get upgrade -y \
  && apt-get install --no-install-recommends -y \
    tini git \
  && pip install -U pip ; pip install pipenv \
  && pip install git+https://github.com/thmsklndr/iot-utils.git@main#egg=iot_utils \
  && apt-get purge -y \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false git \
  && apt-get clean -y && rm -rf /var/lib/apt/lists/* 

RUN bash -c 'export _gid=$(test -z $GID && shuf -i 10000-65534 -n 1 || echo $GID) && \
             export _uid=$(test -z $UID && shuf -i 10000-65534 -n 1 || echo $UID) && \
             (groupadd time4oss -g $_gid || true) && \
             useradd -u $_uid --create-home -g $_gid time4oss'

ENTRYPOINT ["/usr/bin/tini", "--" ]

CMD python

WORKDIR /app
