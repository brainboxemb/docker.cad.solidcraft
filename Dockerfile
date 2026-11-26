ARG PYTHON_IMAGE
ARG MITCAD_IMAGE
FROM ${PYTHON_IMAGE} AS common

ARG RUNTIME_VERSION
ARG PYYAML_VERSION

LABEL org.opencontainers.image.source="https://github.com/brainboxemb/docker.cad.solidcraft"

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    CAD_RUNTIME_VERSION=${RUNTIME_VERSION}

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        libdbus-1-3 \
        libegl1 \
        libfontconfig1 \
        libglib2.0-0 \
        libgl1 \
        libice6 \
        libsm6 \
        libx11-6 \
        libx11-xcb1 \
        libxcb-cursor0 \
        libxcb-xinerama0 \
        libxcb1 \
        libxext6 \
        libxi6 \
        libxkbcommon-x11-0 \
        libxkbcommon0 \
        libxrender1 \
    && rm -rf /var/lib/apt/lists/*

RUN python -m pip install --upgrade pip setuptools wheel \
    && python -m pip install "PyYAML==${PYYAML_VERSION}"

WORKDIR /work


FROM common AS solidcraft

ARG RUNTIME_VERSION
ARG SOLIDCRAFT_VERSION
ARG PILLOW_SPEC

LABEL org.opencontainers.image.title="SolidCraft CAD runtime"
LABEL org.opencontainers.image.description="Lightweight SolidCraft model and visual verification runtime"

ENV CAD_RUNTIME_ROLE=solidcraft \
    CAD_SOLIDCRAFT_RUNTIME_VERSION=${RUNTIME_VERSION} \
    SOLIDCRAFT_VERSION=${SOLIDCRAFT_VERSION} \
    SOLIDCRAFT_GPU=cpu \
    PATH=/opt/solidcraft/bin:$PATH

RUN python -m pip install "Pillow${PILLOW_SPEC}"

RUN set -eux; \
    archive="solidcraft-${SOLIDCRAFT_VERSION}-linux-x86_64.tar.gz"; \
    base="https://github.com/tangency-labs/solidcraft/releases/download/v${SOLIDCRAFT_VERSION}"; \
    mkdir -p /opt/solidcraft /tmp/solidcraft; \
    cd /tmp/solidcraft; \
    curl --proto '=https' -fsSLO "${base}/SHA256SUMS.txt"; \
    curl --proto '=https' -fsSLO "${base}/${archive}"; \
    grep "  ${archive}$" SHA256SUMS.txt | sha256sum -c -; \
    tar -xzf "${archive}" --strip-components=1 -C /opt/solidcraft; \
    test -x /opt/solidcraft/bin/solidcraft-cli; \
    rm -rf /tmp/solidcraft

COPY scripts/cad-solidcraft-info /usr/local/bin/cad-solidcraft-info
COPY scripts/test-solidcraft-runtime.sh /usr/local/bin/test-cad-solidcraft-runtime

RUN chmod +x \
        /usr/local/bin/cad-solidcraft-info \
        /usr/local/bin/test-cad-solidcraft-runtime \
    && test-cad-solidcraft-runtime

CMD ["cad-solidcraft-info"]


FROM ${MITCAD_IMAGE} AS mitcad

ARG RUNTIME_VERSION
ARG MITCAD_VERSION
ARG MITCAD_ARCH
ARG MITCAD_APPIMAGE_SHA256

LABEL org.opencontainers.image.source="https://github.com/brainboxemb/docker.cad.solidcraft"
LABEL org.opencontainers.image.title="Mitcad CAD runtime"
LABEL org.opencontainers.image.description="Isolated Mitcad native CAD runtime for experimental consumers"

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    CAD_RUNTIME_VERSION=${RUNTIME_VERSION} \
    CAD_RUNTIME_ROLE=mitcad \
    CAD_MITCAD_RUNTIME_VERSION=${RUNTIME_VERSION} \
    MITCAD_VERSION=${MITCAD_VERSION} \
    MITCAD_ARCH=${MITCAD_ARCH} \
    APPIMAGE_EXTRACT_AND_RUN=1 \
    QT_QPA_PLATFORM=offscreen \
    PATH=/opt/mitcad/bin:$PATH

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        python3 \
        python-is-python3 \
        python3-yaml \
        libdbus-1-3 \
        libegl1 \
        libfontconfig1 \
        libfreetype6 \
        libgl1 \
        libgl1-mesa-dri \
        libglib2.0-0t64 \
        libglx-mesa0 \
        libice6 \
        libopengl0 \
        libsm6 \
        libwayland-client0 \
        libwayland-cursor0 \
        libwayland-egl1 \
        libx11-6 \
        libx11-xcb1 \
        libxcb-cursor0 \
        libxcb-icccm4 \
        libxcb-image0 \
        libxcb-keysyms1 \
        libxcb-randr0 \
        libxcb-render-util0 \
        libxcb-shape0 \
        libxcb-xinerama0 \
        libxcb-xkb1 \
        libxext6 \
        libxi6 \
        libxkbcommon-x11-0 \
        libxkbcommon0 \
        libxrender1 \
    && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    asset="Mitcad-${MITCAD_VERSION}-${MITCAD_ARCH}.AppImage"; \
    base="https://github.com/mitcad/Mitcad/releases/download/v${MITCAD_VERSION}"; \
    mkdir -p /opt/mitcad/bin /tmp/mitcad; \
    cd /tmp/mitcad; \
    curl --proto '=https' -fsSLo "${asset}" "${base}/${asset}"; \
    printf '%s  %s\n' "${MITCAD_APPIMAGE_SHA256}" "${asset}" | sha256sum -c -; \
    install -m 0755 "${asset}" /opt/mitcad/Mitcad.AppImage; \
    rm -rf /tmp/mitcad

COPY scripts/mitcad-cli /opt/mitcad/bin/mitcad-cli
COPY scripts/cad-mitcad-info /usr/local/bin/cad-mitcad-info
COPY scripts/test-mitcad-runtime.sh /usr/local/bin/test-cad-mitcad-runtime

RUN chmod +x \
        /opt/mitcad/bin/mitcad-cli \
        /usr/local/bin/cad-mitcad-info \
        /usr/local/bin/test-cad-mitcad-runtime \
    && test-cad-mitcad-runtime

CMD ["cad-mitcad-info"]


FROM common AS reference

ARG PYTHONSCAD_VERSION
ARG PYBOSL2_COMMIT
ARG CADQUERY_VERSION
ARG BUILD123D_VERSION
ARG CADCRAFT_VERSION
ARG CADCRAFT_ARCH
ARG CADCRAFT_ARCHIVE_SHA256
ARG PILLOW_SPEC
ARG TRIMESH_SPEC
ARG SCIPY_SPEC
ARG MATPLOTLIB_SPEC

LABEL org.opencontainers.image.title="CAD reference runtime"
LABEL org.opencontainers.image.description="Independent CAD reference engines for verification"

ENV CAD_RUNTIME_ROLE=reference \
    PYTHONSCAD_VERSION=${PYTHONSCAD_VERSION} \
    PYBOSL2_COMMIT=${PYBOSL2_COMMIT} \
    CADQUERY_VERSION=${CADQUERY_VERSION} \
    BUILD123D_VERSION=${BUILD123D_VERSION} \
    BUILD123D_PYTHON=/opt/build123d/bin/python \
    CADCRAFT_VERSION=${CADCRAFT_VERSION} \
    CADCRAFT_ARCH=${CADCRAFT_ARCH} \
    PATH=/opt/cadcraft/bin:$PATH \
    MPLBACKEND=Agg

RUN python -m pip install \
        "Pillow${PILLOW_SPEC}" \
        "trimesh${TRIMESH_SPEC}" \
        "scipy${SCIPY_SPEC}" \
        "matplotlib${MATPLOTLIB_SPEC}" \
    && python -m pip install \
        "pythonscad==${PYTHONSCAD_VERSION}" \
        "git+https://github.com/pinkfish/pybosl2@${PYBOSL2_COMMIT}" \
        "cadquery==${CADQUERY_VERSION}" \
    && python -m venv /opt/build123d \
    && /opt/build123d/bin/python -m pip install --upgrade pip setuptools wheel \
    && /opt/build123d/bin/python -m pip install "build123d==${BUILD123D_VERSION}"

RUN set -eux; \
    archive="cadcraft-${CADCRAFT_VERSION}-linux-${CADCRAFT_ARCH}.tar.gz"; \
    base="https://github.com/storytold/cadcraft/releases/download/v${CADCRAFT_VERSION}"; \
    root="cadcraft-${CADCRAFT_VERSION}-linux-${CADCRAFT_ARCH}"; \
    mkdir -p /opt/cadcraft/bin /tmp/cadcraft; \
    cd /tmp/cadcraft; \
    curl --proto '=https' -fsSLO "${base}/${archive}"; \
    printf '%s  %s\n' "${CADCRAFT_ARCHIVE_SHA256}" "${archive}" | sha256sum -c -; \
    tar -xzf "${archive}"; \
    install -m 0755 "${root}/bin/cadcraft-cli" /opt/cadcraft/bin/cadcraft-cli; \
    /opt/cadcraft/bin/cadcraft-cli --version; \
    rm -rf /tmp/cadcraft

COPY scripts/cad-reference-info /usr/local/bin/cad-reference-info
COPY scripts/test-reference-runtime.sh /usr/local/bin/test-cad-reference-runtime

RUN chmod +x \
        /usr/local/bin/cad-reference-info \
        /usr/local/bin/test-cad-reference-runtime \
    && test-cad-reference-runtime

CMD ["cad-reference-info"]
