# Dockerfile for compiling Ruby 2.5.1 on Ubuntu 20.04 and running your Rails 5.1.7 app

# 1) Base image
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# 2) Install build tools, runtime libs, Node and npm
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
       build-essential \
       curl \
       git \
       libssl-dev \
       libreadline-dev \
       zlib1g-dev \
       libpq-dev \
       nodejs \
       npm \
       ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# 3) Download, compile and install Ruby 2.5.1
RUN apt-get update && apt-get install -y openssh-client

WORKDIR /usr/src
RUN curl -fsSL https://cache.ruby-lang.org/pub/ruby/2.5/ruby-2.5.1.tar.gz | tar xz \
  && cd ruby-2.5.1 \
  && ./configure --disable-install-doc \
  && make -j"$(nproc)" \
  && make install \
  && cd / \
  && rm -rf /usr/src/ruby-2.5.1

# 4) Install Bundler without documentation (faster)

# 5) Set up the Rails app
WORKDIR /app
COPY Gemfile Gemfile.lock ./
RUN gem install bundler:2.1.4 && bundle install --jobs 4 --retry 3 --quiet 
# 6) Copy application code
COPY . .

# 7) Expose port and define default command
EXPOSE 3000
CMD ["bin/rails", "server", "-b", "0.0.0.0"]
