shard_include( "attackers")


-- speedups
local SpGetGameFrame = Spring.GetGameFrame
local SpGetUnitPosition = Spring.GetUnitPosition
local SpGetUnitSeparation = Spring.GetUnitSeparation
local SpGetUnitVelocity = Spring.GetUnitVelocity
local SpGetUnitMaxRange = Spring.GetUnitMaxRange
local SpValidUnitID = Spring.ValidUnitID
local SpGetUnitCurrentBuildPower = Spring.GetUnitCurrentBuildPower
local SpGetUnitNearestEnemy = Spring.GetUnitNearestEnemy
------


function IsRaider(unit)
	for i,name in ipairs(raiderlist) do
		if name == unit:Internal():Name() then
			return true
		end
	end
	return false
end

RaiderBehaviour = class(Behaviour)

function RaiderBehaviour:Init()
	--self.ai.game:SendToConsole("raider!")
	--self.game:AddMarker({ x = startPosx, y = startPosy, z = startPosz }, "my start position")
	CMD.MOVE_STATE = 50
	CMD.FIRE_STATE = 45
	aiTeamsCount = #Spring.GetTeamList()
end

local function Distance(x1,z1, x2,z2)
	local vectx = x2 - x1
	local vectz = z2 - z1
	local dis = math.sqrt((vectx*vectx) + (vectz*vectz))
	return dis
end

function RaiderBehaviour:Update()
	local frame = SpGetGameFrame()
	if not self.unitID then
		self.unitID = self.unit:Internal().id
	end
	if not self.unitIDrefreshrate then
		self.unitIDrefreshrate = self.unitID*10000
	end
	if not self.active then -- do not even attempt anything if the unit is inactive...	
		if frame%90 == self.unitID%90 then
			local unit = self.unit:Internal()
			if (unit:GetHealth()/unit:GetMaxHealth())*100 == 100 then
				self.active = true
			else
				return
			end
		else
			return
		end
	end
	if not self.AggFactor then
		self.AggFactor = self.ai.mainsquadhandler:GetAggressiveness(self)
	end
	local frame = SpGetGameFrame()
	local unit = self.unit:Internal()
	if (frame%2000 == self.unitIDrefreshrate%2000) or self.myRange == nil or self.myUnitCount == nil or raidRangeUpdateRate == nil or raidMapUpdateRate == nil then --refresh "myRange" casually because it can change with experience
		self.myUnitCount = Spring.GetTeamUnitCount(self.ai.id)
		self.myRange = math.min(SpGetUnitMaxRange(self.unitID),500)
		raidRangeUpdateRate = self.myUnitCount
		raidMapUpdateRate = raidRangeUpdateRate*3
	end
	if (frame%raidMapUpdateRate == self.unitIDrefreshrate%raidMapUpdateRate) then -- a unit on map stays 'visible' for max 3s, this also reduces lag
		local nearestVisibleAcrossMap = SpGetUnitNearestEnemy(self.unitID, self.AggFactor*self.myRange)
		if nearestVisibleAcrossMap and (GG.AiHelpers.VisibilityCheck.IsUnitVisible(nearestVisibleAcrossMap, self.ai.id)) then
			self.nearestVisibleAcrossMap = nearestVisibleAcrossMap
			if not self.behaviourcontroled then
				self.ai.mainsquadhandler:RemoveFromSquad(self)
			end
		else
			self.nearestVisibleAcrossMap = nil
			if self.behaviourcontroled then
				self.ai.mainsquadhandler:AssignToASquad(self)
				return
			end
		end
	end
	if (frame%raidRangeUpdateRate == self.unitIDrefreshrate%raidRangeUpdateRate) then -- a unit in range stays 'visible' for max 1.5s, this also reduces lag
		local nearestVisibleInRange = SpGetUnitNearestEnemy(self.unitID, 1.75*self.myRange)
		local closestVisible = nearestVisibleInRange and GG.AiHelpers.VisibilityCheck.IsUnitVisible(nearestVisibleInRange, self.ai.id)
		if nearestVisibleInRange and closestVisible then
			self.nearestVisibleInRange = nearestVisibleInRange
			self.enemyRange = SpGetUnitMaxRange(nearestVisibleInRange)
			if not self.behaviourcontroled then
				self.ai.mainsquadhandler:RemoveFromSquad(self)
			end
		else
			self.nearestVisibleInRange = nil
			if self.behaviourcontroled then
				self.ai.mainsquadhandler:AssignToASquad(self)
				return
			end
		end
	end
	if not (self.nearestVisibleAcrossMap or self.nearestVisibleInRange) then
		if self.behaviourcontroled then
			self.ai.mainsquadhandler:AssignToASquad(self)
			return
		end
	end
	if self.unitIDrefreshrate%raidRangeUpdateRate == frame%raidRangeUpdateRate then
		self:AttackCell(self.nearestVisibleAcrossMap, self.nearestVisibleInRange, self.enemyRange, self.alliedNear)
	end
