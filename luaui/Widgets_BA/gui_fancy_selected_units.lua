function widget:GetInfo()
   return {
      name      = "Fancy Selected Units",		--(took 'UnitShapes' widget as a base for this one)
      desc      = "Shows which units are selected",
      author    = "Floris",
      date      = "04.04.2014",
      license   = "GNU GPL, v2 or later",
      layer     = 2,
      enabled   = false
   }
end



--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local clearquad
local shapes = {}

local rad_con						= 180 / math.pi

local UNITCONF						= {}

local currentRotationAngle			= 0
local currentRotationAngleOpposite	= 0
local previousOsClock				= os.clock()

local animationMultiplier			= 1
local animationMultiplierInner		= 1
local animationMultiplierAdd		= true

local defaultEngineSelection		= true

local selectedUnits					= {}
local perfSelectedUnits				= {}

local maxSelectTime					= 0				--time at which units "new selection" animation will end
local maxDeselectedTime				= -1			--time at which units deselection animation will end

local currentOption					= 5

local glCallList					= gl.CallList
local glDrawListAtUnit				= gl.DrawListAtUnit

local spIsUnitSelected				= Spring.IsUnitSelected
local spGetSelectedUnitsCount		= Spring.GetSelectedUnitsCount
local spGetSelectedUnitsSorted		= Spring.GetSelectedUnitsSorted
local spGetUnitTeam					= Spring.GetUnitTeam
local spLoadCmdColorsConfig			= Spring.LoadCmdColorsConfig
local spGetUnitDirection			= Spring.GetUnitDirection
local spGetCameraPosition			= Spring.GetCameraPosition
local spGetUnitViewPosition			= Spring.GetUnitViewPosition
local spGetUnitDefID				= Spring.GetUnitDefID
local spIsGUIHidden					= Spring.IsGUIHidden
local spGetTeamColor				= Spring.GetTeamColor
local spGetUnitHealth 				= Spring.GetUnitHealth
local spGetUnitIsCloaked			= Spring.GetUnitIsCloaked
local spUnitInView                  = Spring.IsUnitInView
local spIsUnitVisible				= Spring.IsUnitVisible

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local OPTIONS = {}
OPTIONS.defaults = {	-- these will be loaded when switching style, but the style will overwrite the those values 
	name							= "Defaults",
	-- Quality settings
	showNoOverlap					= false,	-- set true for no line overlapping
	showBase						= true,
	showFirstLine					= true,
	showFirstLineDetails			= true,
	showSecondLine					= false,
	showExtraComLine				= true,		-- extra circle lines for the commander unit
	showExtraBuildingWeaponLine		= true,
	
	-- opacity
	spotterOpacity					= 0.9,
	spotterOpacityMin				= 0.3,		-- minimum value before a platter will be added
	baseOpacity						= 0.25,
	firstLineOpacity				= 1,
	secondLineOpacity				= 1.1,
	
	-- animation
	selectionStartAnimation			= true,
	selectionStartAnimationTime		= 0.045,
	selectionStartAnimationScale	= 0.82,
	-- selectionStartAnimationScale	= 1.17,
	selectionEndAnimation			= true,
	selectionEndAnimationTime		= 0.07,
	selectionEndAnimationScale		= 0.9,
	--selectionEndAnimationScale	= 1.17,
	
	-- animation
	rotationSpeed					= 1,
	animationSpeed					= 0.0006,	-- speed of scaling up/down inner and outer lines
	animateSpotterSize				= true,
	maxAnimationMultiplier			= 1.014,
	minAnimationMultiplier			= 0.99,
	
	-- prefer not to change because other widgets use these values too  (highlight_units, given_units, selfd_icons, ...)
	scaleFactor						= 2.9,			
	rectangleFactor					= 3.3,
	
	-- circle shape
	solidCirclePieces				= 32,
	circlePieces					= 24,
	circlePieceDetail				= 1,		-- smoothness of each piece (1 or higher)
	circleSpaceUsage				= 0.7,		-- 1 = whole circle space gets filled
	circleInnerOffset				= 0.45,
	
	-- size
	scaleMultiplier					= 1.04,
	innersize						= 1.7,
	selectinner						= 1.66,
	outersize						= 1.79,
}
table.insert(OPTIONS, {
	name							= "Cheap Fill",
	showFirstLineDetails			= false,
	rotationSpeed					= 0,
	baseOpacity						= 0.4,
})
table.insert(OPTIONS, {
	name							= "Tilted Blocky Dots",
	circlePieces					= 36,
	circlePieceDetail				= 1,
	circleSpaceUsage				= 0.7,
	circleInnerOffset				= 0.45,
})
table.insert(OPTIONS, {
	name							= "Blocky Dots",
	circlePieces					= 40,
	circlePieceDetail				= 1,
	circleSpaceUsage				= 0.55,
	circleInnerOffset				= 0,
	rotationSpeed					= 1,
})
table.insert(OPTIONS, {
	name							= "Stretched Blocky Dots",
	circlePieces					= 22,
	circlePieceDetail				= 4,
	circleSpaceUsage				= 0.28,
	circleInnerOffset				= 1,
})
table.insert(OPTIONS, {
	name							= "Curvy Lines",
	circlePieces					= 5,
	circlePieceDetail				= 7,
	circleSpaceUsage				= 0.7,
	circleInnerOffset				= 0,
	rotationSpeed					= 1.8,
})
table.insert(OPTIONS, {
	name							= "Curvy Lines 2",
	circlePieces					= 7,
	circlePieceDetail				= 4,
	circleSpaceUsage				= 0.7,
	circleInnerOffset				= 0,
	rotationSpeed					= 2.5,
})

