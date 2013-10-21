Access control with Conjur, nginx, and lua
===========================================

This project is a simple example of fine grained access control to 
a web service using a Conjur permissions model, nginx and the nginx-lua
module.

Running the example
--------------------
You can run the project in a vm with vagrant.  `$ vagrant up` will start the vm 
and run the servers.

The vagrant vm forwards requests to localhost:4567 to port 80 on the guest.

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