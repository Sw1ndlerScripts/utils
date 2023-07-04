local cases = {
    ['string'] = function(value)
        return '"' .. value .. '"'
    end,
    ['function'] = function(value)
        local funcName = getinfo(value).name or 'nil'
        local name = '-- function ' .. funcName .. '()'

        return funcName .. " -- function " .. funcName .. "()"
    end,
    ['CFrame'] = function(value)
        local x = math.round(value.X)
        local y = math.round(value.Y)
        local z = math.round(value.Z)
        return 'CFrame.new(' .. tostring(x) .. ", " .. tostring(y) .. ", " .. tostring(z) .. ")"
    end,
    ['Vector3'] = function(value)
        local x = math.round(value.X)
        local y = math.round(value.Y)
        local z = math.round(value.Z)
        return 'Vector3.new(' .. tostring(x) .. ", " .. tostring(y) .. ", " .. tostring(z) .. ")"  
    end,
    ['Instance'] = function(value)
        return value.Name .. " | "  .. value:GetFullName()
    end,
    ['nil'] = function(value)
        return "nil"
    end
}

function stringify(value)
    local case = typeof(value)
    if cases[case] then
        return cases[case](value)
    end
    return tostring(value)
end

function stringifyTable(index, value)
    local newIndex = stringify(index)
    local newValue = stringify(value)

    if typeof(newIndex) == 'string' then
        newIndex = "[" .. newIndex .. "]"
    end

    if typeof(newValue) == 'string' then
        return newIndex .. " = " .. newValue
    elseif tostring(newIndex):find(":") == nil then
        return newIndex .. " = " .. tostring(newValue)
    else
        return newIndex .. " = " .. typeof(newValue) .. ": " .. tostring(newValue)
    end
end

local iterations = 0
getgenv().printTable = function(tbl, indent)
    local firstIteration = indent == nil

    if typeof(tbl) ~= 'table' then
        return print(stringify(tbl))
    end

    if firstIteration then
        iterations = 0
    else
        iterations = iterations + 1
    end


    if firstIteration then
        print("{")
    end
    local indent = indent or 4
    local spaces = string.rep(" ", indent)

    for i, value in pairs(tbl) do
        if typeof(value) == 'table' then
            if tostring(i) ~= '__index' then
                local newIndex = i
                if typeof(i) == 'Instance' then
                    newIndex = i:GetFullName()
                end

                print(spaces .. '["' .. tostring(newIndex) .. '"]' .. " = { ")
                printTable(value, indent + 4)
            end
        else
            local result = spaces .. stringifyTable(i, value)

            if i == #tbl then
                print(result)
            else
                print(result .. ",")
            end
        end
    end

    if firstIteration == false then
        print(string.rep(" ", indent - 4) ..  "},")
    else
        print("}")
    end
end


local copyIterations = 0
local stringStack = ""
getgenv().copyTable = function(tbl, indent)
    local firstIteration = (indent == nil)

    if indent == nil then
        stringStack = ""
    end

    if typeof(tbl) ~= 'table' then
        return setclipboard(stringify(tbl))
    end

    if firstIteration then
        copyIterations = 0
    else
        copyIterations = copyIterations + 1
    end


    if firstIteration then
        stringStack = stringStack .. "tbl = {" .. "\n"
    end
    
    local indent = indent or 4
    local spaces = string.rep(" ", indent)

    for i, value in pairs(tbl) do
        if typeof(value) == 'table' then
            if tostring(i) ~= '__index' then
                local newIndex = i
                if typeof(i) == 'Instance' then
                    newIndex = i:GetFullName()
                end

                stringStack = stringStack .. spaces .. '["' .. tostring(newIndex) .. '"]' .. " = { " .. "\n"
                copyTable(value, indent + 4)
            end
        else
            local result = spaces .. stringifyTable(i, value)

            if i == #tbl then
                stringStack = stringStack .. result .. "\n"
            else
                stringStack = stringStack .. result .. "," .. "\n"
            end
        end
    end

    if firstIteration == false then
        stringStack = stringStack .. string.rep(" ", indent - 4) ..  "}," .. "\n"
    else
        stringStack = stringStack .. "}"
        print("Copied table")
    	setclipboard(stringStack)
    end
end
