FROM golang:1.13.5-alpine

# 1.13.5-alpine3.11, 1.13-alpine3.11, 1-alpine3.11, alpine3.11, 1.13.5-alpine, 1.13-alpine, 1-alpine, alpine

# https://wiki.alpinelinux.org/wiki/How_to_get_regular_stuff_working
# https://wiki.musl-libc.org/functional-differences-from-glibc.html

LABEL maintainer "https://github.com/bossjones"

RUN apk add --no-cache ca-certificates git python3 ctags tzdata bash neovim neovim-doc

######################
### SETUP ZSH/TMUX ###
######################

RUN apk add --no-cache zsh tmux && rm -rf /tmp/*

RUN git clone git://github.com/robbyrussell/oh-my-zsh.git /root/.oh-my-zsh
RUN git clone https://github.com/tmux-plugins/tpm /root/.tmux/plugins/tpm
RUN git clone https://github.com/tmux-plugins/tmux-cpu /root/.tmux/plugins/tmux-cpu
RUN git clone https://github.com/tmux-plugins/tmux-prefix-highlight /root/.tmux/plugins/tmux-prefix-highlight

COPY tmux.conf /root/.tmux.conf
COPY tmux.linux.conf /root/.tmux.linux.conf

####################
### SETUP NEOVIM ###
####################

# Install vim plugin manager
RUN apk add --no-cache curl \
  && curl -fLo /root/.local/share/nvim/site/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim \
  && rm -rf /tmp/* \
  && apk del --purge curl

# Install vim plugins
RUN apk add --no-cache -t .build-deps build-base python3-dev \
  && pip3 install -U neovim \
  && rm -rf /tmp/* \
  && apk del --purge .build-deps

RUN mkdir -p /root/.config/nvim
COPY vimrc /root/.config/nvim/init.vim
RUN ln -s /root/.config/nvim/init.vim /root/.vimrc

COPY nvim/snippets /root/.config/nvim/snippets
COPY nvim/spell /root/.config/nvim/spell

# https://github.com/pyenv/pyenv/wiki/Common-build-problems
RUN apk add --no-cache \
    # libressl2.7-libtls \
    # mpfr3 \
    build-base \
    gcc \
    abuild \
    binutils \
    binutils-doc \
    gcc-doc \
    cmake \
    cmake-doc \
    extra-cmake-modules \
    extra-cmake-modules-doc \
    ccache \
    ccache-doc \
    bash \
    bash-completion \
    bash-doc \
    binutils \
    bzip2-dev \
    ca-certificates \
    coreutils \
    dpkg \
    dpkg-dev \
    expat \
    expat-dev \
    findutils \
    fontconfig \
    fontconfig-dev \
    freetype \
    freetype-dev \
    gcc \
    gdbm \
    gdbm-dev \
    git \
    gmp \
    grep \
    inputproto \
    isl \
    kbproto \
    less \
    less-doc \
    libacl \
    libatomic \
    libattr \
    libbsd \
    libbz2 \
    libc-dev \
    libcap \
    libcurl \
    libffi \
    libffi-dev \
    libgcc \
    libgomp \
    libhistory \
    libpng \
    libpng-dev \
    libpthread-stubs \
    libressl \
    libressl-dev \
    libssh2 \
    libstdc++ \
    libx11 \
    libx11-dev \
    libxau \
    libxau-dev \
    libxcb \
    libxcb-dev \
    libxdmcp \
    libxdmcp-dev \
    libxft \
    libxft-dev \
    libxrender \
    libxrender-dev \
    linux-headers \
    linux-pam \
    make \
    man \
    man-pages \
    mdocml-apropos \
    mpc1 \
    musl-dev \
    ncurses-dev \
    ncurses-libs \
    ncurses-terminfo \
    ncurses-terminfo-base \
    patch \
    pax-utils \
    pciutils \
    pcre2 \
    perl \
    pkgconf \
    readline \
    readline-dev \
    renderproto \
    shadow \
    sqlite-dev \
    sqlite-libs \
    sudo \
    tcl \
    tcl-dev \
    tk \
    tk-dev \
    tree \
    usbutils \
    util-linux \
    xcb-proto \
    xextproto \
    xproto \
    xtrans \
    xz \
    xz-dev \
    xz-libs \
    mkfontdir \
    terminus-font \
    zlib-dev

# Install https://github.com/sgerrand/alpine-pkg-glibc
RUN apk --no-cache add ca-certificates wget && \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.30-r0/glibc-2.30-r0.apk && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.30-r0/glibc-bin-2.30-r0.apk && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.30-r0/glibc-dev-2.30-r0.apk && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.30-r0/glibc-i18n-2.30-r0.apk && \
    apk add glibc-2.30-r0.apk glibc-bin-2.30-r0.apk glibc-dev-2.30-r0.apk glibc-i18n-2.30-r0.apk

# Go get popular golang libs
RUN echo "===> go get popular golang libs..." \
  && go get -u github.com/go-delve/delve/cmd/dlv \
  && go get -u github.com/sirupsen/logrus \
  && go get -u github.com/spf13/cobra/cobra \
  && go get -u github.com/golang/dep/cmd/dep \
  && go get -u github.com/fatih/structs \
  && go get -u github.com/gorilla/mux \
  && go get -u github.com/gorilla/handlers \
  && go get -u github.com/parnurzeal/gorequest \
  && go get -u github.com/urfave/cli \
  && go get -u github.com/apex/log/...
# Go get vim-go binaries
RUN echo "===> get vim-go binaries..." \
  && go get -u -v github.com/klauspost/asmfmt/cmd/asmfmt \
  && go get -u -v github.com/kisielk/errcheck \
  && go get -u -v github.com/davidrjenni/reftools/cmd/fillstruct \
  && go get -u -v github.com/stamblerre/gocode \
  && go get -u -v github.com/rogpeppe/godef \
  && go get -u -v github.com/zmb3/gogetdoc \
  && go get -u -v golang.org/x/tools/cmd/goimports \
  && go get -u -v golang.org/x/lint/golint \
  && GO111MODULE=on go get -v golang.org/x/tools/gopls@latest \
  && go get -u -v github.com/alecthomas/gometalinter \
  && go get -u -v github.com/golangci/golangci-lint/cmd/golangci-lint \
  && go get -u -v github.com/fatih/gomodifytags \
  && go get -u -v golang.org/x/tools/cmd/gorename \
  && go get -u -v github.com/jstemmer/gotags \
  && go get -u -v golang.org/x/tools/cmd/guru \
  && go get -u -v github.com/josharian/impl \
  && go get -u -v honnef.co/go/tools/cmd/keyify \
  && go get -u -v github.com/fatih/motion \
  && go get -u -v github.com/koron/iferr

# Get powerline font just in case (to be installed on the docker host)
RUN apk add --no-cache wget \
  && mkdir /root/powerline \
  && cd /root/powerline \
  && wget https://github.com/powerline/fonts/raw/master/Meslo%20Slashed/Meslo%20LG%20M%20Regular%20for%20Powerline.ttf \
  && rm -rf /tmp/* \
  && apk del --purge wget

ENV TERM=screen-256color
# Setup Language Environtment
ENV LANG="C.UTF-8"
ENV LC_COLLATE="C.UTF-8"
ENV LC_CTYPE="C.UTF-8"
ENV LC_MESSAGES="C.UTF-8"
ENV LC_MONETARY="C.UTF-8"
ENV LC_NUMERIC="C.UTF-8"
ENV LC_TIME="C.UTF-8"


# shell-init: error retrieving current directory: getcwd: cannot access parent directories: Permission denied
# internal/process/main_thread_only.js:42
#     cachedCwd = binding.cwd();
#                         ^

# Error: EACCES: permission denied, uv_cwd
#     at process.cwd (internal/process/main_thread_only.js:42:25)
#     at Object.resolve (path.js:976:47)
#     at patchProcessObject (internal/bootstrap/pre_execution.js:73:28)
#     at prepareMainThreadExecution (internal/bootstrap/pre_execution.js:10:3)
#     at internal/main/run_main_module.js:7:1 {
#   errno: -13,
#   code: 'EACCES',
#   syscall: 'uv_cwd'
# }

# HOTFIX: https://github.com/embark-framework/embark/issues/1677
RUN apk add --no-cache --update nodejs npm xclip acl && rm -rf /tmp/* \
    && setfacl -dR -m u:root:rwX /usr/lib/node_modules \
    && setfacl -R -m u:root:rwX /usr/lib/node_modules \
    && setfacl -dR -m u:root:rwX /usr/local/bin/ \
    && setfacl -R -m u:root:rwX /usr/local/bin \
    && npm config set user 0 \
    && npm config set unsafe-perm true \
    && npm install --global pure-prompt

RUN git clone https://github.com/zsh-users/antigen.git /root/.antigen/antigen

# COPY zshrc.pure /root/.zshrc.pure
COPY zshrc.pure /root/.zshrc
# COPY zshrc /root/.zshrc

RUN apk --no-cache add fontconfig && rm -rf /tmp/*

# RUN mkdir -p $HOME/.fonts $HOME/.config/fontconfig/conf.d \
#   && wget -P $HOME/.fonts https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf \
#   && wget -P $HOME/.config/fontconfig/conf.d/ https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf \
#   && fc-cache -vf $HOME/.fonts/

# SOURCE: https://github.com/veggiemonk/ansible-dotfiles/blob/master/tasks/fonts.yml
RUN git clone https://github.com/powerline/fonts ~/powerlinefonts && \
  cd ~/powerlinefonts; ~/powerlinefonts/install.sh \
  && fc-cache -f

COPY bin/ /entrypoints

RUN /entrypoints/install-fonts

# DISABLED: # ARG HOME="/root"
# DISABLED: # ARG PROFILE="$HOME/.profile"
# DISABLED: # ARG PYENV_COMMIT="0aeeb6fdcbdd01dea879703ca628a5a08bcb0a84"
# DISABLED: # ARG PYENV_ROOT="$HOME/.pyenv"
# DISABLED: #
# DISABLED: # # https://github.com/pyenv/pyenv#basic-github-checkout
# DISABLED: # # The git option '--shallow-submodules' is not supported in this version.
# DISABLED: # RUN git clone --recursive --shallow-submodules \
# DISABLED: #         https://github.com/pyenv/pyenv.git \
# DISABLED: #         $PYENV_ROOT
# DISABLED: #
# DISABLED: # # Enforce configured commit.
# DISABLED: # RUN cd $PYENV_ROOT && \
# DISABLED: #     git reset --hard $PYENV_COMMIT && \
# DISABLED: #     cd $HOME
# DISABLED: #
# DISABLED: # # Convenient environment when ssh-ing into the container.
# DISABLED: # RUN echo "export PYENV_ROOT=$PYENV_ROOT" >> $PROFILE
# DISABLED: # RUN echo 'export PATH=$PYENV_ROOT/bin:$PATH' >> $PROFILE
# DISABLED: # RUN echo 'eval "$(pyenv init -)"' >> $PROFILE

# ENTRYPOINT ["/bin/bash", "--login", "-i", "-c"]
# CMD ["bash"]

ARG RPI_BUILD=false
ENV RPI_BUILD ${RPI_BUILD}

RUN mkdir /usr/local/src

RUN if [ "${RPI_BUILD}" = "false" ]; then \
    curl -L 'https://github.com/heppu/gkill/releases/download/v1.0.2/gkill-linux-amd64' > /usr/local/bin/gkill; \
    chmod +x /usr/local/bin/gkill; \
    curl -L 'https://github.com/rgburke/grv/releases/download/v0.3.2/grv_v0.3.2_linux64' > /usr/local/bin/grv; \
    chmod +x /usr/local/bin/grv; \
    curl --silent -L 'https://github.com/simeji/jid/releases/download/v0.7.6/jid_linux_amd64.zip' > /usr/local/src/jid.zip; \
    unzip /usr/local/src/jid.zip -d /usr/local/bin;  \
    chmod +x /usr/local/bin/jid; \
    else \
        echo "skipping all adm builds ..."; \
    fi

RUN git clone https://github.com/facebook/PathPicker.git /usr/local/src/PathPicker; cd /usr/local/src/PathPicker; ln -s "$(pwd)/fpp" /usr/local/bin/fpp; fpp --help

RUN apk add --no-cache \
  ltrace \
  strace \
  gdb \
  fd \
  autoconf \
  automake \
  clang \
  clang-dev \
  lld \
  ccache \
  python3-dev \
  boost-python3 \
  python3-dbg \
  python3 \
  python3-doc \
  python3-tests \
  ruby \
  curl \
  wget \
  file \
  && export PIP_NO_CACHE_DIR=off \
  && export PIP_DISABLE_PIP_VERSION_CHECK=on \
  && pip3 install --upgrade pip wheel
  # && pip3 install capstone unicorn keystone-engine ropper retdec-python \
  # && pip3 install capstone unicorn ropper retdec-python \
  # && echo "===> Adding gef user..." \
  # && useradd -ms /bin/bash gef \
  # && echo "===> Install GEF..." \
  # && wget --progress=bar:force -O /home/gef/.gdbinit-gef.py https://github.com/hugsy/gef/raw/master/gef.py \
  # && chmod o+r /home/gef/.gdbinit-gef.py \
  # && echo "===> Clean up unnecessary files..."

# hadolint ignore=DL3013
RUN pip3 install --upgrade \
  jsbeautifier \
  flake8 \
  mypy \
  bandit \
  pylint \
  pycodestyle \
  pydocstyle \
  ansible-lint

# RUN ln -sf /usr/bin/clang /usr/bin/cc
# RUN ln -sf /usr/bin/clang++ /usr/bin/c++

# RUN update-alternatives --install /usr/bin/cc cc /usr/bin/clang 10
# RUN update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++ 10
# RUN update-alternatives --install /usr/bin/ld ld /usr/bin/lld 10

# RUN update-alternatives --auto cc
# RUN update-alternatives --auto c++
# RUN update-alternatives --auto ld

# RUN update-alternatives --display cc
# RUN update-alternatives --display c++
# RUN update-alternatives --display ld

# RUN ls -l /usr/bin/cc /usr/bin/c++

# RUN cc --version
# RUN c++ --version

# Install nvim plugins
RUN set -x; apk add --no-cache -t .build-deps build-base python3-dev \
  && echo "===> neovim PlugInstall..." \
  && nvim -i NONE -c PlugInstall -c quitall \
  && echo "===> neovim UpdateRemotePlugins..." \
  && nvim -i NONE -c UpdateRemotePlugins -c quitall \
  && rm -rf /tmp/* \
  && apk del --purge .build-deps

# RUN git clone https://github.com/junegunn/fzf.git -b 0.18.0 ~/.fzf
RUN cd ~/.fzf; ./install --all

ENV SHELL="zsh"
RUN /bin/zsh -l -c "curl -fsSL https://github.com/Schniz/fnm/raw/master/.ci/install.sh | bash"

RUN go get -u github.com/simeji/jid/cmd/jid

ENTRYPOINT ["tmux"]

ARG BUILD_DATE
ARG VCS_REF
ARG BUILD_VERSION

# Labels.
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.name="bossjones/workstation-docker"
LABEL org.label-schema.vcs-ref=$VCS_REF
LABEL org.label-schema.vendor="TonyDark Industries"
LABEL org.label-schema.version=$BUILD_VERSION
LABEL maintainer="jarvis@theblacktonystark.com"


# ####################################
# ENV LANG C.UTF-8
# # ENV CI true
# ENV PYENV_ROOT /home/${NON_ROOT_USER}/.pyenv
# ENV PATH="${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:${PATH}"

# RUN curl -L https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer | bash && \
#     git clone --depth 1 https://github.com/pyenv/pyenv-virtualenvwrapper /home/${NON_ROOT_USER}/.pyenv/plugins/pyenv-virtualenvwrapper && \
#     git clone --depth 1 https://github.com/pyenv/pyenv-pip-rehash /home/${NON_ROOT_USER}/.pyenv/plugins/pyenv-pip-rehash && \
#     git clone --depth 1 https://github.com/pyenv/pyenv-pip-migrate /home/${NON_ROOT_USER}/.pyenv/plugins/pyenv-pip-migrate && \
#     pyenv install 3.5.2

# # ########################[EDITOR RELATED SETUP STUFF]################################

# # # Install rbenv to manage ruby versions
# RUN git clone --depth 1 https://github.com/rbenv/rbenv.git ~/.rbenv && \
#     cd ~/.rbenv && src/configure && make -C src && \
#     echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc && \
#     echo 'eval "$(rbenv init -)"' >> ~/.bashrc && \
#     git clone --depth 1 https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build


##########################################################################################

RUN GO111MODULE=on go get github.com/mikefarah/yq/v2

# container user
ARG CONTAINER_GID=501
ARG CONTAINER_UID=501
ARG CONTAINER_USER=developer

# host ip address
ARG HOST_IP

# set container user as environment variable
ENV CONTAINER_USER=${CONTAINER_USER}

RUN apk add --no-cache --update \
  bash \
  build-base \
  bzip2-dev \
  ca-certificates \
  curl \
  git \
  jq \
  linux-headers \
  ncurses-dev \
  openssl \
  openssl-dev \
  patch \
  readline-dev \
  sqlite-dev \
  tmux \
  unzip \
  vim \
  zsh \
    && \
  rm -rf /var/cache/apk/*

ENV PYENV_ROOT="/.pyenv" \
    PATH="/.pyenv/bin:/.pyenv/shims:$PATH"

RUN curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash && \
    git clone https://github.com/pyenv/pyenv-virtualenvwrapper ${PYENV_ROOT}/plugins/pyenv-virtualenvwrapper && \
    git clone https://github.com/pyenv/pyenv-pip-migrate ${PYENV_ROOT}/plugins/pyenv-pip-migrate && \
    git clone https://github.com/jawshooah/pyenv-default-packages ${PYENV_ROOT}/plugins/pyenv-default-packages

COPY default-packages ${PYENV_ROOT}/default-packages

ENV PYTHON_CONFIGURE_OPTS="--enable-shared"
ENV PYTHONDONTWRITEBYTECODE 1

# ----------------------------------------------------------------------------------------------
# https://github.com/alpinelinux/aports/pull/6980/files
# https://bugs.alpinelinux.org/issues/10209
# https://stackoverflow.com/questions/55475157/pam-authentication-failure-when-running-chpasswd-on-alpine-linux
# FIXME: `PAM: Authentication failure` when running `chpasswd` on Alpine Linux
# ----------------------------------------------------------------------------------------------
# echo "auth     sufficient pam_rootok.so" | tee /etc/pam.d/chpasswd
# echo "account  include    base-account" | tee -a /etc/pam.d/chpasswd
# echo "password include    base-password" | tee -a /etc/pam.d/chpasswd
# ----------------------------------------------------------------------------------------------

# echo "auth		include		base-auth" | tee /etc/pam.d/login && \
# echo "account		include		base-account" | tee -a /etc/pam.d/login && \
# echo "password	include		base-password" | tee -a /etc/pam.d/login && \
# echo "session		include		base-session" | tee -a /etc/pam.d/login && \

RUN apk add --no-cache --update tree shadow sudo bash linux-pam && \
    echo -e "\n\n\n" && \
    cat /etc/pam.d/chpasswd && \
    echo -e "BEFORE" && \
    echo -e "\n\n\n" && \
    ls -lta /etc/pam.d && \
    echo -e "\n\n\n" && \
    echo "auth     sufficient pam_rootok.so" > /etc/pam.d/chpasswd && \
    echo "account  include    base-account" >> /etc/pam.d/chpasswd && \
    echo "password include    base-password" >> /etc/pam.d/chpasswd && \
    echo -e "\n\n\n" && \
    echo -e "AFTER - chpasswd" && \
    cat /etc/pam.d/chpasswd && \
    echo -e "\n\n\n" && \
    echo -e "BEFORE - login" && \
    cat /etc/pam.d/login && \
    echo "auth		include		base-auth" > /etc/pam.d/login && \
    echo "account		include		base-account" >> /etc/pam.d/login && \
    echo "password	include		base-password" >> /etc/pam.d/login && \
    echo "session		include		base-session" >> /etc/pam.d/login && \
    echo -e "AFTER - login" && \
    cat /etc/pam.d/login && \
    echo -e "\n\n\n" && \
    echo -e "\n\n\n" && \
    echo -e "BEFORE - useradd" && \
    cat /etc/pam.d/useradd && \
    sed -i "s,account		required	pam_permit.so,account		include		base-account,g" /etc/pam.d/useradd && \
    sed -i "s,password	include		system-auth,password	include		base-password,g" /etc/pam.d/useradd && \
    echo -e "AFTER - useradd" && \
    cat /etc/pam.d/useradd && \
    echo -e "\n\n\n" && \
    \
    if [ -z "`getent group $CONTAINER_GID`" ]; then \
      addgroup -S -g $CONTAINER_GID $CONTAINER_USER; \
    else \
      groupmod -n $CONTAINER_USER `getent group $CONTAINER_GID | cut -d: -f1`; \
    fi && \
    if [ -z "`getent passwd $CONTAINER_UID`" ]; then \
      adduser -S -h /home/${CONTAINER_USER} -u $CONTAINER_UID -G $CONTAINER_USER -s /bin/sh $CONTAINER_USER; \
    else \
      usermod -l $CONTAINER_USER -g $CONTAINER_GID -d /home/$CONTAINER_USER -m `getent passwd $CONTAINER_UID | cut -d: -f1`; \
    fi && \
    echo "${CONTAINER_USER} ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$CONTAINER_USER && \
    chmod 0440 /etc/sudoers.d/$CONTAINER_USER && \
    mkdir /home/${CONTAINER_USER}/.ssh && \
    chmod og-rwx /home/${CONTAINER_USER}/.ssh && \
    echo 'export PATH="~/.local/bin:${PATH}"' >> /etc/profile.d/${CONTAINER_USER}.sh && \
    echo 'export PATH="/home/${CONTAINER_USER}/.local/bin:${PATH}"' >> /etc/profile.d/${CONTAINER_USER}.sh && \
    chown -R ${CONTAINER_USER}:${CONTAINER_USER} /home/${CONTAINER_USER}

# COPY vagrant_insecure_key /home/${CONTAINER_USER}
# COPY vagrant_insecure_key.pub /home/${CONTAINER_USER}
# RUN cat /home/${CONTAINER_USER}/vagrant_insecure_key > /home/${CONTAINER_USER}/.ssh/id_rsa
# RUN cat /home/${CONTAINER_USER}/vagrant_insecure_key.pub > /home/${CONTAINER_USER}/.ssh/id_rsa.pub

COPY --chown=developer:developer python-versions.txt /
RUN set -x; pyenv update && \
    xargs -P 4 -n 1 pyenv install < /python-versions.txt && \
    pyenv global $(pyenv versions --bare) && \
    find $PYENV_ROOT/versions -type d '(' -name '__pycache__' -o -name 'test' -o -name 'tests' ')' -exec rm -rfv '{}' + && \
    find $PYENV_ROOT/versions -type f '(' -name '*.py[co]' -o -name '*.exe' ')' -exec rm -fv '{}' + && \
    mv -v -- /python-versions.txt $PYENV_ROOT/version && \
    chown -R ${CONTAINER_USER}:${CONTAINER_USER} ${PYENV_ROOT}

COPY pyenv-init.sh /pyenv-init.sh

RUN find . | grep -E "(__pycache__|\.pyc|\.pyo$)" | xargs rm -rf

# SOURCE: https://hub.docker.com/r/ljishen/my-vim/dockerfile
# perl for Checkpatch (syntax checking for C)
# gcc for syntax checking of c
# g++ for syntax checking of c++
# python3-pip, python3-setuptools and python3-wheel
#    are used for installing/building python packages (e.g. jsbeautifier, flake8)
# cppcheck for syntax checking of c and c++
# exuberant-ctags for Vim plugin Tagbar (https://github.com/majutsushi/tagbar#dependencies)
# clang is for plugin Vim plugin YCM-Generator (https://github.com/rdnetto/YCM-Generator)
# clang-format is used by plugin google/vim-codefmt
# python3-dev is required to build typed-ast, which is required by jsbeautifier
# python-dev, cmake and build-essential are used for compiling YouCompleteMe(YCM)
#     with semantic support in the following command:
#     /bin/sh -c /root/.vim/bundle/YouCompleteMe/install.py
# libffi-dev and libssl-dev is required to build ansible-lint
# shellcheck for syntax checking of sh

# TODO: Search for docs/grep
# apk search nginx | grep -- -doc
