# Step 1/37
# Descarga la imagen Base de Ubuntu 18
FROM ubuntu:18.04

# Step 2/37
MAINTAINER orlando.montenegro@correounivalle.edu.co

# Step 3/37
ENV DEBIAN_FRONTEND=noninteractive \
	DEBCONF_NONINTERACTIVE_SEEN=true

# Step 4/37
ENV LINTER_PORT=4567 \
	PYTHON_TUTOR_PORT=8003 \
	COKAPI_PORT=3000 \
	DB_PORT=27017 \
	DEPLOYMENT_HOME=/tmp/JuezUN/ \
	APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

#ENV HTTP_PROXY "http://user:password@host:port/"
#ENV HTTPS_PROXY "http://user:password@host:port/"

#RUN echo "Acquire::http::Proxy \"http://user:password@host:port/\"; " >> /etc/apt/apt.conf
#RUN echo "Acquire::https::Proxy \"http://user:password@host:port/\"; " >> /etc/apt/apt.conf 

# Step 5/37
RUN apt-get update && apt-get install -y gnupg gnupg2 dbus wget openssh-server curl software-properties-common

# Step 6/37
RUN echo "deb http://download.opensuse.org/repositories/network:/messaging:/zeromq:/release-stable/Debian_9.0/ ./" >> /etc/apt/sources.list \
	&& wget https://download.opensuse.org/repositories/network:/messaging:/zeromq:/release-stable/Debian_9.0/Release.key -O- | apt-key add \
	&& wget http://launchpadlibrarian.net/330507614/libsodium18_1.0.13-1_amd64.deb \
	&& apt-get install ./libsodium18_1.0.13-1_amd64.deb 

# Step 7/37
RUN apt-get update && apt-get install -y --fix-missing apt-utils apt-transport-https ca-certificates

