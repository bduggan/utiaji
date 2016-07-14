
function log(msg)
    ngx.log(ngx.STDERR, msg)
end

local sig, path, ext = ngx.var.sig, ngx.var.path, ngx.var.ext
local root = os.getenv('UTIAJI_HOME') .. '/static/pim'

log('path is ' .. path)

local images_dir = root .. "/up/" -- where images come from
local cache_dir = root .. "/cache/" -- where images are cached

local function return_not_found(msg)
  ngx.status = ngx.HTTP_NOT_FOUND
  ngx.header["Content-type"] = "text/html"
  ngx.say(msg or "not found")
  ngx.exit(0)
end

local source_fname = images_dir .. path
local file = io.open(source_fname)

if not file then
  ngx.log(ngx.STDERR, "source not found: " .. source_fname)
  return_not_found()
end
file:close()

local dest_fname = cache_dir .. path .. ".png"
local magick = require("magick")

ngx.log(ngx.STDERR, "generating thumbnail: " .. dest_fname)
magick.thumb(source_fname, '150x150', dest_fname)
ngx.exec(ngx.var.request_uri)
