# ============================================================
#  Bernese GNSS Software Dockerfile - Installed Runtime Image
# ============================================================
#
#  Project : Bernese GNSS Software Container Environment
#  Version : 5.4
#  Target  : Fully installed Bernese 5.4 runtime/build image
#            with Qt4, Fortran, Perl, RNXCMP, X11 forwarding
#            and optional external campaign/data folders.
#
#  Maintainer : Ángel Vera Herrera <avera@roa.es>
#
#  Output Image:
#    - NAME: bernese54-runtime
#
#  Notes:
#    - Based on Ubuntu 18.04 for native Qt4 compatibility.
#    - Bernese is installed inside the image.
#    - Do NOT bind-mount /home/bernese/BERN54 in normal use.
#    - For first validation, run without any bind mounts.
#
# ============================================================

FROM ubuntu:18.04 AS runtime

LABEL IMAGE_NAME="bernese54-runtime" \
      MAINTAINER="Ángel Vera Herrera <avera@roa.es>" \
      VERSION="5.4" \
      DESCRIPTION="Bernese GNSS Software 5.4 installed runtime in Ubuntu 18.04"

# ------------------------------------------------------------
# Build arguments
# ------------------------------------------------------------

ARG HTTP_PROXY=""
ARG HTTPS_PROXY=""
ARG NO_PROXY=""

ARG USERNAME=bernese
ARG USER_UID=1000
ARG USER_GID=1000

ARG RNXCMP_URL="https://terras.gsi.go.jp/ja/crx2rnx/RNXCMP_4.2.0_Linux_gcc_64bit.tar.gz"

# ------------------------------------------------------------
# Base environment
# ------------------------------------------------------------

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

ENV http_proxy=${HTTP_PROXY}
ENV https_proxy=${HTTPS_PROXY}
ENV no_proxy=${NO_PROXY}

RUN if [ -n "$http_proxy" ]; then \
      echo "Acquire::http::Proxy \"$http_proxy\";" > /etc/apt/apt.conf.d/01proxy; \
    fi

# ------------------------------------------------------------
# System, compiler, Perl, Qt4 and X11 dependencies
# ------------------------------------------------------------

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    software-properties-common \
    gnupg \
    gpg-agent \
    dirmngr \
    tzdata \
    locales \
    sudo \
    bash \
    csh \
    tcsh \
    expect \
    procps \
    file \
    less \
    vim \
    nano \
    gcc \
    g++ \
    gfortran \
    make \
    binutils \
    tar \
    gzip \
    bzip2 \
    p7zip-full \
    xz-utils \
    unzip \
    zip \
    wget \
    curl \
    rsync \
    perl \
    perl-doc \
    libperl-dev \
    libdatetime-perl \
    libjson-perl \
    libxml-simple-perl \
    libtest-simple-perl \
    zlib1g \
    zlib1g-dev \
    libz-dev \
    libqt4-dev \
    libqt4-dev-bin \
    libqt4-qt3support \
    qt4-qmake \
    qt4-dev-tools \
    libqtwebkit4 \
    libx11-6 \
    libx11-dev \
    libxext6 \
    libxext-dev \
    libxrender1 \
    libxrender-dev \
    libxtst6 \
    libxtst-dev \
    libxi6 \
    libxi-dev \
    libxrandr2 \
    libxrandr-dev \
    libxinerama1 \
    libxinerama-dev \
    libxcursor1 \
    libxcursor-dev \
    libxfixes3 \
    libxfixes-dev \
    libxft2 \
    libxft-dev \
    libsm6 \
    libice6 \
    libfontconfig1 \
    libfontconfig1-dev \
    libfreetype6 \
    libfreetype6-dev \
    x11-apps \
 && locale-gen en_US.UTF-8 \
 && ln -snf /usr/share/zoneinfo/UTC /etc/localtime \
 && echo "UTC" > /etc/timezone \
 && ln -sf /bin/bash /bin/sh \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# Hatanaka RINEX compression/decompression tools
# ------------------------------------------------------------

USER root

