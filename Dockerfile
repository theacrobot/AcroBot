FROM ruby:latest

RUN apt-get -qq update && \
    apt-get -qq -y install rsync && \
    apt-get -qq -y install vim && \
    apt-get -qq clean

ENV ACROBOT_HOME=/opt/acrobot

RUN gem install -q cinch && \
    mkdir -p ${ACROBOT_HOME} && \
    chmod 777 ${ACROBOT_HOME}

USER nobody
WORKDIR ${ACROBOT_HOME}

COPY . ${ACROBOT_HOME}

CMD ["ruby", "./AcroBot.rb"]
