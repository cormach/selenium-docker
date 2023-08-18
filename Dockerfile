

# Install Chrome browser and ChromeDriver

ARG NAMESPACE
ARG VERSION
ARG AUTHORS
FROM python:3.10
LABEL authors=${AUTHORS}

USER root
RUN apt-get -qq -y update && apt-get install -qq -y jq curl

#============================================
# Google Chrome
#============================================
# can specify versions by CHROME_VERSION;
#  e.g. google-chrome-stable=53.0.2785.101-1
#       google-chrome-beta=53.0.2785.92-1
#       google-chrome-unstable=54.0.2840.14-1
#       latest (equivalent to google-chrome-stable)
#       google-chrome-beta  (pull latest beta)
#============================================
ARG CHROME_VERSION="google-chrome-stable"
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update -qqy \
  && apt-get -qqy install \
    ${CHROME_VERSION:-google-chrome-stable} \
    && echo $CHROME_VERSION \
  && rm /etc/apt/sources.list.d/google-chrome.list \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

#=================================
# Chrome Launch Script Wrapper
#=================================
COPY --chmod=777 wrap_chrome_binary /opt/bin/wrap_chrome_binary
RUN /opt/bin/wrap_chrome_binary

#============================================
# Chrome webdriver
#============================================
# can specify versions by CHROME_DRIVER_VERSION
# Latest released version will be used by default
#============================================
ARG CHROME_DRIVER_VERSION

RUN echo "Geting ChromeDriver binary from https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions-with-downloads.json" \
    && CFT_URL=https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions-with-downloads.json \
    && CFT_CHANNEL="Stable" \
    && CTF_VALUES=$(curl -sSL $CFT_URL | jq -r --arg CFT_CHANNEL "$CFT_CHANNEL" '.channels[] | select (.channel==$CFT_CHANNEL)') \
    && echo $CTF_VALUES \
    && CHROME_DRIVER_VERSION=$(echo $CTF_VALUES | jq -r '.version' ) \
    && echo $CHROME_DRIVER_VERSION \
    && CHROME_DRIVER_URL=$(echo $CTF_VALUES | jq -r '.downloads.chromedriver[] | select(.platform=="linux64") | .url' ) \
    && echo $CHROME_DRIVER_URL \
    && wget --no-verbose -O /tmp/chromedriver_linux64.zip $CHROME_DRIVER_URL \
    && rm -rf /opt/selenium/chromedriver \
    &&  unzip /tmp/chromedriver_linux64.zip -d /opt/selenium \
    && rm /tmp/chromedriver_linux64.zip \
    &&  mv /opt/selenium/chromedriver-linux64/chromedriver /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION \
    &&  chmod 755 /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION \
    &&  ln -fs /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION /usr/bin/chromedriver


# #============================================
# # Dumping Browser name and version for config
# #============================================
RUN echo "chrome" > /opt/selenium/browser_name

# Set environment variables to avoid GUI errors
ENV PYTHONUNBUFFERED=1
ENV DISPLAY=:99

USER 1200

# Install required packages
RUN pip install --user selenium
