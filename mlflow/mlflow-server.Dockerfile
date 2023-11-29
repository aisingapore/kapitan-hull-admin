FROM python:3.10-slim-bullseye

LABEL version='1.0'
LABEL decription='MLflow Server with basic auth and aws/gcp artefact storage'
LABEL author='Deon Chia'

ARG USER=nonroot
ARG DEBIAN_FRONTEND=noninteractive
ARG EN_UTF="en_US.UTF-8"
ARG MLFLOW_VER

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
RUN adduser --gecos '' -u 1005 --disabled-password $USER

USER $USER
WORKDIR /home/$USER

RUN pip3 -qq install mlflow==$MLFLOW_VER google-cloud-storage boto3
ENV PATH="/home/$USER/.local/bin:$PATH"

RUN mkdir scripts/
COPY --chown=nonroot:nonroot --chmod=0744 entrypoint.sh scripts/

ENTRYPOINT [ "./scripts/entrypoint.sh" ]
CMD [ "--port 5005" ]
EXPOSE 5005

