FROM node:9

WORKDIR /app

ADD . /app
RUN npm install -g hexo-cli
RUN npm install

expose 4000

CMD /usr/local/bin/hexo server -p 4000