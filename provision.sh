#!/bin/bash
set -e

cd /vagrant
function say {
  echo " >>> $@"
}
function ok {
  echo "  ! OK"
}

say "installing packages..."
apt-get update
apt-get install -y nginx-extras curl git
ok

say "linking /etc/nginx/sites-enabled/default -> nginx.conf"
ln -sf /vagrant/nginx.conf /etc/nginx/sites-enabled/default
ok

say "(re)starting nginx service"
service nginx restart
ok

say "switching to non-root user"
su vagrant
ok
if [[ ! -x `which rvm` ]] ; then 
  say "installing rvm and ruby..."
  apt-get install -y curl
  curl -L https://get.rvm.io | sudo bash -s stable
  sudo usermod -a -G rvm vagrant
  ok
fi

say "setting ruby version and running bundler..."
source /etc/profile.d/rvm.sh
rvm use --install 2.0.0
bundle install
ok

say "creating conjur config file"
cp /vagrant/conjurrc ~/.conjurrc
ok

say "starting demo service"
mkdir -p var
./run-service.rb restart
ok

echo " **** DONE **** "