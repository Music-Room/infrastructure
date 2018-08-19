

all: build

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
	@$(aws ecr --profile alex get-login --no-include-email --region us-east-1 | sed 's|https://||')
	docker-compose up
	#docker-compose logs -f

clean:
	docker-compose stop
	docker-compose rm -f
	docker rm $$(docker ps -a -f status=exited -q)
	docker rmi $$(docker images -a -q)