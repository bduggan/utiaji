
-- http://leafo.net/posts/creating_an_image_server.html

ngx.log(ngx.STDERR, "in thumbs.lua")

local sig, size, path, ext =
  ngx.var.sig, ngx.var.size, ngx.var.path, ngx.var.ext

local secret = "ioiasdfjj" -- signature secret key
local images_dir = "static/pim/up/" -- where images come from
local cache_dir = "static/pim/cache/" -- where images are cached

local function return_not_found(msg)
  ngx.status = ngx.HTTP_NOT_FOUND
  ngx.header["Content-type"] = "text/html"
  ngx.say(msg or "not found")
  ngx.exit(0)
end

local function calculate_signature(str)
  return ngx.encode_base64(ngx.hmac_sha1(secret, str))
    :gsub("[+/=]", {["+"] = "-", ["/"] = "_", ["="] = ","})
    :sub(1,12)
end

--if calculate_signature(size .. "/" .. path) ~= sig then
--  return_not_found("invalid signature")
--end

local source_fname = images_dir .. path

-- make sure the file exists
local file = io.open(source_fname)

if not file then
  ngx.log(ngx.STDERR, "not found: " .. source_fname)
  return_not_found()
end

file:close()

local dest_fname = cache_dir .. ngx.md5(size .. "/" .. path) .. "." .. ext

-- resize the image
local magick = require("magick")

ngx.log(ngx.STDERR, "generating thumbnail: " .. dest_fname)

magick.thumb(source_fname, size, dest_fname)

ngx.exec(ngx.var.request_uri)