RUN set -eux; \
    mkdir -p /tmp/rnxcmp; \
    wget -O /tmp/rnxcmp/rnxcmp.tar.gz "${RNXCMP_URL}"; \
    tar -xzf /tmp/rnxcmp/rnxcmp.tar.gz -C /tmp/rnxcmp; \
    CRX2RNX_BIN="$(find /tmp/rnxcmp -type f -iname 'CRX2RNX' | head -n 1)"; \
    RNX2CRX_BIN="$(find /tmp/rnxcmp -type f -iname 'RNX2CRX' | head -n 1)"; \
    test -n "${CRX2RNX_BIN}"; \
    test -n "${RNX2CRX_BIN}"; \
    cp "${CRX2RNX_BIN}" /usr/local/bin/CRX2RNX; \
    cp "${RNX2CRX_BIN}" /usr/local/bin/RNX2CRX; \
    chmod +x /usr/local/bin/CRX2RNX /usr/local/bin/RNX2CRX; \
    ln -sf /usr/local/bin/CRX2RNX /usr/local/bin/crx2rnx; \
    ln -sf /usr/local/bin/RNX2CRX /usr/local/bin/rnx2crx; \
    /usr/local/bin/CRX2RNX 2>&1 | head -20 || true; \
    /usr/local/bin/RNX2CRX 2>&1 | head -20 || true; \
    rm -rf /tmp/rnxcmp

# ------------------------------------------------------------
# User creation
# ------------------------------------------------------------

RUN groupadd --gid ${USER_GID} ${USERNAME} \
 && useradd --uid ${USER_UID} --gid ${USER_GID} -ms /bin/bash ${USERNAME} \
 && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
 && chmod 0440 /etc/sudoers.d/${USERNAME}

# ------------------------------------------------------------
# Bernese base directories
# ------------------------------------------------------------
#
# Important:
#   Do NOT create /home/bernese/BERN54 here.
#   setup.sh must create it during installation.
#

USER ${USERNAME}
WORKDIR /home/${USERNAME}

RUN mkdir -p \
    /home/${USERNAME}/GPSUSER54 \
    /home/${USERNAME}/GPSWORK \
    /home/${USERNAME}/GPSDATA/CAMPAIGN54 \
    /home/${USERNAME}/GPSDATA/DATAPOOL \
    /home/${USERNAME}/GPSDATA/SAVEDISK \
    /home/${USERNAME}/INST

# ------------------------------------------------------------
# Environment setup
# ------------------------------------------------------------

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV USER=${USERNAME}

ENV QTDIR=/usr/share/qt4
ENV QTBERN=/usr/share/qt4
ENV QMAKESPEC=/usr/share/qt4/mkspecs/linux-g++

ENV C=/home/${USERNAME}/BERN54
ENV U=/home/${USERNAME}/GPSUSER54
ENV T=/home/${USERNAME}/GPSWORK
ENV P=/home/${USERNAME}/GPSDATA/CAMPAIGN54
ENV D=/home/${USERNAME}/GPSDATA/DATAPOOL
ENV S=/home/${USERNAME}/GPSDATA/SAVEDISK
ENV INST=/home/${USERNAME}/INST

ENV PATH=${QTDIR}/bin:${C}/PGM:${C}/SCRIPT:${PATH}

# ------------------------------------------------------------
# Bernese shell profile
# ------------------------------------------------------------

RUN cat <<'EOF' > /home/${USERNAME}/.bernese_profile
# ============================================================
#  Bernese GNSS Software 5.4 Environment
# ============================================================

export QTDIR=/usr/share/qt4
export QTBERN=/usr/share/qt4
export QMAKESPEC=/usr/share/qt4/mkspecs/linux-g++

export C=$HOME/BERN54
export U=$HOME/GPSUSER54
export T=$HOME/GPSWORK
export P=$HOME/GPSDATA/CAMPAIGN54
export D=$HOME/GPSDATA/DATAPOOL
export S=$HOME/GPSDATA/SAVEDISK
export INST=$HOME/INST

export PATH=$QTDIR/bin:$C/PGM:$C/SCRIPT:$PATH

if [ -f "$C/LOADGPS.setvar" ]; then
    . "$C/LOADGPS.setvar"
