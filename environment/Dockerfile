# hash:sha256:0ffc6482c1c18e9c938bcea570471f04d1069e3dfce903fd5cda0f79043dd105
ARG REGISTRY_HOST
FROM $REGISTRY_HOST/codeocean/omix-r-visualization:r4.4.3-v2

ARG DEBIAN_FRONTEND=noninteractive
ARG GIT_ASKPASS
COPY git-ask-pass /

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        pandoc=3.1.3+ds-2 \
    && rm -rf /var/lib/apt/lists/*

ARG RCACHE_OPTIONS
RUN echo $RCACHE_OPTIONS >> $(Rscript -e 'cat(R.home())')/etc/Rprofile.site
RUN Rscript -e 'remotes::install_version("DT", "0.34.0")'

COPY postInstall /
RUN --mount=type=secret,id=secrets . /run/secrets/secrets \
    && /postInstall
