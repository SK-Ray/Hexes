--[[
    
        hexes.lua
        
        1-7-2014
        @stinkyKitties  www.stinkykitties.com
        
        Thanks to:
        
        Code converted from 
        http://www.redblobgames.com/grids/hexagons/#hex-to-pixel
        
        to LUA, specifically for the Corona SDK 
        This module can be used outside of the Corona SDK by replacing the bit. module
        
        
        @redblobgames   www.redblobgames.com
        @lavalevel      www.lavalevel.com
        
        Purpose:
        
        This module will contain functions pertaining to the 
        
        display,
        selection,
        navigation
        
        
        
        of hexes for hex style maps in games in lua


        It will include convienence functions for
        
        Coordinate conversion,
        blah,
        blah,
        blah,
        
        
--]]


display.setStatusBar( display.HiddenStatusBar )
display.setDefault ("magTextureFilter", "nearest") -- make it nice and pixeled


-- q = columns
-- r = rows
local bit = require("bit") 
local hexes = {}

--- Takes two known values to compute the third:
--- premise function
local function isOdd(myNumber)
    
    if (myNumber % 2) == 0 then
        return false
    else
        return true
    end
    
end


--x + y + z = 0
-- x = 0 - y - z
-- y = 0 - x - z
-- z = 0 - x - y 

local function fillBlank(known1,known2)
    return (0-known1 - known2)
end


--# convert cube to axial
--q = x
--r = z
local function cubeToAxial(params)
    local x,y,z = params.x,params.y,params.z
    local axialCoordinate = {}
    axialCoordinate.q = x
    axialCoordinate.r =z
    return axialCoordinate
end

--# convert axial to cube
--x = q
--z = r
--y = -x-z
local function axialToCube(params)
    local q,r = params.q, params.r
    local myX = q
    local myZ = r
    local myY = -myX -myZ
    local cubeCoordinate = {x=myX,y=myY,z=myZ}
    return cubeCoordinate
end

--# convert cube to odd-q offset
--q = x
--r = z + (x - (x&1)) / 2
local function cubeToOddQOffset(params)
    local x,y,z = params.x,params.y,params.z
    local rowColumn = {}
    rowColumn.q  = x 
    rowColumn.r =   z + ( x -  bit.band(x ,1 )    ) /2 
    
    return rowColumn
end

--# convert odd-q offset to cube
--x = q
--z = r - (q - (q&1)) / 2
--y = -x-z
---- *********** we are using this guy:
local function oddQOffsetToCube(params)
    local q,r = params.q, params.r
    local myX = (q )
    local myZ = r  - (q - bit.band(q,1))  /2    --modified all q to be q-1
    local myY = -myX - myZ
    local cubeCoordinate = {x=myX,y=myY,z=myZ}
    return cubeCoordinate
end


--new and improved evenQOffsetToCube
local function evenQOffsetToCube(params)
    local q,r = params.q, params.r
    local myX = (q )
    local myZ = r  - (q + bit.band(q,1))  /2    --modified all q to be q-1
    local myY = -myX - myZ
    local cubeCoordinate = {x=myX,y=myY,z=myZ}
    return cubeCoordinate
    
end


local function evenROffsetToCube(params)
    local q,r = params.q, params.r
    local myX = q - ( r + bit.band(r,1)) /2 
    local myZ = r  
    local myY = -myX - myZ
    local cubeCoordinate = {x=myX,y=myY,z=myZ}
    return cubeCoordinate
    
end

local function oddROffsetToCube(params)
    local q,r = params.q, params.r
    local myX = q - ( r - bit.band(r,1)) /2 
    local myZ = r  
    local myY = -myX - myZ
    local cubeCoordinate = {x=myX,y=myY,z=myZ}
    return cubeCoordinate
    
end





local offsetCood= {
    q = 92,
r=11}

local cubeCoord = oddQOffsetToCube(offsetCood)
print("original offset:" .. offsetCood.q , offsetCood.r)
print("Cube: ", cubeCoord.x,cubeCoord.y,cubeCoord.z)

local offsetBack =  cubeToOddQOffset(cubeCoord)
print("Offset Back:", offsetBack.q,offsetBack.r)


