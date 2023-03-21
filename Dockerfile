FROM ubuntu:22.04

WORKDIR /root

ARG PY_VER=3.8.4
ARG PY_BIN=3.8
ARG TERRA_VER=1.3.6
ARG TERRA_GRUNT_VER=0.42.2
ARG HELM_VER=3.10.2
ARG ISTIO_VER=1.16.0

#########################
# NORMAL IMAGE UPDATING #
#########################

RUN apt-get update; apt-get upgrade; apt-get install -y 

# Personal preferences
RUN apt install curl vim bind9-utils -y

#####################
# INSTALLING PYTHON #
#####################

# Python dependencies
RUN apt-get install make gcc -y

RUN apt-get install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev -y

# Download Python and required build tools
RUN curl https://www.python.org/ftp/python/$PY_VER/Python-$PY_VER.tgz -Lo $HOME/python

# Build and Install Python
RUN tar -xf $HOME/python && \
    cd Python-$PY_VER && \
    ./configure --enable-optimizations --with-ensurepip=install && \ 
    make -j 8 && \
    make altinstall

# set alias

RUN echo 'alias python=/usr/local/bin/python$PY_BIN' >> ~/.bashrc

##################
# INSTALLING GIT #
##################

RUN apt-get install git -y

####################
# INSTALLL AWS CLI #
####################

RUN apt-get install unzip -y

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

RUN unzip awscliv2.zip && ./aws/install

####################################
# INSTALL TERRAFORM AND TERRAGRUNT #
####################################

RUN curl https://releases.hashicorp.com/terraform/$TERRA_VER/terraform_$(echo $TERRA_VER)_linux_amd64.zip -o terraform.zip

RUN unzip terraform.zip && mv ./terraform /usr/local/bin

RUN curl https://github.com/gruntwork-io/terragrunt/releases/download/v$TERRA_GRUNT_VER/terragrunt_linux_amd64 -Lo terragrunt && \
    chmod +x terragrunt && mv terragrunt /usr/local/bin

###################
# INSTALL KUBECTL #
###################

RUN curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl

RUN install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

################
# INSTALL HELM #
################

RUN curl https://get.helm.sh/helm-v$HELM_VER-linux-amd64.tar.gz -Lo helm && tar -xvf helm

RUN mv linux-amd64/helm /usr/local/bin

####################
# INSTALL ISTIOCTL #
####################

RUN curl -L https://istio.io/downloadIstio | ISTIO_VERSION=$ISTIO_VER TARGET_ARCH=x86_64 sh -

RUN mv istio-$ISTIO_VER/bin/istioctl /usr/local/bin

########################
# CONFIGURE PYTHON ENV #
########################

WORKDIR /root/build

COPY requirements.txt ./

RUN /usr/local/bin/python3.8 -m venv .env && \
    echo 'source /root/build/.env/bin/activate' >> $HOME/.bashrc && \
    echo 'pip install -U pip' >> $HOME/.bashrc && \
    echo 'pip install -r requirements.txt' >> $HOME/.bashrc &&\
    echo 'ansible-galaxy collection install community.general' >> $HOME/.bashrc

CMD tail -f /dev/null

