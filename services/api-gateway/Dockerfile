FROM ruby:3.2

RUN gem install bundler

WORKDIR /app

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . .

EXPOSE 4000

CMD ["bundle", "exec", "puma", "-b", "tcp://0.0.0.0:4000", "config.ru"]