function table.shallow_copy(t)
	local t2 = {}
	for k,v in pairs(t) do
		t2[k] = v
	end
	return t2
end
OPTIONS_original = table.shallow_copy(OPTIONS)
OPTIONS_original.defaults = nil

------------------------------------------------------------------------------------
------------------------------------------------------------------------------------


local function toggleOptions()
	currentOption = currentOption + 1
	if not OPTIONS[currentOption] then
		currentOption = 1
	end
	loadConfig()
end


local function updateSelectedUnitsData()
	
	-- remove deselected units 
	local clockDifference
	for teamID,_ in pairs(selectedUnits) do
		for unitID,_ in pairs(selectedUnits[teamID]) do
			if not spIsUnitSelected(unitID) and selectedUnits[teamID][unitID]['selected'] then
				clockDifference = OPTIONS[currentOption].selectionStartAnimationTime - (currentClock - selectedUnits[teamID][unitID]['new'])
				if clockDifference < 0 then
					clockDifference = 0
				end
				selectedUnits[teamID][unitID]['selected'] = false 
				selectedUnits[teamID][unitID]['new'] = false
				selectedUnits[teamID][unitID]['old'] = currentClock - clockDifference
			end
		end
	end
	
	-- add selected units
	if spGetSelectedUnitsCount() > 0 then
		local units = spGetSelectedUnitsSorted()
		local clockDifference, unit, unitID
		for uDID,_ in pairs(units) do
			if uDID ~= 'n' then --'n' returns table size
				for i=1,#units[uDID] do
					unitID = units[uDID][i]
					unit = UNITCONF[uDID]
					if (unit) then
						teamID = spGetUnitTeam(unitID)
						if not selectedUnits[teamID] then
							selectedUnits[teamID] = {}
						end
						if not selectedUnits[teamID][unitID] then
							selectedUnits[teamID][unitID]			= {}
							selectedUnits[teamID][unitID]['new']	= currentClock
						elseif selectedUnits[teamID][unitID]['old'] then
							clockDifference = OPTIONS[currentOption].selectionEndAnimationTime - (currentClock - selectedUnits[teamID][unitID]['old'])
							if clockDifference < 0 then
								clockDifference = 0
							end
							selectedUnits[teamID][unitID]['new']	= currentClock - clockDifference
							selectedUnits[teamID][unitID]['old']	= nil
						end
						selectedUnits[teamID][unitID]['selected']	= true
					end
				end
			end
		end
	end
	
	-- creates has blinking problem
	--[[ create new table that has iterative keys instead of unitID (to speedup after about 300 different units have ever been selected)
	perfSelectedUnits = {}
	for teamID,_ in pairs(selectedUnits) do
		perfSelectedUnits[teamID] = {}
		for unitID,_ in pairs(selectedUnits[teamID]) do
			table.insert(perfSelectedUnits[teamID], unitID)
		end
		perfSelectedUnits[teamID]['totalUnits'] = table.getn(perfSelectedUnits[teamID])
	end
	]]--
end


local function SetupCommandColors(state)
	local alpha = state and 1 or 0
	spLoadCmdColorsConfig('unitBox  0 1 0 ' .. alpha)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- Creating polygons:
local function CreateDisplayLists(callback)
	local displayLists = {}
	
	displayLists.select = callback.fading(OPTIONS[currentOption].outersize, OPTIONS[currentOption].selectinner)
	displayLists.inner = callback.solid({0, 0, 0, 0}, OPTIONS[currentOption].innersize)
	displayLists.large = callback.solid(nil, OPTIONS[currentOption].selectinner)
	displayLists.shape = callback.fading(OPTIONS[currentOption].innersize, OPTIONS[currentOption].selectinner)
	
	return displayLists
end



