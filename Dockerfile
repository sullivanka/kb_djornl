FROM python:3.10
MAINTAINER KBase developer

RUN apt-get update
RUN apt-get upgrade -y
RUN mkdir -p /kb/module/work
WORKDIR /kb/module
# Python and R requirements
RUN apt-get install -y r-base
COPY ./requirements.kb_sdk.txt /kb/module/requirements.kb_sdk.txt
RUN pip install -r requirements.kb_sdk.txt
COPY ./requirements.txt /kb/module/requirements.txt
RUN pip install --extra-index-url https://pypi.anaconda.org/kbase/simple \
    -r requirements.txt
# Node and node requirements
RUN curl -fsSL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get install -y nodejs
COPY ./package.json /kb/module/package.json
RUN NO_POSTINSTALL=true npm install --production
RUN npm install webpack-cli webpack
COPY ./ /kb/module
# fix permissions
RUN chmod -R a+rw /kb/module
# build js report app
RUN mkdir -p /opt/work
RUN npm run build -- --mode production --output-path /opt/work/build
### Install kb-sdk
RUN apt-get install -y ant

RUN wget -O- https://www.azul.com/wp-content/uploads/2021/05/0xB1998361219BD9C9.txt | apt-key add -
RUN echo 'deb [ arch=amd64,arm64 ] https://repos.azul.com/zulu/deb/ stable main' > /etc/apt/sources.list.d/zulu-openjdk.list
RUN apt-get update
RUN apt-get install -y zulu8-jdk
RUN set -ex; \
	\
# deal with slim variants not having man page directories (which causes "update-alternatives" to fail)
	if [ ! -d /usr/share/man/man1 ]; then \
		mkdir -p /usr/share/man/man1; \
	fi; \
	\
	apt-get install -y \
		ca-certificates-java \
		jetty9 \
	; \
# update-alternatives so that future installs of other OpenJDK versions don't change /usr/bin/java
	update-alternatives --get-selections | awk -v home="$(readlink -f "$JAVA_HOME")" 'index($3, home) == 1 { $2 = "manual"; print | "update-alternatives --set-selections" }'; \
# ... and verify that it actually worked for one of the alternatives we care about
	update-alternatives --query java | grep -q 'Status: manual' ; \
	apt-get clean
RUN mkdir /root/src \
	&& cd /root/src \
	&& git clone https://github.com/kbase/kb_sdk.git \
	&& cd kb_sdk \
	&& make \
	&& cp bin/kb-sdk /usr/local/bin \
	&& mkdir -p /kb/deployment/lib /kb/deployment/lib
### end install kb-sdk
RUN make all

ENTRYPOINT [ "./scripts/entrypoint.sh" ]

CMD [ ]