local TestAxialFromCube = cubeToAxial(cubeCoord)
print("Axial: ",TestAxialFromCube.q,TestAxialFromCube.r )

local cubeFromAxial = axialToCube(TestAxialFromCube)
print("Cube back: " ..cubeFromAxial.x,cubeFromAxial.y,cubeFromAxial.z)


local distanceBetween = function(firstObj, other)
    local foo = firstObj.cubeCoordinates
    local bar = other.cubeCoordinates
    
    
    
    local xDiff = math.abs(bar.x - foo.x) 
    local yDiff = math.abs(bar.y - foo.y) 
    local zDiff = math.abs(bar.z - foo.z)
    local maxXY = (xDiff > yDiff) and xDiff or yDiff
    local maxYZ = (yDiff > zDiff) and yDiff or zDiff 
    return (maxXY > maxYZ) and maxXY or maxYZ
end


--- ******************************************************************************************************************************************************************************************************************
local hexSize = 128
local spriteSize = 256
local topped = "pointy"
local offsetX = 90
local offsetY = 90
local myColumns = 50 -- ( display.actualContentHeight / hexSize) 
local myRows = 50 -- ( display.actualContentWidth  / hexSize ) 

local my3DArray = require("array3dController")

print("myColumns: " .. myColumns, "MyRows: " .. myRows)


local function findNeighbors(hex)
    local neighbors = {}
    local myX = hex.r
    local myY = hex.q    
    local colRow
    
    local neighborSouth = {}
    neighborSouth.q =     hex.axialCoordinates.q  + 0
    neighborSouth.r =     hex.axialCoordinates.r  + 1
    local neighborSouthCube = axialToCube(neighborSouth)
    table.insert(neighbors, {cube =neighborSouthCube, direction = "south"})
    
    local neighborSouthWest = {}
    neighborSouthWest.q =     hex.axialCoordinates.q  -1
    neighborSouthWest.r =     hex.axialCoordinates.r  + 1
    local neighborSouthWestCube = axialToCube(neighborSouthWest)
    table.insert(neighbors, {cube =neighborSouthWestCube, direction = "southwest"})
    
    local neighborSouthEast = {}
    neighborSouthEast.q =     hex.axialCoordinates.q  + 1
    neighborSouthEast.r =     hex.axialCoordinates.r  + 0
    local neighborSouthEastCube = axialToCube(neighborSouthEast)
    table.insert(neighbors, {cube =neighborSouthEastCube, direction = "southeast"})
    
    local neighborNorth= {}
    neighborNorth.q =     hex.axialCoordinates.q  + 0
    neighborNorth.r =     hex.axialCoordinates.r  -1
    local neighborNorthCube = axialToCube(neighborNorth)
    table.insert(neighbors,{cube =neighborNorthCube, direction = "north"})
    
    local neighborNorthWest = {}
    neighborNorthWest.q =     hex.axialCoordinates.q  -1
    neighborNorthWest.r =     hex.axialCoordinates.r  + 0
    local neighborNorthWestCube = axialToCube(neighborNorthWest)
    table.insert(neighbors, {cube =neighborNorthWestCube, direction = "northwest"})
    
    local neighborNorthEast = {}
    neighborNorthEast.q =     hex.axialCoordinates.q  + 1
    neighborNorthEast.r =     hex.axialCoordinates.r  - 1
    local neighborNorthEastCube = axialToCube(neighborNorthEast)
    table.insert(neighbors, {cube =neighborNorthEastCube, direction = "northeast"})
    
    -- colRow = cubeToOddQOffset( neighbor1Cube)
    -- return colRow.q , colRow.r  
    return neighbors
end


local hexList = {}

