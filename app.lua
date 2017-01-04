local lapis = require('lapis')
local console = require('lapis.console')
local respond_to = require('lapis.application').respond_to
local capture_errors_json = require('lapis.application').capture_errors_json
local to_json = require('lapis.util').to_json
local from_json = require('lapis.util').from_json
local app = lapis.Application()


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
  POST = function(self)

    local username = tostring(self.params.username)
    local images = tostring(self.params.images)

    os.execute('echo TESTING PARAMETERS:')
    os.execute('echo ' .. username)
    os.execute('echo ' .. images)

    local data_folder = 'data/' .. username .. '/'
    os.execute('rm -rf ' .. data_folder)
    os.execute('mkdir ' .. data_folder)

    base64_images = images:split(',')

    for k, v in pairs(base64_images) do
      saveBase64AsImage(k, v, data_folder)
    end

    return { json = {result = to_json(self.params) }}
  end
})))

return app
