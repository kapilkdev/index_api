FROM ruby:3.2.2
COPY . /app
RUN bundle config set --deployment "true"
RUN bundle config set --without "development test"
WORKDIR /app
RUN gem install bundler
RUN bundle install
EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]