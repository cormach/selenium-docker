# Use the official Python image as the base image
FROM python:3.10

# Install required packages
RUN pip install selenium

# Install Chrome browser and ChromeDriver
RUN apt-get update && apt-get install -y wget gnupg
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
RUN apt-get update && apt-get install -y google-chrome-stable

# Set environment variables to avoid GUI errors
ENV PYTHONUNBUFFERED=1
ENV DISPLAY=:99
