#!/bin/bash

# Make sure everything is being run from the script's directory
cd $(dirname $0)

# Choose whether you want system monitoring
echo ''
while true; do
    read -p 'Do you want this system to be monitored by New Relic? y/n [n]: ' monitoring_choice
    case $monitoring_choice in
      ''|[Nn]) monitoring_choice=0; break;;
      [Yy]) monitoring_choice=1; read -p 'New Relic API Key?: ' new_relic_api_key; break;;
      *) echo 'Please answer y/n.';;
    esac
done

# Select a database package
echo ''
echo 'Please select a database package.'
echo '1) PostgreSQL'
echo '2) MySQL'
while true; do
    read -p 'Package # [1]: ' db_choice
    case $db_choice in
      ''|1) db_choice=1; break;;
      2) read -p 'MySQL Root Password?: ' mysql_password; break;;
      *) echo 'Please choose a database package.';;
    esac
done

# Choose whether you want a mail server
echo ''
while true; do
    read -p 'Do you want a mail server to be installed? y/n [n]: ' mail_choice
    case $mail_choice in
      ''|[Nn]) mail_choice=0; break;;
      [Yy])
        mail_choice=1
        while true; do
          read -p 'What is the domain name?: ' mail_domain
          case $mail_domain in
            '') echo 'Please provide a domain name.';;
            *) break;;
          esac
        done
      break;;
      *) echo 'Please answer y/n.';;
    esac
done

# Upgrading OS packages
sudo apt-get -y update
sudo apt-get -y dist-upgrade

# Disabling SSH password authentication and root login
sudo cp support/lockdown/sshd_config /etc/ssh/sshd_config
sudo service ssh restart

# Setting up firewall rules
sudo cp support/lockdown/iptables.firewall.rules /etc/iptables.firewall.rules
sudo iptables-restore < /etc/iptables.firewall.rules
sudo cp support/lockdown/firewall /etc/network/if-pre-up.d/firewall
sudo chmod +x /etc/network/if-pre-up.d/firewall

# Installing Fail2Ban
sudo apt-get -y install fail2ban

# Installing essential packages
sudo apt-get -y install curl git-core

# Installing New Relic System Monitor
if [[ $monitoring_choice == 1 ]]
then
  curl 'http://download.newrelic.com/debian/newrelic.list' | sudo tee /etc/apt/sources.list.d/newrelic.list
  curl 'http://download.newrelic.com/548C16BF.gpg' | sudo apt-key add -
  sudo apt-get -y update
  sudo apt-get -y install newrelic-sysmond
  sudo nrsysmond-config --set license_key=$new_relic_api_key
  sudo /etc/init.d/newrelic-sysmond start
fi

# Installing NGINX
echo -e 'deb http://nginx.org/packages/ubuntu/ precise nginx\ndeb-src http://nginx.org/packages/ubuntu/ precise nginx' | sudo tee /etc/apt/sources.list.d/nginx.list
curl 'http://nginx.org/keys/nginx_signing.key' | sudo apt-key add -
sudo apt-get -y update
sudo apt-get -y install nginx
sudo cp support/nginx/nginx.conf /etc/nginx/nginx.conf
sudo mv /etc/nginx/conf.d /etc/nginx/sites-available
sudo mkdir /etc/nginx/sites-enabled
sudo service nginx start

# Installing the chosen database package
if [[ $db_choice == 1 ]]
then
  # Installing PostgreSQL
  echo 'deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main' | sudo tee /etc/apt/sources.list.d/pgdg.list
  curl 'https://www.postgresql.org/media/keys/ACCC4CF8.asc' | sudo apt-key add -
  sudo apt-get -y update
  sudo apt-get -y install postgresql libpq-dev
else
  # Installing MySQL
  sudo DEBIAN_FRONTEND=noninteractive apt-get -y install mysql-server mysql-client libmysqlclient-dev
  mysql -u root -e "DROP DATABASE 'test';"
  mysqladmin -u root password $mysql_password
fi

# Installing Postfix
if [[ $mail_choice == 1 ]]
then
  sudo DEBIAN_FRONTEND=noninteractive apt-get -y install postfix
  sudo cp support/postfix/main.cf /etc/postfix/main.cf
  sudo postconf -e "myhostname = $mail_domain"
  sudo postconf -e "mydomain = $mail_domain"
  sudo postconf -e "myorigin = $mail_domain"
  sudo service postfix restart
fi

# Setting up rbenv for Ruby and Rails
sudo apt-get -y install build-essential tklib zlib1g-dev libssl-dev libreadline-gplv2-dev libxml2 libxml2-dev libxslt1-dev
git clone git://github.com/sstephenson/rbenv.git ~/.rbenv
git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
git clone git://github.com/rkh/rbenv-update.git ~/.rbenv/plugins/rbenv-update
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.profile
echo 'eval "$(rbenv init -)"' >> ~/.profile
cp support/ruby/gemrc ~/.gemrc

echo ''
echo 'Installation Complete!'
echo 'Please reload your shell to update your path.'
