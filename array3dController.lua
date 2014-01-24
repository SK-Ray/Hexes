--[[
            
            array3dController.lua
            R.Delia @stinkykitties
            www.stinkykitties.com
            1-23-2013
            
            This thing should be able to take index 'looking' or coded values to get 0, and negative values represented inside of a table

--]]
local my3DArrayController = {}

local array3D  = {{{}}}

function my3DArrayController:addTo3DTextArray(x,y,z,value)
    
    local x = tostring(x)
    local y = tostring(y)
    local z = tostring(z)
    
    
    
    if array3D[x] == nil then
        array3D[x] = {}
    end
    
    if array3D[x][y] == nil then
        array3D[x][y] = {}
    end
    
    array3D[x][y][z] = value
    
end

function my3DArrayController:get3DValue(coord3d)
    
    local x = tostring(coord3d.x)
    local y = tostring(coord3d.y)
    local z = tostring(coord3d.z)
    
    
    local value = nil
    
    if array3D[x] == nil then
        return value
    end
    
    
    if array3D[x][y] == nil then
        array3D[x][y] = {}
    end
    
    if array3D[x][y][z] == nil then
        return value
    else
        value = array3D[x][y][z]
    end
    
    return value
    
end


function my3DArrayController:dumpArray()
    for i,v in pairs(array3D) do
        
        
        for j,w in pairs(v) do
            
            
            for k,x in pairs(w) do
                
            
                                    
                print("array3D[".. i .."][".. j .. "][".. k .. "] = Table")
              

                
            end
            
        end
        
        
    end
end

function my3DArrayController:clearArray()
    array3D = {}
end




return my3DArrayController
