

all: build

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

clean:
	docker-compose stop
	docker-compose rm -f
	docker rm $$(docker ps -a -f status=exited -q)
	docker rmi $$(docker images -a -q)