local function DrawCircleLine(innersize, outersize)
	gl.BeginEnd(GL.QUADS, function()
		local detailPartWidth, a1,a2,a3,a4
		local width = OPTIONS[currentOption].circleSpaceUsage
		local detail = OPTIONS[currentOption].circlePieceDetail

		local radstep = (2.0 * math.pi) / OPTIONS[currentOption].circlePieces
		for i = 1, OPTIONS[currentOption].circlePieces do
			for d = 1, detail do
				
				detailPartWidth = ((width / detail) * d)
				a1 = ((i+detailPartWidth - (width / detail)) * radstep)
				a2 = ((i+detailPartWidth) * radstep)
				a3 = ((i+OPTIONS[currentOption].circleInnerOffset+detailPartWidth - (width / detail)) * radstep)
				a4 = ((i+OPTIONS[currentOption].circleInnerOffset+detailPartWidth) * radstep)
				
				--outer (fadein)
				gl.Vertex(math.sin(a4)*innersize, 0, math.cos(a4)*innersize)
				gl.Vertex(math.sin(a3)*innersize, 0, math.cos(a3)*innersize)
				--outer (fadeout)
				gl.Vertex(math.sin(a1)*outersize, 0, math.cos(a1)*outersize)
				gl.Vertex(math.sin(a2)*outersize, 0, math.cos(a2)*outersize)
			end
		end
	end)
end

local function DrawCircleSolid(size)
	gl.BeginEnd(GL.TRIANGLE_FAN, function()
		local pieces = OPTIONS[currentOption].solidCirclePieces
		local radstep = (2.0 * math.pi) / pieces
		local a1
		if (color) then
			gl.Color(color)
		end
		gl.Vertex(0, 0, 0)
		for i = 0, pieces do
			a1 = (i * radstep)
			gl.Vertex(math.sin(a1)*size, 0, math.cos(a1)*size)
		end
	end)
end

local function CreateCircleLists()
	local callback = {}
	
	function callback.fading(innersize, outersize)
		return gl.CreateList(DrawCircleLine, innersize, outersize)
	end
	
	function callback.solid(color, size)
		return gl.CreateList(DrawCircleSolid, size)
	end
	
	shapes.circle = CreateDisplayLists(callback)
end



local function DrawSquareLine(innersize, outersize)
	
	gl.BeginEnd(GL.QUADS, function()
		local radstep = (2.0 * math.pi) / 4
		local width, a1,a2,a2_2
		for i = 1, 4 do
			-- straight piece
			width = 0.7
			i = i + 0.65
			a1 = (i * radstep)
			a2 = ((i+width) * radstep)
			
			gl.Vertex(math.sin(a2)*innersize, 0, math.cos(a2)*innersize)
			gl.Vertex(math.sin(a1)*innersize, 0, math.cos(a1)*innersize)
			
			gl.Vertex(math.sin(a1)*outersize, 0, math.cos(a1)*outersize)
			gl.Vertex(math.sin(a2)*outersize, 0, math.cos(a2)*outersize)
			
			-- corner piece
			width = 0.3
			i = i + 3
			a1 = (i * radstep)
			a2 = ((i+width) * radstep)
			i = i -0.6
			a2_2 = ((i+width) * radstep)
			
			gl.Vertex(math.sin(a2_2)*innersize, 0, math.cos(a2_2)*innersize)
			gl.Vertex(math.sin(a1)*innersize, 0, math.cos(a1)*innersize)
			
			gl.Vertex(math.sin(a1)*outersize, 0, math.cos(a1)*outersize)
			gl.Vertex(math.sin(a2_2)*outersize, 0, math.cos(a2_2)*outersize)
		end
	end)
end

local function DrawSquareSolid(size)
	gl.BeginEnd(GL.TRIANGLE_FAN, function()
		local width, a1,a2,a2_2
		local radstep = (2.0 * math.pi) / 4
		
		gl.Vertex(0, 0, 0)
		
		for i = 1, 4 do
			--straight piece
			width = 0.7
			i = i + 0.65
			a1 = (i * radstep)
			a2 = ((i+width) * radstep)
			
			gl.Vertex(math.sin(a2)*size, 0, math.cos(a2)*size)
			gl.Vertex(math.sin(a1)*size, 0, math.cos(a1)*size)
			
			--corner piece
			width = 0.3
			i = i + 3
			a1 = (i * radstep)
			a2 = ((i+width) * radstep)
			i = i -0.6
			a2_2 = ((i+width) * radstep)
			
			gl.Vertex(math.sin(a2_2)*size, 0, math.cos(a2_2)*size)
			gl.Vertex(math.sin(a1)*size, 0, math.cos(a1)*size)
		end
		
	end)
end

local function CreateSquareLists()
	
	local callback = {}
	
	function callback.fading(innersize, outersize)
		return gl.CreateList(DrawSquareLine, innersize, outersize)
	end
	
	function callback.solid(color, size)
		return gl.CreateList(DrawSquareSolid, size)
	end
	shapes.square = CreateDisplayLists(callback)
