
local data_preparation = {}

-- 'data' is an array of input 1x2048 vectors and its target classes.
--  {
--      { vector, class },
--      { vector, class },
--      .................
--  }
function data_preparation.prepare_data(data)
    result = ''
    for i = 1, #data do
        result = result .. prepare_single_vector(data[i][1], data[i][2]) .. '\n'
    end

    return result
end

function prepare_single_vector(vector, class)
    row = class > 0 and '+1' or '-1'
    for k, v in pairs(vector) do
        row = row .. ' ' .. k .. ':' .. v
    end

    return row
end


return data_preparation
