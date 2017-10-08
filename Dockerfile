FROM ruby:2.4
WORKDIR "/usr/src/app"
COPY Gemfile Gemfile.lock /usr/src/app/
RUN bundle install
VOLUME ["/usr/src/app"]
ENTRYPOINT ["bundle"]