end



local function DrawTriangleLine(innersize, outersize)
	gl.BeginEnd(GL.QUADS, function()
		local width, a1,a2,a2_2
		local radstep = (2.0 * math.pi) / 3
		
		for i = 1, 3 do
			--straight piece
			width = 0.7
			i = i + 0.65
			a1 = (i * radstep)
			a2 = ((i+width) * radstep)
			
			gl.Vertex(math.sin(a2)*innersize, 0, math.cos(a2)*innersize)
			gl.Vertex(math.sin(a1)*innersize, 0, math.cos(a1)*innersize)
			
			gl.Vertex(math.sin(a1)*outersize, 0, math.cos(a1)*outersize)
			gl.Vertex(math.sin(a2)*outersize, 0, math.cos(a2)*outersize)
			
			-- corner piece
			width = 0.3
			i = i + 3
			a1 = (i * radstep)
			a2 = ((i+width) * radstep)
			i = i -0.6
			a2_2 = ((i+width) * radstep)
			
			gl.Vertex(math.sin(a2_2)*innersize, 0, math.cos(a2_2)*innersize)
			gl.Vertex(math.sin(a1)*innersize, 0, math.cos(a1)*innersize)
			
			gl.Vertex(math.sin(a1)*outersize, 0, math.cos(a1)*outersize)
			gl.Vertex(math.sin(a2_2)*outersize, 0, math.cos(a2_2)*outersize)
		end
		
	end)
end

local function DrawTriangleSolid(size)	
	
	gl.BeginEnd(GL.TRIANGLE_FAN, function()
		
		local width, a1,a2,a2_2
		local radstep = (2.0 * math.pi) / 3
		
		gl.Vertex(0, 0, 0)
		
		for i = 1, 3 do
			-- straight piece
			width = 0.7
			i = i + 0.65
			a1 = (i * radstep)
			a2 = ((i+width) * radstep)
			
			gl.Vertex(math.sin(a2)*size, 0, math.cos(a2)*size)
			gl.Vertex(math.sin(a1)*size, 0, math.cos(a1)*size)
			
			-- corner piece
			width = 0.3
			i = i + 3
			a1 = (i * radstep)
			a2 = ((i+width) * radstep)
			i = i -0.6
			a2_2 = ((i+width) * radstep)
			
			gl.Vertex(math.sin(a2_2)*size, 0, math.cos(a2_2)*size)
			gl.Vertex(math.sin(a1)*size, 0, math.cos(a1)*size)
		end
		
	end)
end

local function CreateTriangleLists()
	
	local callback = {}
	
	function callback.fading(innersize, outersize)
		return gl.CreateList(DrawTriangleLine, innersize, outersize)
	end
	
	function callback.solid(color, size)
		return gl.CreateList(DrawTriangleSolid, size)
	end
	shapes.triangle = CreateDisplayLists(callback)
end


local function DestroyShape(shape)
	gl.DeleteList(shape.select)
	gl.DeleteList(shape.inner)
	gl.DeleteList(shape.large)
	gl.DeleteList(shape.shape)
end



function widget:Initialize()

	loadConfig()
	
	clearquad = gl.CreateList(function()
		local size = 1000
		gl.BeginEnd(GL.QUADS, function()
			gl.Vertex( -size,0,  			-size)
			gl.Vertex( Game.mapSizeX+size,0, -size)
			gl.Vertex( Game.mapSizeX+size,0, Game.mapSizeZ+size)
			gl.Vertex( -size,0, 			Game.mapSizeZ+size)
		end)
	end)
	
	currentClock = os.clock()

	WG['fancyselectedunits'] = {}
	WG['fancyselectedunits'].getOpacity = function()
		return OPTIONS[currentOption].spotterOpacity
	end
	WG['fancyselectedunits'].setOpacity = function(value)
		OPTIONS[currentOption].spotterOpacity = value
	end

	SetupCommandColors(false)
end


function loadOption()
	local appliedOption = OPTIONS_original[currentOption]
	OPTIONS[currentOption] = table.shallow_copy(OPTIONS.defaults)
	
	for option, value in pairs(appliedOption) do
		OPTIONS[currentOption][option] = value
	end
end


function loadConfig()
	loadOption()
	
	CreateCircleLists()
	CreateSquareLists()
	CreateTriangleLists()
	
	SetUnitConf()
	
	Spring.Echo("Fancy Selected Units-dev:  loaded style... '"..OPTIONS[currentOption].name.."'")
end


