FROM ubuntu:24.04

# system specification arguments
ARG DEBIAN_FRONTEND="noninteractive"
ARG SYS_ARCH="x86_64"
ARG SYS_OS="linux"
ARG LOCALE_LANG="en_US.UTF-8"

# non-root user arguments
ARG NON_ROOT_USER="coder"
ARG NON_ROOT_UID="2222"
ARG NON_ROOT_GID="2222"
ARG HOME_DIR="/home/${NON_ROOT_USER}"
ARG CONDA_HOME="/miniconda3"

# version arguments
ARG CODE_VER="4.89.1"
ARG CONDA_VER="py312_24.4.0-0"

RUN apt-get -qqq update \
	&& apt-get install -y -qqq --no-install-recommends \
	git \
	nano \
	vim \
	curl \
	wget \
	mtr-tiny \
	tmux \
	unzip \
	procps \
	locales \
	man \ 
	lsb-release \
	apt-transport-https \
	ca-certificates \
	gnupg \
	sudo \
	openssh-server

# Manually set Locale to $LOCALE_LANG
RUN sed -i "s/# ${LOCALE_LANG}/${LOCALE_LANG}/" /etc/locale.gen \
	&& locale-gen
ENV LANG=${LOCALE_LANG}

# Update keyrings and install kubectl, gcloud 
RUN mkdir -m 0755 -p /etc/apt/keyrings \
	&& echo 'deb [signed-by=/usr/share/keyrings/cloud.google.asc] https://packages.cloud.google.com/apt cloud-sdk main' \
	| tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
	&& curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
	| tee /usr/share/keyrings/cloud.google.asc \
	&& apt-get -qqq update \
	&& apt-get install -y -qqq --no-install-recommends kubectl google-cloud-cli \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# Create a non-root user and a custom miniconda directory
RUN echo "auth requisite pam_deny.so" >> /etc/pam.d/su \
	&& useradd -l -m -s /bin/bash -u ${NON_ROOT_UID} ${NON_ROOT_USER} \
	&& mkdir -p ${CONDA_HOME} \
	&& chown -R ${NON_ROOT_UID}:${NON_ROOT_GID} ${CONDA_HOME} \
	&& echo "${NON_ROOT_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd \
	&& chmod g+w /etc/passwd

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-${SYS_OS}-${SYS_ARCH}.zip" \
	-o "awscliv2.zip" \
	&& unzip awscliv2.zip \
	&& ./aws/install \
	&& rm -r awscliv2.zip aws

# Install code-server
ARG CODE_BIN="code-server_${CODE_VER}_amd64.deb"
RUN curl -fsOL "https://github.com/coder/code-server/releases/download/v${CODE_VER}/${CODE_BIN}" \
	&& dpkg -i "${CODE_BIN}" \
	&& rm "${CODE_BIN}"

# Miniconda arguments
ARG MINICONDA_SH="Miniconda3-${CONDA_VER}-Linux-${SYS_ARCH}.sh"

RUN curl -fO "https://repo.anaconda.com/miniconda/${MINICONDA_SH}" \
	&& chmod +x ${MINICONDA_SH} \
	&& bash ./${MINICONDA_SH} -u -b -p ${CONDA_HOME} \
	&& rm ${MINICONDA_SH}

USER ${NON_ROOT_USER}
WORKDIR ${HOME_DIR}

RUN ${CONDA_HOME}/bin/conda init bash
ENV PATH ${CONDA_HOME}/bin:${HOME_DIR}/.local/bin:${PATH}

EXPOSE 8080
ENTRYPOINT ["/usr/bin/code-server"]
CMD ["--disable-telemetry", "--bind-addr=0.0.0.0:8080", "."]

