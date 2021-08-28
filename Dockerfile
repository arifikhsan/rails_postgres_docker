FROM ruby:3.0.2

ENV NODE_VERSION=14.17.5
ENV BUNDLER_VERSION=2.2.22

RUN apt-get update && \
  apt-get install --quiet --yes \
  curl \
  sqlite3 \
  postgresql-client \
  libpq-dev \
  libsqlite3-dev \
  git \
  vim

RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
ENV NVM_DIR=/root/.nvm
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"
RUN node --version
RUN npm --version

RUN npm install --global yarn
RUN gem install bundler --version ${BUNDLER_VERSION}

WORKDIR /app
ENV BUNDLE_PATH /gems

COPY package.json yarn.lock /app/
RUN yarn install
COPY Gemfile Gemfile.lock /app/
RUN bundle install

COPY . /app/

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

CMD ["ruby", "bin/rails", "server", "--binding", "0.0.0.0"]

EXPOSE 3000