function SetUnitConf()
	local name, shape, xscale, zscale, scale, xsize, zsize, weaponcount
	for udid, unitDef in pairs(UnitDefs) do
		xsize, zsize = unitDef.xsize, unitDef.zsize
		scale = OPTIONS[currentOption].scaleFactor*( xsize^2 + zsize^2 )^0.5
		name = unitDef.name
		
		if (unitDef.isBuilding or unitDef.isFactory or unitDef.speed==0) then
			shapeName = 'square'
			shape = shapes.square
			xscale, zscale = OPTIONS[currentOption].rectangleFactor * xsize, OPTIONS[currentOption].rectangleFactor * zsize
		elseif (unitDef.isAirUnit) then
			shapeName = 'triangle'
			shape = shapes.triangle
			xscale, zscale = scale, scale
		else
			shapeName = 'circle'
			shape = shapes.circle
			xscale, zscale = scale, scale
		end
		
		weaponcount = table.getn(unitDef.weapons)
			
		
		UNITCONF[udid] = {name=name, shape=shape, shapeName=shapeName, xscale=xscale, zscale=zscale, weaponcount=weaponcount}
	end
end


function widget:Shutdown()
	if WG['teamplatter'] == nil and WG['fancyselectedunits'] == nil then
		SetupCommandColors(true)
	end
	WG['fancyselectedunits'] = nil
	
	gl.DeleteList(clearquad)
	
	for _, shape in pairs(shapes) do
		DestroyShape(shape)
	end
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


function widget:Update()
	if OPTIONS[currentOption].spotterOpacity >= OPTIONS[currentOption].spotterOpacityMin then

		currentClock = os.clock()
		maxSelectTime = currentClock - OPTIONS[currentOption].selectionStartAnimationTime
		maxDeselectedTime = currentClock - OPTIONS[currentOption].selectionEndAnimationTime
		
		updateSelectedUnitsData()		-- calling updateSelectedUnitsData() inside widget:CommandsChanged() will return in buggy behavior in combination with the 'smart-select' widget
	end
end



local degrot = {}
function widget:GameFrame(frame)
	
	if OPTIONS[currentOption].spotterOpacity > OPTIONS[currentOption].spotterOpacityMin then
		if frame%1~=0 then return end
		
		-- logs current unit direction	(needs regular updates for air units, and for buildings only once)	for teamID,_ in pairs(perfSelectedUnits) do
		--for teamID,_ in pairs(perfSelectedUnits) do
			--for unitKey=1, perfSelectedUnits[teamID]['totalUnits'] do
			--unitID = perfSelectedUnits[teamID][unitKey]
		for teamID,_ in pairs(selectedUnits) do
			for unitID,_ in pairs(selectedUnits[teamID]) do
				local dirx, _, dirz = spGetUnitDirection(unitID)
				if (dirz ~= nil) then
					degrot[unitID] = 180 - math.acos(dirz) * rad_con
					if dirx < 0 then
						degrot[unitID] = 180 - math.acos(dirz) * rad_con
					else
						degrot[unitID] = 180 + math.acos(dirz) * rad_con
					end
				end
			end
		end
	end
end


function GetUsedRotationAngle(unitID, shapeName, opposite)
	if (shapeName == 'circle') then
		if opposite then 
			return currentRotationAngleOpposite
		else
			return currentRotationAngle
		end
	else
		return degrot[unitID]
	end
end



