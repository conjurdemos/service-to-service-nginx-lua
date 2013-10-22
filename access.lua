-- Assume for simplicity that our location is a regex capturing 2 values, for the 
-- privilege and id.  In real life you might want to decouple this script 
-- from your nginx configuration details by setting variables to the captured values
-- instead of accessing them directly.
local privilege, resource_id = ngx.var[1], ngx.var[2]


-- Use the conjur authz service to check whether the authenticated user has the privilege
-- on a resource of kind "ngx-demo-service" and the given id.  The location /authz is 
-- a proxy to the conjur authz service.  In real life you might want to decouple nginx.conf
-- from this script by storing the location path in an nginx variable.
local location = string.format(
  "/authz/sandbox/resources/ngx-demo-service/%s?check&privilege=%s",
  resource_id, 
  privilege
)

-- This executes the request asynchronously in the sense that it doesn't block the 
-- nginx event loop, but blocks the current request until it completes.
local res = ngx.location.capture(location)
local status = res.status

-- Authz returns 2xx if the check passes.  We map 404 onto 403 for simplicity
-- and respond with 500 to errors other than 401 and 403.  Note that conjur
-- does not use 3xx redirects, so the status >= 300 check is fine.
if status >= 300 then
  ngx.log(ngx.ERR, string.format(
    "permission check of '%s' on 'sandbox:ngx-demo-service:%s' failed with %d", 
    privilege, 
    resource_id,
    status))

  if status == 401 then ngx.exit(401) 
  elseif status == 403 then ngx.exit(403)
  elseif status == 404 then ngx.exit(403)
  else ngx.exit(500) end
end

-- Permission granted, log it.  This should probably actually send the message to 
-- nginx's access.log, but I'm not sure what log level does that...
ngx.log(ngx.ERR, "allowing access to '" .. privilege .. "' '" .. resource_id .. "'")

-- Don't pass conjur auth token on to a potentially insecure backend
ngx.req.clear_header("Authorization")

-- Doing nothing in an access script allows the request to proceed
