## Perl 5.26.1 / Carton / cpanm / Alpine Docker image


Pull the docker container using:

    docker pull csandeep/perl5_docker_image

Assuming you are using [Mojolicious](http://mojolicious.org/) framework:

Here's a sample **Dockerfile** to get you started:

    ADD . /src
    WORKDIR /src

    RUN carton install --cached
    RUN mv /src/local /tmp

    WORKDIR /tmp

    EXPOSE 3000
    ENV PERL5LIB /tmp/local/lib/perl5
    ENV MOJO_MODE development

and a **docker-compose.yml** to go with the above:

      version: '2'
    
      services:
        db:
          image: mariadb
          ports:
            - "8081:3306"
          environment:
            MYSQL_ROOT_PASSWORD: password
          volumes:
                - ./.data:/var/lib/mysql
        web:
          container_name: web
          restart: always
          tty: true
          build:
            context: .
            dockerfile: Dockerfile-web
          ports:
            - "3000:3000"
          volumes:
            - .:/src
          environment:
            PERL5LIB: /tmp/local/lib/perl5
            MOJO_MODE: development
            DB_PASSWORD: password
            SERVERNAME: test-dev
          links:
            - test-db:mysql 
          command: sh /src/start_web.sh  


the **start.sh** 

      echo "Starting morbo!"
    
      if [ -d /tmp/local ]; then
          cp -R /tmp/local /src/local
      fi
    
      carton exec "morbo -v -v /src/script/your_project"