fi
EOF

RUN echo '' >> /home/${USERNAME}/.profile \
 && echo '# Load Bernese GNSS Software environment' >> /home/${USERNAME}/.profile \
 && echo '[ -f "$HOME/.bernese_profile" ] && . "$HOME/.bernese_profile"' >> /home/${USERNAME}/.profile

# ------------------------------------------------------------
# Bernese installer bundle
# ------------------------------------------------------------
#
# Expected files in Docker build context:
#   Bernese54/BSW54Unx_2023-10-16.tar.gz
#   Bernese54/LICENSE_full.TXT
#   prepare_bernese.exp
#   install_bernese.sh
#

USER root

COPY Bernese54/BSW54Unx_2023-10-16.iso /tmp/BSW54Unx_2023-10-16.iso

RUN set -eux; \
    mkdir -p /home/${USERNAME}/INST; \
    7z x /tmp/BSW54Unx_2023-10-16.iso -o/home/${USERNAME}/INST; \
    rm -f /tmp/BSW54Unx_2023-10-16.iso; \
    echo "===== Extracted ISO tree ====="; \
    find /home/${USERNAME}/INST -maxdepth 3 -type f | sort; \
    test -f /home/${USERNAME}/INST/setup.sh; \
    test -f /home/${USERNAME}/INST/BERN54.tgz; \
    test -f /home/${USERNAME}/INST/CAMPAIGN54.tgz; \
    test -f /home/${USERNAME}/INST/DATAPOOL.tgz; \
    test -f /home/${USERNAME}/INST/SAVEDISK.tgz; \
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/INST; \
    chmod -R u+rwX,g+rwX /home/${USERNAME}/INST

# ------------------------------------------------------------
# Bernese license file
# ------------------------------------------------------------

RUN mkdir -p /opt/bernese-license \
 && chown -R ${USERNAME}:${USERNAME} /opt/bernese-license

COPY --chown=${USERNAME}:${USERNAME} Bernese54/LICENSE_full.TXT /opt/bernese-license/LICENSE.TXT

# ------------------------------------------------------------
# Bernese automated installation scripts
# ------------------------------------------------------------

COPY --chown=${USERNAME}:${USERNAME} prepare_bernese.exp /home/${USERNAME}/prepare_bernese.exp
COPY --chown=${USERNAME}:${USERNAME} install_bernese.sh /home/${USERNAME}/install_bernese.sh

RUN chmod +x /home/${USERNAME}/prepare_bernese.exp \
 && chmod +x /home/${USERNAME}/install_bernese.sh

USER ${USERNAME}
WORKDIR /home/${USERNAME}

# ------------------------------------------------------------
# Bernese automated installation
# ------------------------------------------------------------
#
# Phase 1:
#   setup.sh + LOADGPS.setvar generation.
#
# Phase 2:
#   license copy, menu compilation, program compilation,
#   example campaign installation and license registration.
#

RUN /home/${USERNAME}/prepare_bernese.exp
RUN /home/${USERNAME}/install_bernese.sh

# ------------------------------------------------------------
# Cleanup installer artifacts
# ------------------------------------------------------------

USER root

RUN rm -rf /home/${USERNAME}/INST \
 && rm -f /home/${USERNAME}/prepare_bernese.exp \
 && rm -f /home/${USERNAME}/install_bernese.sh \
 && find /home/${USERNAME}/BERN54 -type f \( \
        -name "*.o" -o \
        -name "*.mod" -o \
        -name "*.tmp" -o \
        -name "*~" \
    \) -delete \
 && rm -rf /tmp/* /var/tmp/*

USER ${USERNAME}

# ------------------------------------------------------------
# Entrypoint
# ------------------------------------------------------------

COPY --chown=${USERNAME}:${USERNAME} entrypoint.sh /home/${USERNAME}/entrypoint.sh
RUN chmod +x /home/${USERNAME}/entrypoint.sh

ENTRYPOINT ["/home/bernese/entrypoint.sh"]
CMD ["/bin/bash"]

# ------------------------------------------------------------
# END DOCKERFILE
# ------------------------------------------------------------