end

function RaiderBehaviour:OwnerBuilt()
	self.unit:Internal():ExecuteCustomCommand(CMD.MOVE_STATE, { 2 }, {})
	self.unit:Internal():ExecuteCustomCommand(CMD.FIRE_STATE, { 2 }, {})
	self.attacking = true
	self.active = true
	self.unitID = self.unit:Internal().id
	self.AggFactor = self.ai.mainsquadhandler:GetAggressiveness(self)
	self.ai.mainsquadhandler:AssignToASquad(self)
end

function RaiderBehaviour:OwnerDead()
	if not self.behaviourcontroled then
		self.ai.mainsquadhandler:RemoveFromSquad(self)
	end
end

function RaiderBehaviour:OwnerIdle()
	self.attacking = true
	self.active = true
end

function RaiderBehaviour:AttackCell(nearestVisibleAcrossMap, nearestVisibleInRange, enemyRange, alliedNear)
	local p
	local unit = self.unit:Internal()
	local unitID = unit.id
	local currenthealth = unit:GetHealth()
	local maxhealth = unit:GetMaxHealth()
	-- Retreating first so we have less data process/only what matters
	if not (currenthealth >= maxhealth*0.75 or currenthealth > 3000) then
	local nanotcx, nanotcy, nanotcz = GG.AiHelpers.NanoTC.GetClosestNanoTC(self.unitID)
		if nanotcx and nanotcy and nanotcz then
			p = api.Position()
			p.x, p.y, p.z = nanotcx, nanotcy, nanotcz
		else
			p = self.ai.triggerhandler.commpos
		end
		self.target = p
		self.attacking = false
		if self.active then
			self.active = false -- until it is idle (= getting repaired)
			self.unit:Internal():Move(self.target)
		end
		return
	end
	
	local utype = self.game:GetTypeByName(unit:Name())
	
	-- nil/invalid checks
	if nearestVisibleInRange and (not SpValidUnitID(nearestVisibleInRange)) then 
		nearestVisibleInRange = nil 
		self.nearestVisibleInRange = nil
	end
	if nearestVisibleAcrossMap and (not SpValidUnitID(nearestVisibleAcrossMap)) then 
		nearestVisibleAcrossMap = nil 
		self.nearestVisibleAcrossMap = nil 
	end
	if not (nearestVisibleAcrossMap or nearestVisibleInRange) then
		return
	end
	
	if nearestVisibleInRange then -- process cases where there isn't any visible nearestVisibleInRange first
		local ex,ey,ez = SpGetUnitPosition(nearestVisibleInRange)
		local ux,uy,uz = SpGetUnitPosition(self.unitID)
		local pointDis = SpGetUnitSeparation(self.unitID,nearestVisibleInRange)
		local dis = 120
		local f = dis/pointDis
		local wantedRange
		wantedRange = (math.random(25,75)/100)*self.myRange
		-- offset upos randomly so it moves a bit while keeping distance
		local dx, _, dz, dw = SpGetUnitVelocity(self.unitID) -- attempt to not always queue awful turns
		local modifier = "ctrl"
		ux = ux + 10*dx + math.random (-80,80)
		uy = uy
		uz = uz + 10*dz + math.random (-80,80)
		if wantedRange <= pointDis then
			modifier = nil -- Do not try to move backwards if attempting to get closer to target
		end
		-- here we find the goal position
		if (pointDis+dis > wantedRange) then
			f = (wantedRange-pointDis)/pointDis
		end
		local cx = ux+(ux-ex)*f
		local cy = uy
		local cz = uz+(uz-ez)*f
		self.unit:Internal():ExecuteCustomCommand(CMD.MOVE, {cx, cy, cz}, {modifier})
		return
	end
	
	-- We have processed units that had to retreat and units that had visible enemies within 2* their range
	-- what are left are units with no visible enemies within 2*maxRange (no radar/los/prevLOS buildings)
	local enemyposx, enemyposy, enemyposz
	if nearestVisibleAcrossMap then
		enemyposx, enemyposy, enemyposz = SpGetUnitPosition(nearestVisibleAcrossMap) -- visible on map
	else
		return
	end
	p = api.Position()
	p.x = enemyposx + math.random(-math.sqrt(2)/2*self.myRange*0.90, math.sqrt(2)/2*self.myRange*0.90)
	p.z = enemyposz + math.random(-math.sqrt(2)/2*self.myRange*0.90, math.sqrt(2)/2*self.myRange*0.90)
	p.y = enemyposy
	self.target = p
	self.attacking = true
	unit:Move(self.target)
end


function RaiderBehaviour:Priority()
	if not self.attacking then
		return 0
	else
		return 100
	end
end

function RaiderBehaviour:Activate()
	self.active = true
	if self.target then
		self.unit:Internal():MoveAndFire(self.target)
		self.target = nil
	else
	end
end


function RaiderBehaviour:OwnerDied()
	self.attacking = nil
	self.active = nil
	self.unit = nil
end
