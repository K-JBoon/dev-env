FROM ubuntu:20.04

ARG UNAME=epixors
ARG UID=1000
ARG GID=1000

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV TZ=Europe/Amsterdam
ENV NODE_VERSION=16.15.0
ENV TERM xterm-256color

EXPOSE 1234 8000 4200 8080 3306 6379 8983

RUN apt-get update
RUN apt-get install -qq -y software-properties-common
RUN add-apt-repository universe
RUN apt-get update
RUN apt-get -qq -y upgrade
RUN apt-get install -y \
	autoconf \
	automake \
	ca-certificates \
	cmake \
	colordiff \
	curl \
	fzf \
	g++ \
	gettext \
	git \
	gnupg \
	jq \
	libtool \
	libtool-bin \
	lsb-release \
	ninja-build \
	pkg-config \
	python3 \
	python3-pip \
	ripgrep \
	silversearcher-ag \
	software-properties-common \
	tmux \
	tzdata \
	unzip \
	xclip \
	zip

# Create a non-root user to run as
RUN groupadd -g $GID -o $UNAME
RUN useradd -m -u $UID -g $GID -o -s /bin/bash $UNAME

# Set up directory for mounts
RUN mkdir -p /home/$UNAME/workspace/
WORKDIR /home/$UNAME/workspace

# Setup NodeJS
ENV NVM_DIR=/opt/nvm
RUN mkdir -p "$NVM_DIR"
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="$NVM_DIR/versions/node/v${NODE_VERSION}/bin/:${PATH}"

RUN groupadd nvm
RUN usermod -aG nvm $UNAME
RUN chown -R $UID:$GID /opt/nvm

# Setup Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Set up shell prompt
RUN curl -sS https://starship.rs/install.sh | sh -s -- --yes

# Setup Nvim
RUN mkdir -p /root/TMP
RUN cd /root/TMP && git clone https://github.com/neovim/neovim
RUN cd /root/TMP/neovim && git checkout stable && make -j4 && make install
RUN rm -rf /root/TMP
RUN mkdir -p "/home/$UNAME/.config/"
RUN git clone https://github.com/CosmicNvim/CosmicNvim "/home/$UNAME/.config/nvim"
COPY ./COSMIC_NVIM_CONFIG/ "/home/$UNAME/.config/nvim/lua/cosmic/config/"

# Setup Docker
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
RUN echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update
RUN apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Non-root user stuff
RUN chown -R $UID:$GID /home/$UNAME/
USER $UNAME

# Set up home directory configs
COPY ./HOME_CONFIG/ /home/$UNAME/

# Neovim dependencies/support
RUN pip3 install pynvim
RUN npm i -g neovim
RUN npm install -g eslint_d

# Keep container alive
CMD ["tail", "-f", "/dev/null"]
