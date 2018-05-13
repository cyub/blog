FROM node:9

WORKDIR /app

RUN npm install -g hexo-cli
RUN git clone https://github.com/cyub/blog.git .
RUN npm install

expose 4000

CMD /usr/local/bin/hexo server -p 4000