# Step 8/37
RUN touch /etc/apt/apt.conf.d/99fixbadproxy \ 
		&& echo "Acquire::http::Pipeline-Depth 0;" >> /etc/apt/apt.conf.d/99fixbadproxy \
		&& echo "Acquire::http::No-Cache true;" >> /etc/apt/apt.conf.d/99fixbadproxy \
		&& echo "Acquire::BrokenProxy true;" >> /etc/apt/apt.conf.d/99fixbadproxy \
		&& apt-get update -o Acquire::CompressionTypes::Order::=gz \
		&& apt-get clean \
		&& echo "root:w1234w" | chpasswd \
		&& sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
		&& rm -rf /var/lib/apt/lists/*

# Step 9/37
RUN apt-get update -q && apt-get install -y locales --no-install-recommends apt-utils && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

# Step 10/37
ENV LANG en_US.UTF-8

# Step 11/37
RUN apt-get clean -y && apt-get -f install && dpkg --configure -a

# Step 12/37
RUN apt-get update -q && \
    apt-get install -y -f \
	nano \
	python3-dev \
	python3-setuptools \
	python3-pip \
	apt-utils vim nginx \
	lighttpd lighttpd-dev \
	git gcc libsodium-dev libzmq5 libtidy-dev libzmq3-dev tidy && \
	pip3 install -U pip setuptools && \
    rm -rf /var/lib/apt/lists/*

# Step 13/37
RUN rm -rf /usr/bin/python \
	&& ln /usr/bin/python3 /usr/bin/python \
	&& rm -rf /usr/bin/pip \
	&& ln /usr/bin/pip3 /usr/bin/pip

# Step 14/37
RUN pip install --upgrade pip \
	&& pip install "flup>=1.0.3.dev" \
	&& pip install --upgrade git+https://github.com/JuezUN/INGInious.git

# Step 15/37
# instalacion de mongo
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4 && \
	echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.0.list && \
  	apt-get update && \
  	apt-get install -y mongodb-org && \
  	rm -rf /var/lib/apt/lists/*

# Step 16/37
RUN mkdir -p /data/db

# Step 17/37
RUN chown -R `id -u` data/db

# Step 18/37
RUN curl --silent --location https://deb.nodesource.com/setup_8.x | bash -

# Step 19/37
RUN apt-get install --yes nodejs build-essential

# Step 20/37
WORKDIR /tmp

# Step 21/37
RUN touch .firstrun

# Step 22/37
RUN useradd -ms /bin/bas docker && usermod -aG docker $(whoami)

# Step 23/37
RUN git clone https://github.com/JuezUN/Deployment.git JuezUN \
	&& git clone https://github.com/orlandc/Inginus-Docker-Container.git ijn

# Step 24/37
WORKDIR /tmp/JuezUN

# Step 25/37
RUN git checkout 39622a0b81d81dc3b5402cfc7cc940dd0a29c902

# Step 26/37
RUN chmod +x /tmp/JuezUN/uncode_scripts/uncode* \
	&& cp /tmp/JuezUN/uncode_scripts/uncode* /usr/bin \
	&& sed -i 's+"/usr/lib/python3.5/site-packages/inginious/frontend/static/"+"/usr/local/lib/python3.6/dist-packages/inginious/frontend/static/"+g' /tmp/JuezUN/config/lighttpd/conf.d/fastcgi.conf \
	&& chmod +x /tmp/ijn/boot.sh

# Step 27/37
RUN rm -rf /etc/nginx \
	&& rm -rf /etc/lighttpd \
	&& cp -r /tmp/JuezUN/config/nginx /etc/ \
	&& cp -r /tmp/JuezUN/config/lighttpd /etc/ \
	&& cp /tmp/JuezUN/deployment_scripts/cokapi.sh /usr/local/bin \
	&& cp /tmp/JuezUN/deployment_scripts/cokapi.service /etc/systemd/system \
	&& chmod 664 /etc/systemd/system/cokapi.service \
	&& chmod +x /usr/local/bin/cokapi.sh

# Step 28/37
RUN useradd lighttpd && useradd ucokapi && useradd nginx \
	&& usermod -aG docker lighttpd \
	&& usermod -aG mongodb lighttpd \
	&& usermod -aG ucokapi $(whoami) \
	&& usermod -aG docker ucokapi \
	&& mkdir -p /var/www/INGInious \
	&& mkdir -p /var/www/INGInious/tasks \
	&& mkdir -p /var/www/INGInious/backup \
	&& mkdir -p /var/www/INGInious/tmp \
	&& chown -Rf lighttpd:lighttpd /var/www/INGInious \
	&& mkdir -p /var/cache/lighttpd/compress \
	&& chown -Rf lighttpd:lighttpd /var/cache/lighttpd \
	&& chown -Rf lighttpd:lighttpd /var/log/lighttpd/ \
	&& cp /tmp/JuezUN/config/configuration.yaml /var/www/INGInious/

# Step 29/37
RUN mkdir -p /opt/tutor \
	&& chown -R ucokapi:ucokapi /opt/tutor \
	&& chown ucokapi:ucokapi /usr/local/bin/cokapi.sh

# Step 30/37
WORKDIR /opt/tutor 

# Step 31/37
RUN git clone https://github.com/JuezUN/OnlinePythonTutor.git

# Step 32/37
WORKDIR /opt/tutor/OnlinePythonTutor/v4-cokapi

# Step 33/37
RUN npm install --prefix /usr/local/lib/python3.6/dist-packages/inginious/frontend/plugins/problem_bank/react_app/ \
	&& npm run build --prefix /usr/local/lib/python3.6/dist-packages/inginious/frontend/plugins/problem_bank/react_app/ \
	&& npm install express \
	&& npm update caniuse-lite browserslist

# Step 34/37
RUN rm -rf /usr/bin/python \
	&& ln /usr/bin/python3 /usr/bin/python \
	&& rm -rf /usr/bin/pip \
	&& ln /usr/bin/pip3 /usr/bin/pip \
	&& cp /usr/local/bin/inginious-webapp /usr/bin/

# Step 35/37
RUN	apt-get update && \
	apt-get -y install apt-transport-https ca-certificates netcat && \
	curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg > /tmp/dkey; apt-key add /tmp/dkey && \
	add-apt-repository \
	"deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
	$(lsb_release -cs) \
	stable" && \
	apt-get update && \
	apt-get -y install docker-ce

# Step 36/37
EXPOSE 80 22 443 587 3000 4567 8003 8088 27017 28017

# Step 37/37
CMD ["/bin/bash", "/tmp/ijn/boot.sh"]