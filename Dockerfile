FROM ruby:2

RUN apt-get -qq update && \
    apt-get -qq -y install rsync && \
    apt-get -qq -y install vim && \
    apt-get -qq clean

ENV ACROBOT_HOME=/opt/acrobot

RUN mkdir -p ${ACROBOT_HOME}
COPY . ${ACROBOT_HOME}

RUN gem install -q cinch && \
    chmod -R 777 ${ACROBOT_HOME} && \
    chown -R nobody:root ${ACROBOT_HOME}

USER nobody
WORKDIR ${ACROBOT_HOME}

CMD ["ruby", "./AcroBot.rb"]