local function makeHex(x,y,r,q,dg,offsetType)
    local myHexagon = display.newImage("hex1.png")
    
    if offsetType == "oddR" or offsetType == "evenR" then
        myHexagon.rotation = 90
    end
    
    myHexagon.x = x
    myHexagon.y = y
    myHexagon.r = r
    myHexagon.q = q
    
    myHexagon.xScale, myHexagon.yScale = hexSize/spriteSize, hexSize/spriteSize
    
    
    local mask = graphics.newMask("hexMask.png")
    myHexagon.maskX = myHexagon.x - myHexagon.contentWidth * 0.5
    myHexagon.maskY = myHexagon.y  - myHexagon.contentHeight * 0.5
    
    if offsetType == "oddR" or offsetType == "evenR" then
        myHexagon.maskRotation = 90
    end
    
    --myHexagon.maskScaleX, myHexagon.maskScaleY = hexSize/spriteSize, hexSize/spriteSize
    
    myHexagon:setMask(mask)
    myHexagon.isHitTestMasked = true
    
    --if it is  the prototype, ignore it
    if q == nil then
        --do not play the reindeer games
    else
        if hexes[q] == nil then
            hexes[q] = {}
            
        end
        
        hexes[q][r] = myHexagon
        
        if offsetType == "oddQ" then
            myHexagon.cubeCoordinates =  oddQOffsetToCube( {q=q, r=r})
            
        end
        if offsetType == "evenQ" then
            myHexagon.cubeCoordinates =  evenQOffsetToCube( {q=q, r=r})
        end
        if offsetType == "oddR" then
            myHexagon.cubeCoordinates =  oddROffsetToCube( {q=q, r=r})
        end
        if offsetType == "evenR" then
            myHexagon.cubeCoordinates =  evenROffsetToCube( {q=q, r=r})
        end
        
        my3DArray:addTo3DTextArray(myHexagon.cubeCoordinates.x, myHexagon.cubeCoordinates.y, myHexagon.cubeCoordinates.z, myHexagon)
        
        myHexagon.axialCoordinates = cubeToAxial(myHexagon.cubeCoordinates)
        
        hexList[#hexList +1] = myHexagon
        
        function myHexagon:touch(event)
            
            
            
            if event.phase == "began" then
                print("Col: " .. myHexagon.q,"Row: " .. myHexagon.r)
                
                local directNeighbors  =   findNeighbors(myHexagon)
                for i,v in ipairs(directNeighbors) do
                    
                    local coord3d = v.cube
                    local hex = my3DArray:get3DValue(coord3d)
                    if hex then
                        hex:setFillColor(1,0,0)
                        
                    end
                end
                
                return true   --get rid of wierd artifacts when you click on edges
            end
            
            
            if event.phase == "ended" then
                
                
                myHexagon:setFillColor(math.random(0,255)/255,math.random(0,255)/255,math.random(0,255)/255, 1)
                --myHexagon:setFillColor(math.random(200,255)/255,0,0, 1)
                
                
                print("Col: " .. myHexagon.q,"Row: " .. myHexagon.r)
                print("axial q: " .. myHexagon.axialCoordinates.q," r: " .. myHexagon.axialCoordinates.r)
                print("cubic X: " .. myHexagon.cubeCoordinates.x," Y: " .. myHexagon.cubeCoordinates.y .. " z:" .. myHexagon.cubeCoordinates.z)
                local myCheckAxial = cubeToAxial(myHexagon.cubeCoordinates)
                print("check axial q: " .. myCheckAxial.q," r: " .. myCheckAxial.r)
                local myCheckRowCol = cubeToOddQOffset(myHexagon.cubeCoordinates)
                print("check offset q: " .. myCheckRowCol.q," r: " .. myCheckRowCol.r)
                
                --         Range functionality                
                --                for i,v in ipairs(hexList) do            
                --                    if distanceBetween(myHexagon, v) < 3 then
                --                        v:setFillColor(.2,1,.2)
                --                    end
                --                end
                
                return true
            end
        end
        myHexagon:addEventListener("touch", myHexagon)
    end
    
    
    
    if dg == nil then
        
    else
        dg:insert(myHexagon)
    end
    
    
    
    
    return myHexagon
end



-- set default screen background color to blue
display.setDefault( "background", 0, 0, 0 )

--  Prototype Hex, needed for width/height calculation
local myHex1 = makeHex(display.contentCenterX,display.contentCenterY,"oddQ")
myHex1.isVisible = false



local function makeOddQVerticalGrid(columns,rows,offsetX,offsetY,dg)
    local yMovementUp = - ( myHex1.height * (hexSize/spriteSize) /2)
    local yMovementDown =  ( myHex1.height * (hexSize/spriteSize) /2)
    local xMovementRight = (myHex1.width * (hexSize/spriteSize) * (3/4) )
    
    for i =1, rows do
        
        for j =1, columns do
            -- makeHex(display.contentCenterX+ (myHex1.width * (hexSize/spriteSize) * (3/4) ),display.contentCenterY +( myHex1.height * (hexSize/spriteSize) /2))
            if isOdd(j) then
                makeHex (offsetX + ( (j-1) *  xMovementRight   ) , offsetY + hexSize * ( i -1)  ,i-1,  j-1,dg ,"oddQ" )   --------------BIG CHANGE    i-1, j-1 seem to keep this aligned properly
            else
                makeHex(offsetX + ( (j-1) *  xMovementRight ) , offsetY + hexSize *  (i -1 ) + yMovementDown,i-1, j-1 ,dg, "oddQ" )
            end
            
        end
    end
    
end

local function makeEvenQVerticalGrid(columns,rows,offsetX,offsetY,dg)
    
    local yMovementUp =  ( myHex1.height * (hexSize/spriteSize) /2)
    local yMovementDown = - ( myHex1.height * (hexSize/spriteSize) /2)
    local xMovementRight = (myHex1.width * (hexSize/spriteSize) * (3/4) )
    
    for i =1, rows do
        
        for j =1, columns do
            -- makeHex(display.contentCenterX+ (myHex1.width * (hexSize/spriteSize) * (3/4) ),display.contentCenterY +( myHex1.height * (hexSize/spriteSize) /2))
            if isOdd(j) then
                makeHex (offsetX + ( (j-1) *  xMovementRight   ) , offsetY + hexSize * ( i -1)  ,i-1,  j-1,dg ,"evenQ" )   --------------BIG CHANGE    i-1, j-1 seem to keep this aligned properly
            else
                makeHex(offsetX + ( (j-1) *  xMovementRight ) , offsetY + hexSize *  (i -1 ) + yMovementDown,i-1, j-1 ,dg, "evenQ" )
            end
            
        end
    end
    
end

local function makeEvenRHorizontalGrid(columns,rows,offsetX,offsetY,dg)
    
    local yMovementUp =  ( myHex1.height * (hexSize/spriteSize) * (3/4))
    local yMovementDown =  ( myHex1.height * (hexSize/spriteSize) * (3/4))
    local xMovementRight = myHex1.width * (hexSize/spriteSize)
    
    for i =1, rows do
        
        for j =1, columns do
            -- makeHex(display.contentCenterX+ (myHex1.width * (hexSize/spriteSize) * (3/4) ),display.contentCenterY +( myHex1.height * (hexSize/spriteSize) /2))
            if isOdd(i) then
                makeHex (offsetX + ( (j-1) *  xMovementRight   )  + hexSize/2 , offsetY + yMovementDown * ( i -1)  ,i-1,  j-1,dg ,"evenR" )   --------------BIG CHANGE    i-1, j-1 seem to keep this aligned properly
            else
                makeHex (offsetX + ( (j-1) *  xMovementRight   ) , offsetY + yMovementDown * ( i -1)  ,i-1,  j-1,dg ,"evenR" )   --------------BIG CHANGE    i-1, j-1 seem to keep this aligned properly
            end
            
        end
    end
    
end

local function makeOddRHorizontalGrid(columns,rows,offsetX,offsetY,dg)
    
    local yMovementUp =  ( myHex1.height * (hexSize/spriteSize) * (3/4))
    local yMovementDown =  ( myHex1.height * (hexSize/spriteSize) * (3/4))
    local xMovementRight = myHex1.width * (hexSize/spriteSize)
    
    for i =1, rows do
        
        for j =1, columns do
            -- makeHex(display.contentCenterX+ (myHex1.width * (hexSize/spriteSize) * (3/4) ),display.contentCenterY +( myHex1.height * (hexSize/spriteSize) /2))
            if isOdd(i) then
                makeHex (offsetX + ( (j-1) *  xMovementRight   )  , offsetY + yMovementDown * ( i -1)  ,i-1,  j-1,dg ,"oddR" )   --------------BIG CHANGE    i-1, j-1 seem to keep this aligned properly
            else
                makeHex (offsetX + ( (j-1) *  xMovementRight   )  + hexSize/2  , offsetY + yMovementDown * ( i -1)  ,i-1,  j-1,dg ,"oddR" )   --------------BIG CHANGE    i-1, j-1 seem to keep this aligned properly
            end
            
        end
    end
    
end

local myDisplayGroup = display.newGroup()

local myContainer = display.newContainer( display.actualContentWidth, display.actualContentHeight  )
myContainer.anchorX = .5
myContainer.anchorY = .5
myContainer.x = display.contentCenterX
myContainer.y = display.contentCenterY
myContainer:insert( myDisplayGroup, true ) 

--makeOddQVerticalGrid( myColumns  ,myRows, offsetX - myContainer.width /2 ,offsetY - myContainer.height /2,myDisplayGroup)
--makeEvenQVerticalGrid( myColumns  ,myRows, offsetX - myContainer.width /2 ,offsetY - myContainer.height /2,myDisplayGroup)
--makeEvenRHorizontalGrid( myColumns  ,myRows, offsetX - myContainer.width /2 ,offsetY - myContainer.height /2,myDisplayGroup)
makeOddRHorizontalGrid( myColumns  ,myRows, offsetX - myContainer.width /2 ,offsetY - myContainer.height /2,myDisplayGroup)




local overlay = display.newRect(0, 0, display.contentWidth, display.contentHeight)
overlay.anchorX = 0
overlay.anchorY = 0
overlay.x,overlay.y = 0,0
overlay.isHitTestable = true
overlay.alpha = .0
overlay.moved = false
overlay.beginX = 0
overlay.beginY = 0
overlay.lastX =0
overlay.lastY =0



function overlay:touch(event)
    if event.phase == "began" then
        print(event.x,event.y)
        overlay.beginX,overlay.beginY = event.x,event.y 
        overlay.lastX,overlay.lastY=  event.x,event.y 
        
    end
    
    if event.phase == "moved" then
        local diffX = math.abs(event.x - overlay.beginX)
        local diffY = math.abs(event.y - overlay.beginY)
        
        if  overlay.moved == false then
            if ( diffX > 10) or (diffY > 10) then
                overlay.moved = true
            else
                --boogie until we move 10 px
                return
            end
        end
        
        myDisplayGroup.x = myDisplayGroup.x - (overlay.lastX - event.x)  / myContainer.xScale
        myDisplayGroup.y = myDisplayGroup.y - (overlay.lastY - event.y)  / myContainer.xScale
        
        overlay.lastX = event.x
        overlay.lastY = event.y
    end
    
    if event.phase == "ended" then
        
        if overlay.moved == true then
            
            overlay.moved = false
            --block tiles from getting the ended touch phase :)
            return true
        end
        
    end
    
