FROM jenkins

USER root
RUN apt-get update && apt-get install -y dos2unix
RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers

# plugins
COPY plugins/plugins.txt /usr/share/jenkins/plugins.txt

#fix windows line endings
RUN dos2unix /usr/share/jenkins/plugins.txt && apt-get --purge remove -y dos2unix && rm -rf /var/lib/apt/lists/*

RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/plugins.txt || echo "\033[1;91m*** \033[1;93m Bad Jenkins! \033[1;92mManually Install Plugins! \033[1;91m***\033[0m"

USER jenkins

# jobs
COPY jobs/aadi-ci-config.xml /usr/share/jenkins/ref/jobs/aadi-ci/config.xml

# jenkins settings
COPY config/config.xml /usr/share/jenkins/ref/config.xml

# tool config
COPY config/hudson.tasks.Maven.xml /usr/share/jenkins/ref/hudson.tasks.Maven.xml

# tell Jenkins that no banner prompt for pipeline plugins is needed
COPY config/basic-security.groovy /usr/share/jenkins/ref/basic-security.groovy
RUN echo 2.0 > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state

ENV JAVA_OPTS "-Djenkins.install.runSetupWizard=false -Duser.timezone=Australia/Sydney"
