-- assume for simplicity that our location is a regex capturing 2 values, for the 
-- privilege and id
local privilege, resource_id = ngx.var[1], ngx.var[2]


-- use conjur authz to check whether the authenticated user has the privilege
-- on a resource of kind "ngx-demo-service" and the given id
local location = string.format(
  "/authz/sandbox/resources/ngx-demo-service/%s?check&privilege=%s",
  resource_id, 
  privilege
)
-- this executes asynchronously in the sense that it doesn't block the 
-- nginx event loop, but blocks the current request until it completes.
local res = ngx.location.capture(location)
local status = res.status

-- authz returns 2xx if the check passes, and 403 or 404 otherwise
-- we log error responses, but always exit with status 403
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

-- permission granted, log it
ngx.log(ngx.INFO, "allowing access to '" .. privilege .. "' '" .. resource_id .. "'")

-- don't pass conjur auth token on to a potentially insecure backend
ngx.req.clear_header("Authorization")

-- doing nothing in an access script allows the request to proceed
