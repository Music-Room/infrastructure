# infrastructure

#### AWS - TERRAFORM
    - terraform init

#### Build infrastructure (Makefile)
    - build infrastructure:
        AKEY='aws_access_key' && SKEY='aws_secret_key' && make terrup
    - rm infrastructure:
        AKEY='aws_access_key' && SKEY='aws_secret_key' && make terrdown
    - build docker-compose:
        make
    - rm docker-copmose;
        make clean