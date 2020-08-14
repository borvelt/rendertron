# FROM gcr.io/google_appengine/nodejs
FROM node:12
LABEL name="mfe-renderer" \ 
    version="0.1" \
    description="Renders a webpage for bot consumption (not production ready)"

RUN apt-get update && apt-get install -y \
    wget \
    --no-install-recommends \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update && apt-get install -y \
    google-chrome-stable \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Check to see if the the version included in the base runtime satisfies
# '>=7.6', if not then do an npm install of the latest available
# version that satisfies it.
# RUN /usr/local/bin/install_node '>=7.6'

COPY . /app/

WORKDIR /app/

# Add mferenderer as a user
RUN groupadd -r mferenderer && useradd -r -g mferenderer -G audio,video mferenderer \
    && mkdir -p /home/mferenderer && chown -R mferenderer:mferenderer /home/mferenderer \
    && chown -R mferenderer:mferenderer /app

# Run mferenderer non-privileged
USER mferenderer

EXPOSE 8888

RUN npm install || \
    ((if [ -f npm-debug.log ]; then \
    cat npm-debug.log; \
    fi) && false)

RUN ls node_modules
RUN npm run prepack
