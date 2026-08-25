# hash:sha256:8590b5c572b832f4699749c488ce28df91417f143a38f46092b3b18af777886e
ARG REGISTRY_HOST
FROM $REGISTRY_HOST/codeocean/omix-r-pathway:r4.4.3-bioconductor3.20-v1

ARG DEBIAN_FRONTEND=noninteractive
ARG GIT_ASKPASS
COPY git-ask-pass /

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        pandoc=3.1.3+ds-2 \
    && rm -rf /var/lib/apt/lists/*

ARG RCACHE_OPTIONS
RUN echo $RCACHE_OPTIONS >> $(Rscript -e 'cat(R.home())')/etc/Rprofile.site
RUN Rscript -e 'remotes::install_version("DT", "0.34.0")' \
    && Rscript -e 'remotes::install_version("htmlwidgets", "1.6.4")' \
    && Rscript -e 'remotes::install_version("plotly", "4.12.0")'

COPY postInstall /
RUN --mount=type=secret,id=secrets . /run/secrets/secrets \
    && /postInstall
