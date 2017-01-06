local lapis = require('lapis')
local console = require('lapis.console')
local respond_to = require('lapis.application').respond_to
local json_params = require('lapis.application').json_params
local capture_errors_json = require('lapis.application').capture_errors_json
local to_json = require('lapis.util').to_json
local app = lapis.Application()

local extract_features = require('./pretrained/feature-extractor').extract_features

function saveBase64AsImage(file_name, img_base64, dir_path)
  os.execute(
    'echo -n ' .. tostring(img_base64) .. ' | base64 -d >> ' .. dir_path .. file_name .. '.jpg'
  )
end


function string:split(inSplitPattern, outResults)
  if not outResults then
    outResults = { }
  end
  local theStart = 1
  local theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
  while theSplitStart do
    table.insert( outResults, string.sub( self, theStart, theSplitStart-1 ) )
    theStart = theSplitEnd + 1
    theSplitStart, theSplitEnd = string.find( self, inSplitPattern, theStart )
  end
  table.insert( outResults, string.sub( self, theStart ) )
  return outResults
end


function serializeTable(val, name, skipnewlines, depth)
    skipnewlines = skipnewlines or false
    depth = depth or 0

    local tmp = string.rep(" ", depth)

    if name then tmp = tmp .. name .. " = " end

    if type(val) == "table" then
        tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

        for k, v in pairs(val) do
            tmp =  tmp .. serializeTable(v, k, skipnewlines, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
        end

        tmp = tmp .. string.rep(" ", depth) .. "}"
    elseif type(val) == "number" then
        tmp = tmp .. tostring(val)
    elseif type(val) == "string" then
        tmp = tmp .. string.format("%q", val)
    elseif type(val) == "boolean" then
        tmp = tmp .. (val and "true" or "false")
    else
        tmp = tmp .. "\"[inserializeable datatype:" .. type(val) .. "]\""
    end

    return tmp
end


app:before_filter(function(self)
  -- Perform some security stuff?
end)

app:get('/', function()
  return 'Welcome to ResNet-200 detection and feature extraction service.'
end)

app:match('/console', console.make())

app:match('extract_features', '/extract-features', capture_errors_json(respond_to({
  on_error = function(self)
    return { json = { result = to_json(self.errors), status = 500 } }
  end,
  GET = function(self)
    return { json = {result = 'Welcome to Feature Extractor' }}
  end,
  POST = json_params(function(self)

    -- print("SHIIIIIIIIIIIIIT")
    -- print(serializeTable(self.params.json))
    -- print("SHIIIIIIIIIIIIIT")
    -- print(serializeTable(self.params))
    -- os.execute('echo ' .. serializeTable(self.params) .. ' > test_params.txt')
    -- os.execute('echo STARTING SERIALIZATION')
    -- os.execute('echo ' .. serializeTable(self.params))

    local username = self.params.username
    local images = self.params.images

    local data_folder = 'data/' .. username .. '/'
    os.execute('rm -rf ' .. data_folder)
    os.execute('mkdir ' .. data_folder)

    base64_images = images:split(',')

    for k, v in pairs(base64_images) do
      saveBase64AsImage(k, v, data_folder)
    end


    os.execute('echo "--------------- STARTING THE FEATURE EXTRACTOR ---------------"')

    features = extract_features('pretrained/resnet-200.t7', data_folder:sub(1, -2), 1)
    os.execute('echo "FEATURES BELOW:"')
    os.execute('echo ' .. serializeTable(features))

    return { json = {features = to_json(features) }}
  end)
})))

return app
