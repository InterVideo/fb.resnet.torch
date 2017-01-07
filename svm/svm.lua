require 'torch'
require 'optim'
require 'nn'
require 'cunn'


local svm = {}

function svm.__init()
    torch.setdefaulttensortype('torch.CudaTensor')
end

function svm.create_model(params)
    inputs = params.inputs or 2048

    model = nn.Sequential()
    model:add(nn.Linear(inputs, 1))
    model:add(nn.Euclidian(1, dimData))
    model:add(nn.Linear(dimData, 2))
    model:cuda()

    return model
end

function svm.train(model, data, criterion, config)
    learning_rate = config.learning_rate or 0.001
    weight_decay = config.weight_decay or 0
    momentum = config.momentum or 0.9
    learning_rate_decay = config.learning_rate_decay or 0

end

function svm.test(model, data)
    return model:forward(data)
end

function svm.prepare_data(data)

end

function argmax(v)
    local maxvalue = torch.max(v)
    for i = 1, v:size(1) do
        if v[i] == maxvalue then
            return i
        end
    end
end

function svm.main()
    params = {
        inputs = 2048
    }
    model = create_model(params)

    criterions = {
        HingeEmbedding = nn.HingeEmbeddingCriterion,
        L1HingeEmbedding = nn.L1HingeEmbeddingCriterion,
        CosineEmbedding = nn.CosineEmbeddingCriterion,
        Margin = nn.MarginCriterion,
        SoftMargin = nn.SoftMarginCriterion
    }

    options = {
        learningRate = 1e-3,
        weightDecay = 0,
        momentum = 0,
        learningRateDecay = 1e-4
    }

    criterion = criterions.Margin
    trainer = nn.StohasticGradient(model, criterion, options)

    data = prepare_data(data)
    trainer:train(data)
end

return svm
