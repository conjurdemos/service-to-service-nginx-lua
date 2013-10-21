#!/bin/bash
alias conjur='bundle exec conjur'
ns=`conjur id:create`

echo "using namespace $ns"
mkdir -p assets

# Create some resources
conjur resource:create ngx-demo-service $ns-bacon | tee assets/bacon.json
conjur resource:create ngx-demo-service $ns-eggs | tee assets/eggs.json

# Create a couple of users
conjur user:create $ns-alice | tee assets/alice.json
conjur user:create $ns-bob | tee assets/bob.json

# Alice can fry bacon
conjur resource:permit ngx-demo-service $ns-bacon user:$ns-alice fry
# Bob can scramble eggs
conjur resource:permit ngx-demo-service $ns-eggs user:$ns-bob scramble

# They can both eat eggs and bacon
conjur resource:permit ngx-demo-service $ns-bacon user:$ns-alice eat
conjur resource:permit ngx-demo-service $ns-bacon user:$ns-bob eat
conjur resource:permit ngx-demo-service $ns-eggs user:$ns-alice eat
conjur resource:permit ngx-demo-service $ns-eggs user:$ns-bob eat
