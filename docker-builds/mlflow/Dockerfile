FROM python:3.12.5-slim-bookworm

LABEL version='2.15.1-python-3.12.5-gcs-2.18.2-boto-1.35.7'
LABEL decription='MLflow Server with basic auth and aws/gcp artifact storage'
LABEL author='AISG'

ARG USER=nonroot
ARG UID=1005
ARG GROUP=nonroot
ARG GID=2222
ARG DEBIAN_FRONTEND=noninteractive
ARG EN_UTF="en_US.UTF-8"

RUN apt -q update && \
    apt install -y -qq curl \
    locales \
    apt-transport-https \
    ca-certificates \
    gnupg \
    unzip && \
    rm -rf /var/lib/apt/lists/*

RUN sed -i "s/# $EN_UTF/$EN_UTF/" /etc/locale.gen \
    && locale-gen
ENV LANG=$EN_UTF
RUN groupadd -g ${GID} ${GROUP} \
    && adduser --gecos '' -u ${UID} -gid ${GID} --disabled-password ${USER}

USER ${USER}
WORKDIR /home/${USER}

ARG MLFLOW_VER="2.15.1"
ARG GCS_VER="2.18.2"
ARG BOTO_VER="1.35.7"
RUN pip3 -qq install \
    mlflow==${MLFLOW_VER} \
    google-cloud-storage==${GCS_VER} \
    boto3==${BOTO_VER}
ENV PATH="/home/$USER/.local/bin:$PATH"

RUN mkdir scripts/
COPY --chown=${USER}:${USER} --chmod=0744 entrypoint.sh scripts/

ENTRYPOINT [ "./scripts/entrypoint.sh" ]
CMD [ "--port 5005" ]
EXPOSE 5005
