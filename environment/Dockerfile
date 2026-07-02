# hash:sha256:7d5239899b094b419b473fe50ce2f83b5b52f1f062036ff4f90ca36ecc13b555
ARG REGISTRY_HOST
FROM $REGISTRY_HOST/codeocean/mosuite:v0.3.2

ARG DEBIAN_FRONTEND=noninteractive
ARG GIT_ASKPASS
COPY git-ask-pass /

ARG RCACHE_OPTIONS
RUN echo $RCACHE_OPTIONS >> $(Rscript -e 'cat(R.home())')/etc/Rprofile.site
RUN Rscript -e 'remotes::install_version("RColorBrewer", "1.1-3")' \
    && Rscript -e 'remotes::install_version("optparse", "1.8.2")' \
    && Rscript -e 'remotes::install_version("patchwork", "1.3.2")' \
    && Rscript -e 'remotes::install_version("plotly", "4.12.0")'
