FROM centos:7

RUN cd /tmp && \
			curl -L > epel-release-latest-7.noarch.rpm https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
			yum -y install epel-*.rpm && \
			rm -f *.rpm && \
			yum clean all

RUN cd /tmp && \
			curl -L > splunk-6.3.2-aaff59bb082c-linux-2.6-x86_64.rpm 'http://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=6.3.2&product=splunk&filename=splunk-6.3.2-aaff59bb082c-linux-2.6-x86_64.rpm&wget=true' && \
			yum -y install splunk-*.rpm && \
			rm -f *.rpm && \
			yum clean all
ENV PATH="$PATH:/opt/splunk/bin"

ADD splunk.sh /bin/splunk

RUN mkdir -p /opt/splunk/var && \
			chown -R splunk:splunk /opt/splunk
VOLUME /opt/splunk/var

ADD splunk-etc /opt/splunk/.etc-docker
RUN chown -R splunk:splunk /opt/splunk/.etc-docker
RUN cp -a /opt/splunk/etc /opt/splunk/etc.orig

ADD init.sh /init


RUN yum -y install syslog-ng && \
			yum clean all
ADD syslog-ng.conf /etc/syslog-ng/

# what about 514 udp?
EXPOSE 8000 8089 514


CMD ["/init"]