end
overlay:addEventListener("touch", overlay)

hexes[0][0]:setFillColor(1,0,0)

--my3DArray:dumpArray()


local myHex = my3DArray:get3DValue({x=2,y=-2,z=0})

if myHex == nil then
    print("not a real hex")
else
    myHex:setFillColor(0,1,0) 
end



local myScaleDownButton = display.newRect(0, 0, 100, 100)
myScaleDownButton:setFillColor(1,.2, .2, 1)
myScaleDownButton.anchorX = 0
myScaleDownButton.anchorY = 0
myScaleDownButton.x,myScaleDownButton.y = 0,0

local myScale = 1.0

local zoomText = display.newText("Scale: " .. myScale   , -9990,-1900, 0, 0, native.systemFontBold , 64)
zoomText:setFillColor(0,0,1,1)
function zoomText:repositionWithNewText(myText,x,y)
    zoomText.text = myText
    zoomText.anchorX = 1
    zoomText.anchorY = 0
    zoomText.x = x
    zoomText.y =y 
    
end

function myScaleDownButton:touch(event)
    
    if event.phase == "began" then
        return true
    end
    
    if event.phase == "moved" then
        myScale = myScale - .1
        
        if myScale < 1 then
            myScale =1
        end
        
        myContainer.xScale = myScale
        myContainer.yScale = myScale
        zoomText:repositionWithNewText("Scale: " ..myScale ,display.actualContentWidth ,0)
        
        return true
    end
    
    if event.phase == "ended" then
        myScale = myScale - .1
        
        if myScale < 1 then
            myScale =1
        end
        
        myContainer.xScale = myScale
        myContainer.yScale = myScale
        zoomText:repositionWithNewText("Scale: " ..myScale ,display.actualContentWidth,0)
        
        return true
        
    end
