FROM ubuntu:16.04

RUN apt-get -y update
RUN apt-get -y install openssh-server git

# required by openssh
RUN mkdir /var/run/sshd

# disable password-based login
RUN sed -i -e '/PasswordAuthentication/d' /etc/ssh/sshd_config
RUN echo "PasswordAuthentication no" >> /etc/ssh/sshd_config

RUN adduser --system --shell $(which git-shell) git 

RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

EXPOSE 22
COPY start.sh /start.sh

RUN mkdir -p /home/git/git-shell-commands
COPY create /home/git/git-shell-commands/create
CMD ["/start.sh"]
