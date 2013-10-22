-- Taken from https://github.com/stuartpb/tvtropes-lua

local string = require "string"
local table = require "table"

--Module table
local urlencode={}

--URL encode a string.
local function encodeString(str)
  if type(str) ~= 'string' then str = tostring(str) end

  --Ensure all newlines are in CRLF form
  str = string.gsub (str, "\r?\n", "\r\n")

  --Percent-encode all non-unreserved characters
  --as per RFC 3986, Section 2.3
  --(except for space, which gets plus-encoded)
  str = string.gsub (str, "([^%w%-%.%_%~ ])",
    function (c) return string.format ("%%%02X", string.byte(c)) end)

  --Convert spaces to plus signs
  str = string.gsub (str, " ", "+")

  return str
end

--Make this function available as part of the module
urlencode.string = encodeString

--URL encode a table as a series of parameters.
local function encodeTable(t)

  --table of argument strings
  local argts = {}

  --insertion iterator
  local i = 1

  --URL-encode every pair
  for k, v in pairs(t) do
    if type(v) ~= 'string' then v = tostring(v) end
    argts[i]=encodeString(k).."="..encodeString(v) -- no point in recursively encoding tables
    i=i+1
  end

  return table.concat(argts,'&')
end
urlencode.table = encodeTable

-- Variant that will encode either tables or primitives
local function encode(self, v)
  if type(v) == 'table' then return encodeTable(v) end
  return encodeString(v)
end



return setmetatable(urlencode, {__call = encode})