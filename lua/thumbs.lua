
local path = ngx.var.path
local root = os.getenv('UTIAJI_HOME') .. '/static/pim'
local src = root .. '/up/' .. path
local dst = root .. '/cache/' .. path .. '.png'

local file = io.open(src)

if not file then
  ngx.log(ngx.STDERR, "source not found: " .. src)
  ngx.status = ngx.HTTP_NOT_FOUND
  ngx.say("not found")
  ngx.exit(0)
end
file:close()

ngx.log(ngx.STDERR, "generating thumbnail: " .. dst)
local magick = require("magick")
magick.thumb(src, '150x150', dst)
ngx.exec(ngx.var.request_uri)
