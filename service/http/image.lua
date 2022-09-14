local ngx = ngx

-- 获取 json 解析库
local cjson = require("cjson.safe");
local path = "/opt/application/image/"
local result = {}

-- 获取请求参数
ngx.req.read_body();

local args = ngx.req.get_body_data()
if args == nil then
  result.code = '1'
  result.msg = "未获取到图片"
  ngx.say(cjson.encode(result));
  return
end
ngx.log(ngx.DEBUG, "-----------------------------------------")
--ngx.log(ngx.DEBUG, args)

local image_info = cjson.decode(args)
local img_str = image_info.img_str
if img_str == nil then
  result.code = '1'
  result.msg = "未获取到图片"
  ngx.say(cjson.encode(result));
  return
end

assert(img_str ~= nil, "未获取到图片")
local md5 = ngx.md5(img_str)
local bytes = ngx.decode_base64(img_str)
-- ngx.log(ngx.DEBUG, bytes)
local filePath = path .. string.sub(md5, 0, 2) .. "/";
local filename = md5 .. '.jpg'
local proxyPath = "http://" .. ngx.var.host .. "/ocr/image/" .. string.sub(md5, 0, 2) .. "/" .. filename

local file, err = io.open(filePath .. filename, "w+b")
if file == nil then
  ngx.log(ngx.ERR, err)
  os.execute("mkdir -p " .. filePath)
  file = io.open(filePath .. filename, "w+b")
  -- result.code = '1'
  -- result.msg = "打开存储目录失败"
  -- ngx.say(cjson.encode(result))
  -- return
end
--io.output(file)
file:write(bytes)
file:close()

result.code = "0"
result.msg = proxyPath
ngx.say(cjson.encode(result));

--[[
fetch("http://122.112.196.230/image/store", {
  "headers": {
    "accept": "*/*",
    "accept-language": "zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6",
    "cache-control": "no-cache",
    "content-type": "application/json",
    "pragma": "no-cache"
  },
  "referrerPolicy": "strict-origin-when-cross-origin",
  "body": "{\n  \"request_id\":\"1231312324242424\",\n  \"img_str\": \"data:image/jpeg;base64,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\" \n}",
  "method": "POST",
  "mode": "cors",
  "credentials": "omit"
});

]]
