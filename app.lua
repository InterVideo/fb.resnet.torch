local lapis = require("lapis")
local respond_to = require("lapis.application").respond_to
local app = lapis.Application()


app:before_filter(function(self)
  -- Perform some security stuff?
end)

app:get("/", function()
  return "Welcome to ResNet-200 detection and feature extraction service."
end)

app:match('extract_features', '/extract-features', respond_to({
  GET = function(self)
    return { json = {result = 'Welcome to Feature Extractor' }}
  end,
  POST = function(self)
    return { json = {result = 'Welcome to Feature Extractor' }}
  end
}))

return app
