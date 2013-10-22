Access control with Conjur, nginx, and lua
===========================================

This project is a simple example of fine grained access control to 
a web service using a Conjur permissions model, nginx and the nginx-lua
module.

Running the example
--------------------
You can run the project in a vm with vagrant.  

```sh
vagrant up
vagrant provision
```

The vagrant vm forwards requests to localhost:4567 to port 80 (nginx) on the guest, so 
once it's provisioned you can check that nginx is up and running like this:

```sh
$ curl localhost:4567
It works!
```

The sinatra service listens on 3535, which is also available from the host (a bad idea in 
real life!) on port 5353:

```sh
$ curl localhost:5353/foo/bar
Performed action 'foo' on 'bar'
```

How it works
------------
`ngx-demo-service.rb` is a toy sinatra service that pretends to perform various
actions on resources in response to requests like `GET /fry/bacon`, which would
correspond to performing the action `'fry'` on resource `'bacon'`.

The nginx config uses `access.lua` to perform authorization on a location that forwards
to the sinatra service.  The rule is that a user is authorized to request `/:privilege/:resource`
if they have privilege `privilege` on `ngx-demo-service:<resource>`.  The lua script uses
`ngx.location.capture` to make a request to the conjur authz service to check the permission
and decide whether or not to forward the request to the sinatra backend.

Trying it out
--------------

```sh
# namespace
export ns=`conjur id:create`

# Create users alice and bob
export alice_key=`conjur user:create -u $ns-alice | jsonfield api_key`
export bob_key=`conjur user:create -u $ns-bob | jsonfield api_key`

# Create a group and add both of them to it
conjur group:create $ns-people
conjur group:members:add $ns-people user:$ns-alice
conjur group:members:add $ns-people user:$ns-bob


# Create a couple of resources
conjur resource:create ngx-demo-service $ns-bacon
conjur resource:create ngx-demo-service $ns-eggs

# Permit alice to fry bacon and bob to scramble eggs, and let them both eat bacon and eggs
conjur resource:permit ngx-demo-service $ns-bacon user:$ns-alice fry
conjur resource:permit ngx-demo-service $ns-eggs user:$ns-bob scramble
conjur resource:permit ngx-demo-service $ns-bacon group:$ns-people eat
conjur resource:permit ngx-demo-service $ns-eggs group:$ns-people eat

# Login as alice and see what we're allowed to do
conjur authn:login -u $ns-alice -p $alice_key
# Try to fry bacon as alice, should succeed
curl -H "`conjur authn:authenticate -H`" localhost:4567/fry/$ns-/bacon
# Try to scramble eggs, should fail
curl -H "`conjur authn:authenticate -H`" localhost:4567/scramble/$ns-eggs
# But at least we can eat them!
curl -H "`conjur authn:authenticate -H`" localhost:4567/eat/$ns-eggs


# Login as bob to scramble the eggs
conjur authn:login -u $ns-bob -p $bob_key
# Try to scramble eggs, should succeed
curl -H "`conjur authn:authenticate -H`" localhost:4567/scramble/$ns-eggs
# But bob isn't allowed to fry bacon
curl -H "`conjur authn:authenticate -H`" localhost:4567/fry/$ns-bacon
```




