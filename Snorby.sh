#!/bin/sh
# snorby.sh
# Ubuntu 16.04

#######################
#### Server update ####
#######################

# Optional: Insert a database hostname. Change X.X.X.X by the IP address from your database server

echo X.X.X.X	dbmysql >> /etc/hosts

clear

echo "\033[01;32m###### ###################### ######\033[01;37m"
echo "\033[01;32m######                        ######\033[01;37m"
echo "\033[01;32m######     /etc/hosts set     ######\033[01;37m"
echo "\033[01;32m######                        ######\033[01;37m"
echo "\033[01;32m###### ###################### ######\033[01;37m"

sleep 3

# Server update

clear

echo "\033[01;36m###### ############################ ######\033[01;37m"
echo "\033[01;36m######                              ######\033[01;37m"
echo "\033[01;36m######        System Updating       ######\033[01;37m"
echo "\033[01;36m######                              ######\033[01;37m"
echo "\033[01;36m###### ############################ ######\033[01;37m"

sleep 3

apt-get update
apt-get upgrade -y
apt-get autoremove -y

clear

echo "\033[01;32m###### ############################ ######\033[01;37m"
echo "\033[01;32m######                              ######\033[01;37m"
echo "\033[01;32m######        System updated        ######\033[01;37m"
echo "\033[01;32m######                              ######\033[01;37m"
echo "\033[01;32m###### ############################ ######\033[01;37m"

sleep 3

########################
#### SNORBY Install ####
########################

clear

echo "\033[01;36m###### ################ ######\033[01;37m"
echo "\033[01;36m######                  ######\033[01;37m"
echo "\033[01;36m######  Snorby install  ######\033[01;37m"
echo "\033[01;36m######                  ######\033[01;37m"
echo "\033[01;36m###### ################ ######\033[01;37m"

sleep 3

	# PREREQ

	apt-get install make imagemagick apache2 libyaml-dev libxml2-dev libxslt-dev git libmysqlclient-dev postgresql-server-dev-all libpq-dev libcurl4-openssl-dev libaprutil1-dev libapr1-dev apache2-dev libgdbm-dev libncurses5-dev git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libsqlite3-dev sqlite3 libxslt1-dev python-software-properties libffi-dev libapache2-mod-passenger gnupg -y

		# Ruby install

			# PREREQ
			
			echo "gem: --no-rdoc --no-ri" > ~/.gemrc
			sh -c "echo gem: --no-rdoc --no-ri > /etc/gemrc"

			# INSTALL

			cd /usr/src
			wget http://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.1.tar.gz
			tar -zxvf ruby-2.3.1.tar.gz
			cd ruby-2.3.1/
			./configure
			make
			make install

		# GEMS

			# PREREQ

			gem install wkhtmltopdf
			gem install bundler
			gem install rails
			gem install rake --version=11.1.2
			gem install pg
			gem install mysql
			gem install do_mysql -v '0.10.17'
			gem install do_postgres -v '0.10.17'
			gem install dm-postgres-adapter
			gem install passenger
			gem install net-dns

	# SNORBY INSTALL

	cd /usr/src
	git clone git://github.com/Snorby/snorby.git
	cp -r snorby/ /var/www/html/
	cd /var/www/html/snorby/

		# SNORBY MYSQL

		cp /var/www/html/snorby/config/database.yml.example /var/www/html/snorby/config/database.yml 
		sed -i 's,root,snort,g' /var/www/html/snorby/config/database.yml
		sed -i 's,Enter Password Here,lrGJGqY9JQ!,g' /var/www/html/snorby/config/database.yml
		sed -i 's,localhost,dbmysql,g' /var/www/html/snorby/config/database.yml
		cp /var/www/html/snorby/config/snorby_config.yml.example /var/www/html/snorby/config/snorby_config.yml
		sed -i s/"\/usr\/local\/bin\/wkhtmltopdf"/"\/usr\/bin\/wkhtmltopdf"/g /var/www/html/snorby/config/snorby_config.yml

			# MySQL Version

			cd /var/www/html/snorby
			sed -i 's,do_mysql (~> 0.10.6),do_mysql (~> 0.10.17),g' Gemfile.lock
			sed -i 's,do_mysql (0.10.16),do_mysql (0.10.17),g' Gemfile.lock
			bundle install
			bundle exec rake snorby:setup