end

local myScaleUputton = display.newRect(0, 0, 100, 100)
myScaleUputton:setFillColor(.2, 1, .2, 1)

myScaleUputton.anchorX = 0
myScaleUputton.anchorY = 0
myScaleUputton.x,myScaleUputton.y = 150,0

function myScaleUputton:touch(event)
    
    if event.phase == "began" then
        return true
    end
    
    if event.phase == "moved" then
        myScale = myScale + .1
        myContainer.xScale = myScale
        myContainer.yScale = myScale
        zoomText:repositionWithNewText("Scale: " ..myScale ,display.actualContentWidth ,0)
        
        return true
    end
    
    if event.phase == "ended" then
        myScale = myScale + .1
        myContainer.xScale = myScale
        myContainer.yScale = myScale
        zoomText:repositionWithNewText("Scale: " ..myScale ,display.actualContentWidth ,0)
        
        return true
    end
end

local myRotateRightButton = display.newRect(0, 0, 100, 100)
myRotateRightButton.direction = "right"

myRotateRightButton:setFillColor(1, 1, .2, 1)

myRotateRightButton.anchorX = 0
myRotateRightButton.anchorY = 0
myRotateRightButton.x,myRotateRightButton.y = 350,0

function myRotateRightButton:touch(event)
    
    if event.phase == "began" then
        return true
    end
    
    if event.phase == "moved" then
        myScale = myScale + .1
        myContainer.xScale = myScale
        myContainer.yScale = myScale
        zoomText:repositionWithNewText("Scale: " ..myScale ,display.actualContentWidth ,0)
        
        return true
    end
    
    if event.phase == "ended" then
        myScale = myScale + .1
        myContainer.xScale = myScale
        myContainer.yScale = myScale
        zoomText:repositionWithNewText("Scale: " ..myScale ,display.actualContentWidth ,0)
        
        return true
    end
