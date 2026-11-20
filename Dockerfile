ARG PYTHON_IMAGE
FROM ${PYTHON_IMAGE} AS common

ARG RUNTIME_VERSION
ARG CAD_VERIFICATION_VERSION
ARG CAD_VERIFICATION_COMMIT
ARG PYYAML_VERSION

LABEL org.opencontainers.image.source="https://github.com/brainboxemb/docker.cad.solidcraft"

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    CAD_RUNTIME_VERSION=${RUNTIME_VERSION} \
    CAD_VERIFICATION_VERSION=${CAD_VERIFICATION_VERSION}

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
    && python -m pip install "PyYAML==${PYYAML_VERSION}" \
    && python -m pip install --no-deps \
        "https://github.com/brainboxemb/lib.py.cad.verification/archive/${CAD_VERIFICATION_COMMIT}.zip"

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


FROM common AS reference

ARG PYTHONSCAD_VERSION
ARG PYBOSL2_COMMIT
ARG CADQUERY_VERSION
ARG BUILD123D_VERSION
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

COPY scripts/cad-reference-info /usr/local/bin/cad-reference-info
COPY scripts/test-reference-runtime.sh /usr/local/bin/test-cad-reference-runtime

RUN chmod +x \
        /usr/local/bin/cad-reference-info \
        /usr/local/bin/test-cad-reference-runtime \
    && test-cad-reference-runtime

CMD ["cad-reference-info"]
