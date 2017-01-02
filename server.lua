local http = require('http');
local fs = require('fs');
local JSON = require('json');


local server = http.createServer(function (req, res)
    getTitles(res)
end):listen(8080);

print('Server is running at http://127.0.0.1:8080/')

function getTitles(res)
    fs.readFile('./titles.json',
    function (err, data)
        print(data)
        if (err) then
            hadError(err, res);
        else
            getTemplate(JSON.parse(data), res);
        end
    end)
end

function getTemplate(titles, res)
    fs.readFile('./template.html', function (err, data)
        if (err) then
            hadError(err, res);
        else
            formatHtml(titles, data, res);
        end
    end)
end

function formatHtml(titles, tmpl, res)
    local str = table.concat(titles, '</li><li>')
    local html = tmpl:gsub('%%', str);
    
    res:writeHead(200, {['Content-Type'] = 'text/html'});
    res:finish(html);
end

function hadError(err, res)
    print(err);
    res:finish('Server Error');
end
