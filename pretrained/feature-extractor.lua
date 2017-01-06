require 'torch'
require 'paths'
require 'cudnn'
require 'cunn'
require 'image'
local t = require '../datasets/transforms'


local feature_extractor = {}

function feature_extractor.extract_features(model_name, dir_path, batch_size)
    -- get the list of files
    local list_of_filenames = {}

    -- for i=1, #list_of_base64_images do
    --     f = list_of_base64_images[i]
    --     table.insert(list_of_filenames, f)
    -- end

    local lfs  = require 'lfs'

    for file in lfs.dir(dir_path) do -- get the list of the files
        if file~="." and file~=".." then
            table.insert(list_of_filenames, dir_path .. '/' .. file)
        end
    end

    local number_of_files = #list_of_filenames

    if batch_size > number_of_files then batch_size = number_of_files end

    -- Load the model
    local model = torch.load(model_name):cuda()

    -- Remove the fully connected layer
    assert(torch.type(model:get(#model.modules)) == 'nn.Linear')
    model:remove(#model.modules)

    -- Evaluate mode
    model:evaluate()

    -- The model was trained with this input normalization
    local meanstd = {
        mean = { 0.485, 0.456, 0.406 },
        std = { 0.229, 0.224, 0.225 },
    }

    local transform = t.Compose{
        t.Scale(256),
        t.ColorNormalize(meanstd),
        t.CenterCrop(224),
    }

    local features

    for i=1, number_of_files, batch_size do
        local img_batch = torch.FloatTensor(batch_size, 3, 224, 224) -- batch numbers are the 3 channels and size of transform 

        -- preprocess the images for the batch
        local image_count = 0
        for j=1, batch_size do 
            img_name = list_of_filenames[i+j-1] 

            if img_name  ~= nil then
                image_count = image_count + 1

                local img = image.load(img_name, 3, 'float')
                img = transform(img)
                img_batch[{j, {}, {}, {} }] = img
            end
        end

        -- if this is last batch it may not be the same size, so check that
        if image_count ~= batch_size then
            img_batch = img_batch[{{1,image_count}, {}, {}, {} } ]
        end

    -- Get the output of the layer before the (removed) fully connected layer
    local output = model:forward(img_batch:cuda()):squeeze(1)


    -- this is necesary because the model outputs different dimension based on size of input
    if output:nDimension() == 1 then output = torch.reshape(output, 1, output:size(1)) end 

    if not features then
        features = torch.FloatTensor(number_of_files, output:size(2)):zero()
    end

    features[{ {i, i-1+image_count}, {}  } ]:copy(output)

    end

    return {features=torch.totable(features), image_list=list_of_filenames}
end

return feature_extractor
