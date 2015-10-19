sudo apt-get update
sudo apt-get upgrade
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
\curl -sSL https://get.rvm.io | bash -s stable --ruby
source /home/ubuntu/.rvm/scripts/rvm

gem install rails

sudo apt-get install imagemagick hugin vim zip nodejs libpq-dev rawtherapee sqlitebrowser

bundle install

rake db:migrate

rake db:populate
