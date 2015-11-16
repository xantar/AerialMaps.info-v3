AerialMaps.info

A Simple Adminless multi user Aerial Map gallery and processor.

AerialMaps.info is based on Ruby on Rails and utilized ImageMagick, Hugin & RawTheraPee to automatically correct and stitch Aerial Maps

It is intented to be used on an Ubuntu Distribution (14.04 LTS)
Using RVM for Ruby.

To Install (Fast):

1) ./install-rvm.sh

2) source /home/ubuntu/.rvm/scripts/rvm

3) ./install.sh

Install (Advanced):

1) gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
\curl -sSL https://get.rvm.io | bash -s stable --ruby

2) source /home/ubuntu/.rvm/scripts/rvm

3) gem install rails

4) sudo apt-get install imagemagick hugin vim zip nodejs libpq-dev rawtherapee sqlitebrowser

5) bundle install

6) rake db:migrate

7) rake db:populate

Configure:

- The profiles in /public/RTProfiles/
  o They assume that the app in installed in the home directory of the ubuntu user in an amazon EC2 instance
  o Changing LCPFile= to match the correct path is required.

- /config/initializers/omniauth.rb 
  o The OAuth details are stores here and need to be replaced 

- /app/models/map.rb
  o The Generate Method creates links to a predefined reference "aerialmaps.info" Change it to your URL
  