do
	local unitID, udid, unit, draw, unitPosX, unitPosY, unitPosZ, changedScale, usedAlpha, usedScale, usedXScale, usedZScale, usedRotationAngle
	local health,maxHealth,paralyzeDamage,captureProgress,buildProgress
	
	function DrawSelectionSpottersPart(teamID, type, r,g,b,a,scale, opposite, relativeScaleSchrinking, changeOpacity, drawUnitStyles)
		
		local OPTIONScurrentOption = OPTIONS[currentOption]
		
		--for unitKey=1, perfSelectedUnits[teamID]['totalUnits'] do
		--	unitID = perfSelectedUnits[teamID][unitKey]
		for unitID in pairs(selectedUnits[teamID]) do
			udid = spGetUnitDefID(unitID)
			unit = UNITCONF[udid]
			
			if (unit) and spUnitInView(unitID) then		 -- and spIsUnitVisible(unitID, unit.xscale*scale*1.3, false) 
				unitPosX, unitPosY, unitPosZ = spGetUnitViewPosition(unitID, true)
				
				changedScale = 1
				usedAlpha = a
				
				if not selectedUnits[teamID][unitID] then return end 
				
				
				if (OPTIONScurrentOption.selectionEndAnimation  or  OPTIONScurrentOption.selectionStartAnimation) then
					if changeOpacity then
						gl.Color(r,g,b,a)
					end
					-- check if the unit is deselected
					if (OPTIONScurrentOption.selectionEndAnimation and not selectedUnits[teamID][unitID]['selected']) then
						if (maxDeselectedTime < selectedUnits[teamID][unitID]['old']) then
							changedScale = OPTIONScurrentOption.selectionEndAnimationScale + (((selectedUnits[teamID][unitID]['old'] - maxDeselectedTime) / OPTIONScurrentOption.selectionEndAnimationTime)) * (1 - OPTIONScurrentOption.selectionEndAnimationScale)
							if (changeOpacity) then
								if type == 'unit highlight' then
									usedAlpha = (((selectedUnits[teamID][unitID]['old'] - maxDeselectedTime) / OPTIONScurrentOption.selectionEndAnimationTime) * a)
								else
									usedAlpha = 1 - (((selectedUnits[teamID][unitID]['old'] - maxDeselectedTime) / OPTIONScurrentOption.selectionEndAnimationTime) * (1-a))
								end
								gl.Color(r,g,b,usedAlpha)
							end
						else
							selectedUnits[teamID][unitID] = nil
						end
						
					-- check if the unit is newly selected
					elseif (OPTIONScurrentOption.selectionStartAnimation and selectedUnits[teamID][unitID]['new'] > maxSelectTime) then
						--spEcho(selectedUnits[teamID][unitID]['new'] - maxSelectTime)
						changedScale = OPTIONScurrentOption.selectionStartAnimationScale + (((currentClock - selectedUnits[teamID][unitID]['new']) / OPTIONScurrentOption.selectionStartAnimationTime)) * (1 - OPTIONScurrentOption.selectionStartAnimationScale)
						if (changeOpacity) then
							if type == 'unit highlight' then
								usedAlpha = (((currentClock - selectedUnits[teamID][unitID]['new']) / OPTIONScurrentOption.selectionStartAnimationTime) * a)
							else
								usedAlpha = 1 - (((currentClock - selectedUnits[teamID][unitID]['new']) / OPTIONScurrentOption.selectionStartAnimationTime) * (1-a))
							end
							gl.Color(r,g,b,usedAlpha)
						end
					end
				end
				
				
				if selectedUnits[teamID][unitID] then
				
					usedRotationAngle = GetUsedRotationAngle(unitID, unit.shapeName, opposite)
					if type == 'normal solid'  or  type == 'normal alpha' then
						
						-- special style for coms
						if drawUnitStyles and OPTIONScurrentOption.showExtraComLine and (unit.name == 'corcom'  or  unit.name == 'armcom') then
							usedRotationAngle = GetUsedRotationAngle(unitID, unit.shapeName)
							gl.Color(r,g,b,(usedAlpha*usedAlpha)+0.22)
							usedScale = scale * 1.25
							glDrawListAtUnit(unitID, unit.shape.inner, false, (unit.xscale*usedScale*changedScale)-((unit.xscale*changedScale-10)/10), 1.0, (unit.zscale*usedScale*changedScale)-((unit.zscale*changedScale-10)/10), currentRotationAngleOpposite, 0, degrot[unitID], 0)
							usedScale = scale * 1.23
							usedRotationAngle = GetUsedRotationAngle(unitID, unit.shapeName , true)
							gl.Color(r,g,b,(usedAlpha*usedAlpha)+0.08)
							glDrawListAtUnit(unitID, unit.shape.large, false, (unit.xscale*usedScale*changedScale)-((unit.xscale*changedScale-10)/10), 1.0, (unit.zscale*usedScale*changedScale)-((unit.zscale*changedScale-10)/10), 0, 0, degrot[unitID], 0)
						else
							-- adding style for buildings with weapons
							if drawUnitStyles and OPTIONScurrentOption.showExtraBuildingWeaponLine and unit.shapeName == 'square' then
								if (unit.weaponcount > 0) then
									usedRotationAngle = GetUsedRotationAngle(unitID, unit.shapeName)
									gl.Color(r,g,b,usedAlpha*(usedAlpha+0.2))
									usedScale = scale * 1.11
									glDrawListAtUnit(unitID, unit.shape.select, false, (unit.xscale*usedScale*changedScale)-((unit.xscale*changedScale-10)/7.5), 1.0, (unit.zscale*usedScale*changedScale)-((unit.zscale*changedScale-10)/7.5), usedRotationAngle, 0, degrot[unitID], 0)
								end
								gl.Color(r,g,b,usedAlpha)
							end
							
							if relativeScaleSchrinking then
								glDrawListAtUnit(unitID, unit.shape.select, false, (unit.xscale*scale*changedScale)-((unit.xscale*changedScale-5)/10), 1.0, (unit.zscale*scale*changedScale)-((unit.zscale*changedScale-5)/10), usedRotationAngle, 0, degrot[unitID], 0)
							else
								glDrawListAtUnit(unitID, unit.shape.select, false, unit.xscale*scale*changedScale, 1.0, unit.zscale*scale*changedScale, usedRotationAngle, 0, degrot[unitID], 0)
							end
						end
						
					elseif type == 'solid overlap' then
						
						if relativeScaleSchrinking then
							glDrawListAtUnit(unitID, unit.shape.large, false, (unit.xscale*scale*changedScale)-((unit.xscale*changedScale-5)/50), 1.0, (unit.zscale*scale*changedScale)-((unit.zscale*changedScale-5)/50), usedRotationAngle, 0, degrot[unitID], 0)
						else
							glDrawListAtUnit(unitID, unit.shape.large, false, (unit.xscale*scale*changedScale)+((unit.xscale-15)/15), 1.0, (unit.zscale*scale*changedScale)+((unit.zscale-15)/15), usedRotationAngle, 0, degrot[unitID], 0)
						end
						
					elseif type == 'base solid'  or  type == 'base alpha' then
						usedXScale = unit.xscale
						usedZScale = unit.zscale
						if OPTIONScurrentOption.showExtraComLine and (unit.name == 'corcom'  or  unit.name == 'armcom') then
							usedXScale = usedXScale * 1.23
							usedZScale = usedZScale * 1.23
						elseif OPTIONScurrentOption.showExtraBuildingWeaponLine and unit.shapeName == 'square' then
							if (unit.weaponcount > 0) then
								usedXScale = usedXScale * 1.14
								usedZScale = usedZScale * 1.14
							end
						end
						glDrawListAtUnit(unitID, unit.shape.large, false, (usedXScale*scale*changedScale)-((usedXScale*changedScale-10)/10), 1.0, (usedZScale*scale*changedScale)-((usedZScale*changedScale-10)/10), usedRotationAngle, 0, degrot[unitID], 0)
					end
				end
			end
		end	
	end
