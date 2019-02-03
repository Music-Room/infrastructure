
AWSECR=848984447616.dkr.ecr.us-east-1.amazonaws.com

DOCKER=docker
DOCKERBUILD=$(DOCKER) build
DOCKERRUN=$(DOCKER) run

LOGPATH=/home/ubuntu/infrastructure/app_log
AWSLOGIN=aws ecr --profile alex get-login --no-include-email --region us-east-1 | sed 's|https://||'

#all: aws-login shutterstock-check-rejected

aws-login:
	`eval $(AWSLOGIN)`

install:
	sudo curl -L https://github.com/docker/compose/releases/download/1.18.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose
	docker-compose --version
	sudo pip install awscli
	aws --version
	aws configure

terrup:
	@echo Terraform UP
	terraform init
	@echo $$AKEY
	@echo $$SKEY
	terraform apply -var 'access_key=$(AKEY)' -var 'secret_key=$(SKEY)'

terrdown:
	@echo Terraform DOWN
	terraform down

ansible:
	@echo Ansible UP

build:
	@login=$(aws ecr --profile alex get-login --no-include-email --region us-east-1 | sed 's|https://||')
	@$(shell login)
	docker-compose up -d
	#docker-compose logs -f

pinterest-api-server: aws-login
	$(DOCKERRUN) \
	--rm \
	-td \
	-p 8080:8080 \
	--name=pinterest-api-server \
	-v $(LOGPATH):/app_log \
	--net my_app \
	-e PROD='1' \
	$(AWSECR)/pinterest-api-server:latest

pinterest-relinker-service:
	$(DOCKERRUN) \
	--rm \
	-td \
	--name=pinterest-relinker-service \
	-v $(LOGPATH):/app_log \
	--net my_app \
	$(AWSECR)/pinterest-relinker-service:latest
	@echo "Docker pinterest-relinker-service run..."

pinterest-repinner-service:
	$(DOCKERRUN) \
	--rm \
	-dt \
	--name=pinterest-repinner-service \
	-v $(LOGPATH):/app_log \
	--net my_app \
	-e PROD='1' \
	$(AWSECR)/pinterest-repinner-service:latest
	@echo "Docker run service..."

pinterest-service: aws-login
	$(DOCKERRUN) \
	--rm \
	-td \
	--name=pinterest-service \
	-v $(LOGPATH):/app_log \
	--net my_app \
	-e PROD='1' \
	$(AWSECR)/pinterest-service:latest
	@echo "Docker run service..."

shutterstock-check-rejected: aws-login
	$(DOCKERRUN) \
	--rm \
	-td \
	--name=shutterstock-check-rejected \
	-v $(LOGPATH):/app_log \
	--net my_app \
	$(AWSECR)/shutterstock-check-rejected:latest
	@echo "Docker run service..."

shutterstock-check-approved: aws-login
	$(DOCKERRUN) \
	-td \
	--name=shutterstock-check-approved \
	--rm \
	-v $(LOGPATH):/app/app_log \
	--net my_app \
	$(AWSECR)/shutterstock-check-approved:latest
	@echo "Docker run service..."

slack-notification: aws-login
	$(DOCKERRUN) \
	-td \
	--name=slack-notification \
	--rm \
	-v $(LOGPATH):/app_log \
	--net my_app \
	$(AWSECR)/slack-notification:latest

parser-shutterstock: aws-login
	$(DOCKERRUN) \
        -td \
        --name=parser-shatterstock \
        --rm \
        -v $(LOGPATH):/app_log \
        --net my_app \
	-e SOURCE='shutterstock' \
	-e PROD='1' \
	$(AWSECR)/parser-pinterest:latest

parser-dreamsTime: aws-login
	$(DOCKERRUN) \
        -td \
        --name=parser-dreams_time \
        --rm \
        -v $(LOGPATH):/app_log \
        --net my_app \
        -e SOURCE='dreamsTime' \
        -e PROD='1' \
        $(AWSECR)/parser-pinterest:latest

parser-theHungryJpeg: aws-login
	$(DOCKERRUN) \
        -td \
        --name=parser-heHungryJpeg \
        --rm \
        -v $(LOGPATH):/app_log \
        --net my_app \
        -e SOURCE='theHungryJpeg' \
        -e PROD='1' \
        $(AWSECR)/parser-pinterest:latest

postgres: aws-login
	$(DOCKERRUN) \
	-td \
	--name=postgres-pinterest \
	--rm \
	-v /srv/docker/postgresql:/var/lib/postgresql \
	--net my_app \
	 $(AWSECR)/postgres-pinterest:latest
	
postgresdb:
	psql -v ON_ERROR_STOP=1 --username "alex" --dbname "msp" <<-EOSQL \
	CREATE USER alex; \
	CREATE DATABASE docker; \
	GRANT ALL PRIVILEGES ON DATABASE docker TO docker; \
	EOSQLpsql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL \
	CREATE USER alex; \
	CREATE DATABASE msp; \
	GRANT ALL PRIVILEGES ON DATABASE msp TO alex; \
	CREATE TABLE IF NOT EXISTS pinterest (image_id VARCHAR(15) PRIMARY KEY,title VARCHAR(255) NOT NULL,link VARCHAR(255) NOT NULL,image_src VARCHAR(255) NOT NULL) \
	EOSQL
	@echo "Create POSTGRES user, permission, db"
	
clean:
	docker-compose stop
	docker-compose rm -f
	docker rm $$(docker ps -a -f status=exited -q)
	docker rmi $$(docker images -a -q)
