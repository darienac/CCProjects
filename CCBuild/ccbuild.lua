--Constants
local args = {...}

--Functions
local function loadFromPath(path, includedPaths)
    local page = http.get(path)
    local out = ""
    for line in page.readLine do
        if string.sub(line, 1, 3) == "---" then
            if string.sub(line, 1, 11) == "---include " then
                line = fs.combine(path, "..", string.sub(line, 12))
                print(line)
                if not includedPaths[line] then
                    includedPaths[line] = true
                    out = out .. "\n" .. loadFromPath(line, includedPaths)
                end
            end
        else
            out = out .. "\n" .. line
        end
    end
    page.close()
    return out
end

--Main
local f = fs.open(args[1], "w")
f.write(loadFromPath(args[2], {}))
f.close()