end --// end do

	
function widget:DrawWorldPreUnit()
	
	if OPTIONS[currentOption].spotterOpacity >= OPTIONS[currentOption].spotterOpacityMin then
		
		local clockDifference = (os.clock() - previousOsClock)
		previousOsClock = os.clock()
		
		--if spIsGUIHidden() then return end
		
		gl.PushAttrib(GL.COLOR_BUFFER_BIT)
		gl.DepthTest(false)
		
		-- animate rotation
		if OPTIONS[currentOption].rotationSpeed > 0 then
			local angleDifference = (OPTIONS[currentOption].rotationSpeed) * (clockDifference * 5)
			currentRotationAngle = currentRotationAngle + (angleDifference*0.66)
			if currentRotationAngle > 360 then
			   currentRotationAngle = currentRotationAngle - 360
			end
		
			currentRotationAngleOpposite = currentRotationAngleOpposite - angleDifference
			if currentRotationAngleOpposite < -360 then
			   currentRotationAngleOpposite = currentRotationAngleOpposite + 360
			end
		end
		
		-- animate scale 
		if OPTIONS[currentOption].animateSpotterSize then
			local addedMultiplierValue = OPTIONS[currentOption].animationSpeed * (clockDifference * 50)
			if (animationMultiplierAdd  and  animationMultiplier < OPTIONS[currentOption].maxAnimationMultiplier) then
				animationMultiplier = animationMultiplier + addedMultiplierValue
				animationMultiplierInner = animationMultiplierInner - addedMultiplierValue
				if (animationMultiplier > OPTIONS[currentOption].maxAnimationMultiplier) then
					animationMultiplier = OPTIONS[currentOption].maxAnimationMultiplier
					animationMultiplierInner = OPTIONS[currentOption].minAnimationMultiplier
					animationMultiplierAdd = false
				end
			else
				animationMultiplier = animationMultiplier - addedMultiplierValue
				animationMultiplierInner = animationMultiplierInner + addedMultiplierValue
				if (animationMultiplier < OPTIONS[currentOption].minAnimationMultiplier) then
					animationMultiplier = OPTIONS[currentOption].minAnimationMultiplier
					animationMultiplierInner = OPTIONS[currentOption].maxAnimationMultiplier
					animationMultiplierAdd = true
				end
			end
		end
		
		-- loop teams
		local baseR, baseG, baseB, r, g, b, a, scale, scaleBase, scaleOuter
		for teamID,_ in pairs(selectedUnits) do
			
			r,g,b = 1,1,1
			scale = 1 * OPTIONS[currentOption].scaleMultiplier * animationMultiplierInner
			scaleBase = scale * 1.133
			if OPTIONS[currentOption].showSecondLine then 
				scaleOuter = (1 * OPTIONS[currentOption].scaleMultiplier * animationMultiplier) * 1.18
				scaleBase = scaleOuter * 1.08
			end
			
			gl.ColorMask(false, false, false, true)
			gl.BlendFunc(GL.ONE, GL.ONE)
			gl.Color(r,g,b,1)
			glCallList(clearquad)
			
			
			-- draw base background layer
			if OPTIONS[currentOption].showBase then
				baseR, baseG, baseB = r,g,b
				baseR,baseG,baseB = spGetTeamColor(teamID)
				
				gl.Blending(GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA)
				DrawSelectionSpottersPart(teamID, 'base solid', baseR,baseG,baseB,0,scaleBase, false, false, false, false)
				
				--  Here the inner of the selected spotters are removed
				gl.BlendFunc(GL.ONE, GL.ZERO)
				a = 1 - (OPTIONS[currentOption].baseOpacity * OPTIONS[currentOption].spotterOpacity)
				DrawSelectionSpottersPart(teamID, 'base alpha', baseR,baseG,baseB,a,scaleBase, false, false, true, false)
				
				--  Really draw the spotters now  (This could be optimised if we could say Draw as much as DST_ALPHA * SRC_ALPHA is)
				-- (without protecting form drawing them twice)
				gl.ColorMask(true,true,true,true)
				gl.BlendFunc(GL.ONE_MINUS_DST_ALPHA, GL.DST_ALPHA)
				glCallList(clearquad)
			end
			
			
			-- draw 1st line layer
			if OPTIONS[currentOption].showFirstLine then
				a = 1 - (OPTIONS[currentOption].firstLineOpacity * OPTIONS[currentOption].spotterOpacity)
						
				gl.ColorMask(false, false, false, true)
				gl.BlendFunc(GL.ONE_MINUS_SRC_ALPHA, GL.SRC_ALPHA)
				if OPTIONS[currentOption].showFirstLineDetails then
					if OPTIONS[currentOption].showNoOverlap then
						-- draw normal spotters solid
						gl.Color(r,g,b,0)
						DrawSelectionSpottersPart(teamID, 'normal solid', r,g,b,a,scale, false, false, false, false)
						
						--  Here the spotters are given the alpha level (this step makes sure overlappings dont have different alpha level)
						gl.BlendFunc(GL.ONE, GL.ZERO)
						gl.Color(r,g,b,a)
						DrawSelectionSpottersPart(teamID, 'normal alpha', r,g,b,a,scale, false, false, true, false)
					else
						gl.Color(r,g,b,a)
						DrawSelectionSpottersPart(teamID, 'normal alpha', r,g,b,a,scale, false, false, true, false)
					end
				end
				
				--  Here the inner of the selected spotters are removed
				gl.BlendFunc(GL.ONE, GL.ZERO)
				gl.Color(r,g,b,1)
				DrawSelectionSpottersPart(teamID, 'solid overlap', r,g,b,a,scale, opposite, relativeScaleSchrinking, false, drawUnitStyles)
				
				--  Really draw the spotters now  (This could be optimised if we could say Draw as much as DST_ALPHA * SRC_ALPHA is)
				-- (without protecting form drawing them twice)
				gl.ColorMask(true, true, true, true)
				gl.BlendFunc(GL.ONE_MINUS_DST_ALPHA, GL.DST_ALPHA)
				
				-- Does not need to be drawn per Unit anymore
				glCallList(clearquad)
			end
			
			
			-- draw 2nd line layer
			if OPTIONS[currentOption].showSecondLine then
				a = 1 - (OPTIONS[currentOption].secondLineOpacity * OPTIONS[currentOption].spotterOpacity)
				
				gl.ColorMask(false, false, false, true)
				gl.BlendFunc(GL.ONE_MINUS_SRC_ALPHA, GL.SRC_ALPHA)
				
				--  Here the inner of the selected spotters are removed
				gl.BlendFunc(GL.ONE, GL.ZERO)
				gl.Color(r,g,b,1)
				DrawSelectionSpottersPart(teamID, 'solid overlap', r,g,b,a,scaleOuter, false, true, false, true)
				
				--  Really draw the spotters now  (This could be optimised if we could say Draw as much as DST_ALPHA * SRC_ALPHA is)
				-- (without protecting form drawing them twice)
				gl.ColorMask(true, true, true, true)
				gl.BlendFunc(GL.ONE_MINUS_DST_ALPHA, GL.DST_ALPHA)
				
				-- Does not need to be drawn per Unit anymore
				glCallList(clearquad)
			end
		end
		
		gl.ColorMask(false,false,false,false)
		gl.Color(1,1,1,1)
		gl.PopAttrib()
	end
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- Config related

function widget:GetConfigData(data)
    savedTable = {}
    savedTable.currentOption					= currentOption
    savedTable.spotterOpacity					= OPTIONS.defaults.spotterOpacity
    savedTable.showSecondLine					= OPTIONS.defaults.showSecondLine
    
    return savedTable
end

function widget:SetConfigData(data)
    --currentOption								= data.currentOption			or currentOption
    --OPTIONS.defaults.spotterOpacity				= data.spotterOpacity			or OPTIONS.defaults.spotterOpacity
    --OPTIONS.defaults.showSecondLine				= data.showSecondLine			or OPTIONS.defaults.showSecondLine
end
