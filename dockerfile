FROM ubuntu:20.04
WORKDIR /home/ubuntu

#DATABASE
RUN export DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt install mysql-server -y
RUN service mysql start && \
      mysql -u root -e "CREATE DATABASE insta_clone;" && \
      mysql -u root -e "CREATE USER 'anviam'@'localhost' IDENTIFIED BY 'anviam123';" && \
      mysql -u root -e "GRANT ALL PRIVILEGES ON insta_clone.* TO 'anviam'@'localhost';" && \
      mysql -u root -e "FLUSH PRIVILEGES;"
    
#NODEJS

RUN apt install nodejs -y
RUN apt install npm -y
RUN apt install git -y


COPY backend/ .

#RUN git clone https://github.com/junaidmalik123/proj.git

#WORKDIR /home/ubuntu/proj

RUN apt install curl -y
RUN curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
SHELL ["/bin/bash", "-c"]
RUN nvm install 20
RUN nvm use 20
RUN npm run build
RUN npm install pm2 -g
RUN npx sequelize-cli db:migrate
#RUN pm2 start --name main.js npm -- start

#NGINX

RUN apt install nginx -y
RUN rm -rf /etc/nginx/sites-available 
WORKDIR /etc/nginx
RUN git clone https://github.com/malikjaid/sites-available.git
RUN service nginx reload 
#RUN service nginx start

WORKDIR /home/ubuntu
RUN service mysql start
RUN pm2 start --name main.js npm -- start
RUN service nginx start








#gpt


FROM ubuntu:20.04

# Set the working directory
WORKDIR /home/ubuntu

# Install necessary packages
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y mysql-server nodejs npm git curl nginx && \
    rm -rf /var/lib/apt/lists/*

# Initialize MySQL database
RUN service mysql start && \
    mysql -u root -e "CREATE DATABASE insta_clone;" && \
    mysql -u root -e "CREATE USER 'anviam'@'localhost' IDENTIFIED BY 'anviam123';" && \
    mysql -u root -e "GRANT ALL PRIVILEGES ON insta_clone.* TO 'anviam'@'localhost';" && \
    mysql -u root -e "FLUSH PRIVILEGES;"

# Install NVM
RUN curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash && \
    . ~/.nvm/nvm.sh && \
    nvm install 20 && \
    nvm use 20

# Copy application code
COPY backend/ .

# Install dependencies and build
RUN npm install && \
    npm run build && \
    npm install pm2 -g && \
    npx sequelize-cli db:migrate

# Clone Nginx configuration
WORKDIR /etc/nginx
RUN git clone https://github.com/malikjaid/sites-available.git && \
    rm -rf /etc/nginx/sites-available && \
    mv sites-available /etc/nginx/

# Start services
WORKDIR /home/ubuntu
CMD ["bash", "-c", "service mysql start && service nginx start && pm2 start --name main.js npm -- start"]
