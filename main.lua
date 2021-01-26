local https = require 'ssl.https'
local gumbo = require 'gumbo'
local lfs = require 'lfs'


function getChapter(url)
    local res, code, headers, status = https.request(url)
    local doc =  gumbo.parse(res)
    local dirname = url:sub(1, #url - 1):match("([^/]+)$")
    lfs.mkdir(dirname)
    local head = doc:getElementsByTagName("head")[1]

    for k,v in ipairs(head:getElementsByTagName("meta")) do
        if v:hasAttribute("property") and v:hasAttribute("content") and v:getAttribute("property") == "og:image" then
            local url = v:getAttribute("content")
            local name = url:match( "([^/]+)$" )


            print("Downloading page : " .. name)

            local body, code = https.request(url)
            if not body then error(code) end

            local f = assert(io.open(dirname .. "/" .. name, 'wb'))
            f:write(body)
            f:close()

        end
    end
end

local res, code, headers, status = https.request(arg[1])
local doc = gumbo.parse(res)
local list = doc:getElementById("Chapters_List")

local urls = {}

for i, element in ipairs(list:getElementsByTagName("li")) do
    local href = element.firstChild:getAttribute("href")
    table.insert(urls, href)
end

for k,url in pairs(urls) do
    print("Downloading : " .. url:sub(1, #url - 1):match("([^/]+)$"))
    getChapter(url)
end