end


local myRotateLeftButton = display.newRect(0, 0, 100, 100)
myRotateLeftButton.direction = "left"
myRotateLeftButton:setFillColor(.2, .3, .2, 1)

myRotateLeftButton.anchorX = 0
myRotateLeftButton.anchorY = 0
myRotateLeftButton.x,myRotateLeftButton.y = 450,0
function myRotateLeftButton:touch(event)
    
    if event.phase == "began" then
        return true
    end
    
    if event.phase == "moved" then
        myScale = myScale + .1
        myContainer.xScale = myScale
        myContainer.yScale = myScale
        zoomText:repositionWithNewText("Scale: " ..myScale ,display.actualContentWidth ,0)
        
        return true
    end
    
    if event.phase == "ended" then
        myScale = myScale + .1
        myContainer.xScale = myScale
        myContainer.yScale = myScale
        zoomText:repositionWithNewText("Scale: " ..myScale ,display.actualContentWidth ,0)
        
        return true
    end
end

local function  rotationHandler(event)
    
    if event.phase == "began" then
        return true
        
    elseif event.phase == "moved" then
        if event.target.direction == "right" then
            myContainer.rotation = myContainer.rotation - 6
            
        else
            myContainer.rotation = myContainer.rotation + 6
        end
        return true
    elseif event.phase == "ended" then
        if event.target.direction == "right" then
            myContainer.rotation = myContainer.rotation - 6
            
        else
            myContainer.rotation = myContainer.rotation + 6
        end
        return true
    end
    
