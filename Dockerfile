# Envisaged - Dockerized Gource Visualizations
#
# VERSION 0.1.7
ARG BASE_IMAGE=utensils/opengl:stable
FROM ${BASE_IMAGE}

# Install all needed runtime dependencies.
RUN set -xe; \
    apk --update add --no-cache --virtual .runtime-deps \
        bash \
        ffmpeg \
        git \
        gource \
        imagemagick \
        lighttpd \
        py3-pip \
        python3 \
        subversion \
        wget; \
    pip3 install --upgrade \
        google-api-python-client \
        progressbar2; \
    cd /var/tmp; \
    wget https://github.com/tokland/youtube-upload/archive/master.zip; \
    unzip master.zip; \
    cd youtube-upload-master; \
    python3 setup.py install; \
    cd /var/tmp; \
    rm -rf youtube-upload-master; \
    mkdir -p /visualization; \
    cd /visualization; \
    mkdir -p /visualization/video; \
    mkdir -p /visualization/html; \
    mkdir -p /visualization/avatars; \
    cd /visualization/html; \
    wget "https://github.com/twbs/bootstrap/releases/download/v4.0.0/bootstrap-4.0.0-dist.zip"; \
    unzip bootstrap-4.0.0-dist.zip; \
    rm bootstrap-4.0.0-dist.zip; \
    wget "https://github.com/jquery/jquery/archive/3.3.1.zip"; \
    unzip 3.3.1.zip; \
    rm 3.3.1.zip; \
    mv jquery-3.3.1/dist/* /visualization/html/js/; \
    rm -rf 3.3.1;

# Copy our assets into image.
COPY ./docker-entrypoint.sh /usr/local/bin/entrypoint.sh
COPY . /visualization/

# Set our working directory.
WORKDIR /visualization

# Labels and metadata.
ARG VCS_REF
ARG BUILD_DATE
ARG VERSION
LABEL \
    org.opencontainers.image.authors="James Brink <brink.james@gmail.com>" \
    org.opencontainers.image.created="${BUILD_DATE}" \
    org.opencontainers.image.description="Envisaged ${VERSION} - Dockerized Gource Visualizations." \
    org.opencontainers.image.revision="${VCS_REF}" \
    org.opencontainers.image.source="https://github.com/utensils/Envisaged" \
    org.opencontainers.image.title="Envisaged ${VERSION}" \
    org.opencontainers.image.vendor="Utensils" \
    org.opencontainers.image.version="${VERSION}"

# Set our environment variables.
ENV \
    DISPLAY=":99" \
    GIT_URL="https://github.com/moby/moby" \
    GLOBAL_FILTERS="" \
    GOURCE_AUTO_SKIP_SECONDS="0.5" \
    GOURCE_BACKGROUND_COLOR="000000" \
    GOURCE_CAMERA_MODE="overview" \
    GOURCE_DIR_DEPTH="3" \
    GOURCE_FILENAME_TIME="2" \
    GOURCE_FILTERS="" \
    GOURCE_FONT_SIZE="48" \
    GOURCE_HIDE_ITEMS="usernames,mouse,date,filenames" \
    GOURCE_MAX_USER_SPEED="500" \
    GOURCE_SECONDS_PER_DAY="0.1" \
    GOURCE_TEXT_COLOR="FFFFFF" \
    GOURCE_TIME_SCALE="1.5" \
    GOURCE_TITLE="Software Development" \
    GOURCE_USER_IMAGE_DIR="/visualization/avatars" \
    GOURCE_USER_SCALE="1.5" \
    H264_CRF="23" \
    H264_LEVEL="5.1" \
    H264_PRESET="medium" \
    INVERT_COLORS="false" \
    LOGO_URL="" \
    OVERLAY_FONT_COLOR="0f5ca8" \
    TEMPLATE="border" \
    VIDEO_RESOLUTION="1080p" \
    XVFB_WHD="3840x2160x24" \
    GOURCE_FPS="60"

# Expose port 80 to serve mp4 video over HTTP.
EXPOSE 80

# Set our entrypoint.
CMD ["/usr/local/bin/entrypoint.sh"]
