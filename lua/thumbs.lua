
local root = os.getenv('UTIAJI_HOME') .. '/static/pim'
local path = ngx.var.path
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

local status, err = pcall(function() magick.thumb(src, '150x150', dst) end)

if not status then
    ngx.log(ngx.STDERR, "error generating thumbnail: " .. err)
    ngx.exec('/blank.png')
else
    ngx.exec(ngx.var.request_uri)
end

