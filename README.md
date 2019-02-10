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
    - rm docker-copmose:
        make clean
    - stop one service:
        docker-compose <service> stop
    - start one service:
        docker-compose <service> start









List Available Storage Blocks
lsblk
df -h

Expand Partition to New Available Disk Volume
sudo growpart /dev/xvda 1

Expand file system
sudo resize2fs /dev/xvda1

Check Partitions and Disk Space
lsblk
df -h

