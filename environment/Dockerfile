# hash:sha256:2a6818e9e15e8717bfe50115b8dc668d27f9ea5c770087f714e7f4302f076162
ARG REGISTRY_HOST
FROM $REGISTRY_HOST/codeocean/mosuite:v0.3.2

ARG DEBIAN_FRONTEND=noninteractive
ARG GIT_ASKPASS
COPY git-ask-pass /

ARG RCACHE_OPTIONS
RUN echo $RCACHE_OPTIONS >> $(Rscript -e 'cat(R.home())')/etc/Rprofile.site
RUN Rscript -e 'remotes::install_version("optparse", "1.8.2")' \
    && Rscript -e 'remotes::install_version("patchwork", "1.3.2")' \
    && Rscript -e 'remotes::install_version("plotly", "4.12.0")'