# PHUSION PASSENGER

clear

echo "\033[01;31m###### ############################################### ######\033[01;37m"
echo "\033[01;31m######                                                 ######\033[01;37m"
echo "\033[01;31m######  Manual intervention required for this process  ######\033[01;37m"
echo "\033[01;31m######                                                 ######\033[01;37m"
echo "\033[01;31m###### ############################################### ######\033[01;37m"

sleep 3

passenger-install-apache2-module

#This last command will start the Phusion Passenger install wizard.
#Press Enter
#Using the arrow keys go to Python
#Press the Space bar to deselect Python
#Press Enter
#This will start compiling the software and it is going to take a while.
#When it finishes compiling, it will tell you to write some lines to the Apache configuration file

echo LoadModule passenger_module /usr/local/lib/ruby/gems/2.3.0/gems/passenger-5.2.0/buildout/apache2/mod_passenger.so > /etc/apache2/mods-available/passenger.load
echo PassengerRoot /usr/local/lib/ruby/gems/2.3.0/gems/passenger-5.2.0 > /etc/apache2/mods-available/passenger.conf
echo PassengerDefaultRuby /usr/local/bin/ruby >> /etc/apache2/mods-available/passenger.conf

a2enmod passenger
service apache2 restart
apache2ctl -t -D DUMP_MODULES

# SNORBY VIRTUALHOSTS

echo "<VirtualHost *:80>" > /etc/apache2/sites-available/001-snorby.conf
echo ServerAdmin admin@example.com >> /etc/apache2/sites-available/001-snorby.conf
echo ServerName snort-ids.example.com >> /etc/apache2/sites-available/001-snorby.conf
echo DocumentRoot /var/www/html/snorby/public >> /etc/apache2/sites-available/001-snorby.conf
echo "<Directory "/var/www/html/snorby/public">" >> /etc/apache2/sites-available/001-snorby.conf
echo AllowOverride all >> /etc/apache2/sites-available/001-snorby.conf
echo Order deny,allow >> /etc/apache2/sites-available/001-snorby.conf
echo Allow from all >> /etc/apache2/sites-available/001-snorby.conf
echo Options -MultiViews >> /etc/apache2/sites-available/001-snorby.conf
echo "</Directory>" >> /etc/apache2/sites-available/001-snorby.conf
echo "</VirtualHost>" >> /etc/apache2/sites-available/001-snorby.conf

cd /etc/apache2/sites-available/
a2ensite 001-snorby.conf
cd /etc/apache2/sites-enabled/
a2dissite 000-default.conf
service apache2 restart

# SNORBY SERVICE

echo [Unit] > /lib/systemd/system/snorby_worker.service
echo Description=Snorby Worker Daemon >> /lib/systemd/system/snorby_worker.service
echo Requires=apache2.service >> /lib/systemd/system/snorby_worker.service
echo After=syslog.target network.target apache2.service >> /lib/systemd/system/snorby_worker.service
echo [Service] >> /lib/systemd/system/snorby_worker.service
echo Type=forking >> /lib/systemd/system/snorby_worker.service
echo WorkingDirectory=/var/www/html/snorby >> /lib/systemd/system/snorby_worker.service
echo ExecStart=/usr/local/bin/ruby script/delayed_job start >> /lib/systemd/system/snorby_worker.service
echo [Install] >> /lib/systemd/system/snorby_worker.service
echo WantedBy=multi-user.target >> /lib/systemd/system/snorby_worker.service

cd /var/www/html/snorby/
bundle exec rake snorby:setup

systemctl enable snorby_worker
systemctl status snorby_worker.service

clear

echo "\033[01;32m###### ################ ######\033[01;37m"
echo "\033[01;32m######                  ######\033[01;37m"
echo "\033[01;32m###### Snorby instaled  ######\033[01;37m"
echo "\033[01;32m######                  ######\033[01;37m"
echo "\033[01;32m###### ################ ######\033[01;37m"

sleep 3

echo "\033[01;33m###### ################################## ######\033[01;37m"
echo "\033[01;33m######                                    ######\033[01;37m"
echo "\033[01;33m######   The system will reboot in 5 sec  ######\033[01;37m"
echo "\033[01;33m######                                    ######\033[01;37m"
echo "\033[01;33m###### ################################## ######\033[01;37m"

sleep 5

shutdown -r now