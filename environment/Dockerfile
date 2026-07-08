# hash:sha256:9ff0eccc9077180d87a225729dd845ad8bba90d9f76342bad0f0e538f5443baf
ARG REGISTRY_HOST
FROM $REGISTRY_HOST/codeocean/mosuite:v0.3.2

ARG DEBIAN_FRONTEND=noninteractive
ARG GIT_ASKPASS
COPY git-ask-pass /

ARG RCACHE_OPTIONS
RUN echo $RCACHE_OPTIONS >> $(Rscript -e 'cat(R.home())')/etc/Rprofile.site
RUN Rscript -e 'remotes::install_version("DT")' \
    && Rscript -e 'remotes::install_version("RColorBrewer")' \
    && Rscript -e 'remotes::install_version("htmlwidgets")' \
    && Rscript -e 'remotes::install_version("optparse")' \
    && Rscript -e 'remotes::install_version("patchwork")' \
    && Rscript -e 'remotes::install_version("plotly")'