end


myScaleDownButton:addEventListener("touch", myScaleDownButton)
myScaleUputton:addEventListener("touch", myScaleUputton)
myRotateRightButton:addEventListener("touch", rotationHandler)
myRotateLeftButton:addEventListener("touch", rotationHandler)



----OLD  redo later

--# convert cube to even-r offset
--q = x + (z + (z&1)) / 2
--r = z
--                    local function cubeToEvenROffset(x,y,z)
--                        local axialCoordinate = {}
--                        axialCoordinate.q  = x +  ( z+  ( bit.band(z,1) ) ) /2
--                        axialCoordinate.r =  z 
--                        return axialCoordinate
--                    end

--# convert even-r offset to cube
--x = q - (r + (r&1)) / 2
--z = r
--y = -x-z
--                    local function evenROffsetToCube(q,r)
--                        local myX = q -( r + bit.band(r,1) ) /2
--                        local myZ = r  
--                        local myY = -myX -myZ
--                        local cubeCoordinate = {x=myX,y=myY,z=myZ}
--                        return cubeCoordinate
--                    end


--# convert cube to odd-r offset
--q = x + (z - (z&1)) / 2
--r = z
--                    local function cubeToOddROffset(x,y,z)
--                        local axialCoordinate = {}
--                        axialCoordinate.q  = x +  ( z-  ( bit.band(z,1) ) ) /2
--                        axialCoordinate.r =  z 
--                        return axialCoordinate
--                    end


--# convert cube to even-q offset
--q = x
--r = z + (x + (x&1)) / 2

--                    local function cubeToEvenQOffset(x,y,z)
--
--                        local axialCoordinate = {}
--                        axialCoordinate.q  = x
--                        axialCoordinate.r =  z + ( x + (  bit.band(x ,1 ) )   ) /2
--                        return axialCoordinate
--                    end

--# convert even-q offset to cube
--x = q
--z = r - (q + (q&1)) / 2
--y = -x-z
--                        local function evenQOffsetToCube(q,r)
--                            local myX = q -1
--                            local myZ = r -1 - (q + bit.band(q,1) ) /2
--                            local myY = -myX -myZ
--                            local cubeCoordinate = {x=myX,y=myY,z=myZ}
--                            return cubeCoordinate
--                        end


--# convert odd-r offset to cube
--x = q - (r - (r&1)) / 2
--z = r
--y = -x-z

--local function oddROffsetToCube(r,q)
--    local myX = q -( r -  bit.band(r,1) ) /2
--    local myZ = r  
--    local myY = -myX -myZ
--    local cubeCoordinate = {x=myX,y=myY,z=myZ}
--    return cubeCoordinate
--end




-----Test functions

--[[
print("Fill blank:",fillBlank(12,4))

--------
local convert1 = cubeToAxial(10, -11, 1)
print("Cube to axial:" , convert1.q,convert1.r)

local convert2 = axialToCube(0,-3)
print("Axial to Cube",convert2.x,convert2.y,convert2.z)


-------
local convert3 = cubeToEvenQOffset(10, -11, 1)
print("Cube to Even Columns Offset",convert3.q,convert3.r)

local convert4 = evenQOffsetToCube(10,6)
print("Even Columns Offset to Cube ",convert4.x,convert4.y,convert4.z)

local convert = cubeToOddQOffset(10, -11, 1)
print("Cube to odd Columns Offset",convert.q,convert.r)

local convert = oddQOffsetToCube(10,6)
print("Odd Columns Offset to Cube ",convert.x,convert.y,convert.z)

--------
local convert4 = cubeToEvenROffset(10, -11, 1)
print("Cube to Even Rows Offset",convert4.q,convert4.r)

local convert5 = evenROffsetToCube(11,1)
print("Even Rows Offset to Cube ",convert5.x,convert5.y,convert5.z)


local convert4 = cubeToOddROffset(8,-23,15)
print("Cube to odd Rows Offset  " ,convert4.q,convert4.r)

local convert5 = oddROffsetToCube(15,15)
print("Odd Rows Offset to Cube ",convert5.x,convert5.y,convert5.z)

--]]
