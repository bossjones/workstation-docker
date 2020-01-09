FROM golang:1.13.5-alpine

# 1.13.5-alpine3.11, 1.13-alpine3.11, 1-alpine3.11, alpine3.11, 1.13.5-alpine, 1.13-alpine, 1-alpine, alpine

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
    bash \
    binutils \
    bzip2-dev \
    ca-certificates \
    coreutils \
    dpkg-dev \
    dpkg \
    expat-dev \
    expat \
    fontconfig-dev \
    fontconfig \
    freetype-dev \
    freetype \
    gcc \
    gdbm-dev \
    gdbm \
    git \
    gmp \
    inputproto \
    isl \
    kbproto \
    libacl \
    libatomic \
    libattr \
    libbsd \
    libbz2 \
    libc-dev \
    libcap \
    libcurl \
    libffi-dev \
    libffi \
    libgcc \
    libgomp \
    libhistory \
    libpng-dev \
    libpng \
    libpthread-stubs \
    libressl-dev \
    # libressl2.7-libtls \
    libressl \
    libssh2 \
    libstdc++ \
    libx11-dev \
    libx11 \
    libxau-dev \
    libxau \
    libxcb-dev \
    libxcb \
    libxdmcp-dev \
    libxdmcp \
    libxft-dev \
    libxft \
    libxrender-dev \
    libxrender \
    linux-headers \
    make \
    mpc1 \
    # mpfr3 \
    musl-dev \
    ncurses-dev \
    ncurses-libs \
    ncurses-terminfo-base \
    ncurses-terminfo \
    patch \
    pax-utils \
    pcre2 \
    perl \
    pkgconf \
    readline-dev \
    readline \
    renderproto \
    sqlite-dev \
    sqlite-libs \
    tcl-dev \
    tcl \
    tk-dev \
    tk \
    xcb-proto \
    xextproto \
    xproto \
    xtrans \
    xz-dev \
    xz-libs \
    xz \
    zlib-dev

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

RUN curl -fsSL https://github.com/Schniz/fnm/raw/master/.ci/install.sh | zsh

ARG HOME="/root"
ARG PROFILE="$HOME/.profile"
ARG PYENV_COMMIT="0aeeb6fdcbdd01dea879703ca628a5a08bcb0a84"
ARG PYENV_ROOT="$HOME/pyenv"

# https://github.com/pyenv/pyenv#basic-github-checkout
# The git option '--shallow-submodules' is not supported in this version.
RUN git clone --recursive --shallow-submodules \
        https://github.com/pyenv/pyenv.git \
        $PYENV_ROOT

# Enforce configured commit.
RUN cd $PYENV_ROOT && \
    git reset --hard $PYENV_COMMIT && \
    cd $HOME

# Convenient environment when ssh-ing into the container.
RUN echo "export PYENV_ROOT=$PYENV_ROOT" >> $PROFILE
RUN echo 'export PATH=$PYENV_ROOT/bin:$PATH' >> $PROFILE
RUN echo 'eval "$(pyenv init -)"' >> $PROFILE

# ENTRYPOINT ["/bin/bash", "--login", "-i", "-c"]
# CMD ["bash"]

ARG RPI_BUILD=false
ENV RPI_BUILD ${RPI_BUILD}

RUN if [ "${RPI_BUILD}" = "false" ]; then \
    curl -L 'https://github.com/heppu/gkill/releases/download/v1.0.2/gkill-linux-amd64' > /usr/local/bin/gkill; \
    chmod +x /usr/local/bin/gkill; \
    curl -L 'https://github.com/rgburke/grv/releases/download/v0.3.2/grv_v0.3.2_linux64' > /usr/local/bin/grv; \
    chmod +x /usr/local/bin/grv; \
    else \
        echo "skipping all adm builds ..."; \
    fi

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
  && export PIP_NO_CACHE_DIR=off \
  && export PIP_DISABLE_PIP_VERSION_CHECK=on \
  && pip3 install --upgrade pip wheel \
  && pip3 install capstone unicorn keystone-engine ropper retdec-python \
  && echo "===> Adding gef user..." \
  && useradd -ms /bin/bash gef \
  && echo "===> Install GEF..." \
  && wget --progress=bar:force -O /home/gef/.gdbinit-gef.py https://github.com/hugsy/gef/raw/master/gef.py \
  && chmod o+r /home/gef/.gdbinit-gef.py \
  && echo "===> Clean up unnecessary files..."

RUN ln -sf /usr/bin/clang /usr/bin/cc
RUN ln -sf /usr/bin/clang++ /usr/bin/c++

RUN update-alternatives --install /usr/bin/cc cc /usr/bin/clang 10
RUN update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++ 10
RUN update-alternatives --install /usr/bin/ld ld /usr/bin/lld 10

RUN update-alternatives --auto cc
RUN update-alternatives --auto c++
RUN update-alternatives --auto ld

RUN update-alternatives --display cc
RUN update-alternatives --display c++
RUN update-alternatives --display ld

RUN ls -l /usr/bin/cc /usr/bin/c++

RUN cc --version
RUN c++ --version

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
