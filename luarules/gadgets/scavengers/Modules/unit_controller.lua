Spring.Echo("[Scavengers] Unit Controller initialized")

VFS.Include("luarules/gadgets/scavengers/Configs/"..GameShortName.."/UnitLists/staticunits.lua")

function SelfDestructionControls(n, scav, scavDef)
	UnitRange = {}
	Constructing = {}
	--Constructing[scav] = false
	local _,_,_,_,buildProgress = Spring.GetUnitHealth(scav)
	if buildProgress == 1 then
		if selfdx[scav] then
			oldselfdx[scav] = selfdx[scav]
		end
		if selfdy[scav] then
			oldselfdy[scav] = selfdy[scav]
		end
		if selfdz[scav] then
			oldselfdz[scav] = selfdz[scav]
		end
		selfdx[scav],selfdy[scav],selfdz[scav] = Spring.GetUnitPosition(scav)
		if UnitDefs[scavDef].maxWeaponRange < 800 then
			UnitRange[scav] = 800
		else
			UnitRange[scav] = UnitDefs[scavDef].maxWeaponRange
		end
		if scavConstructor[scav] then
			local metalMake, metalUse = Spring.GetUnitResources(scav)
			if metalUse > 0 then
				Constructing[scav] = true
			else
				Constructing[scav] = false
			end
		end
		if (oldselfdx[scav] and oldselfdy[scav] and oldselfdz[scav]) and (oldselfdx[scav] > selfdx[scav]-20 and oldselfdx[scav] < selfdx[scav]+20) and (oldselfdy[scav] > selfdy[scav]-20 and oldselfdy[scav] < selfdy[scav]+20) and (oldselfdz[scav] > selfdz[scav]-20 and oldselfdz[scav] < selfdz[scav]+20) then
			if selfdx[scav] < mapsizeX and selfdx[scav] > 0 and selfdz[scav] < mapsizeZ and selfdz[scav] > 0 then
				if not scavConstructor[scav] or Constructing[scav] == false then
					local scavhealth, scavmaxhealth, scavparalyze = Spring.GetUnitHealth(scav)
					for q = 1,5 do
						local posx = math.random(selfdx[scav] - 400, selfdx[scav] + 400)
						local posz = math.random(selfdz[scav] - 400, selfdz[scav] + 400)
						local telstartposy = Spring.GetGroundHeight(selfdx[scav], selfdz[scav])
						local telendposy = Spring.GetGroundHeight(posx, posz)
						local poscheck = posLosCheckOnlyLOS(posx, telendposy, posz, 100)
						if (-(UnitDefs[scavDef].minWaterDepth) > telendposy) and (-(UnitDefs[scavDef].maxWaterDepth) < telendposy) and scavparalyze == 0 and poscheck == true then
							Spring.SpawnCEG("scav-spawnexplo",selfdx[scav],telstartposy,selfdz[scav],0,0,0)
							Spring.SpawnCEG("scav-spawnexplo",posx,telendposy,posz,0,0,0)
							Spring.SetUnitPosition(scav, posx, posz)
							Spring.GiveOrderToUnit(scav, CMD.STOP, 0, 0)
							break
						end
					end
				end
			end
			--Spring.DestroyUnit(scav, false, true)
		end
	end
	UnitRange[scav] = nil
	Constructing[scav] = nil
end

function BossDGun(n)
	if FinalBossUnitID then
		local NearestBossEnemy = Spring.GetUnitNearestEnemy(FinalBossUnitID, 20000, false)
		NearestBossEnemyUnitDefID = Spring.GetUnitDefID(NearestBossEnemy)
		if UnitDefs[NearestBossEnemyUnitDefID].canFly ~= true then
			local x,y,z = Spring.GetUnitPosition(NearestBossEnemy)
			--Spring.GiveOrderToUnit(FinalBossUnitID, CMD.DGUN,{x,y,z}, {0})
			Spring.GiveOrderToUnit(FinalBossUnitID, CMD.DGUN, NearestBossEnemy, {0})
		end
	end
end

function ArmyMoveOrders(n, scav, scavDef)
	UnitRange = {}
	if UnitDefs[scavDef].maxWeaponRange and UnitDefs[scavDef].maxWeaponRange > 10 then
		UnitRange[scav] = UnitDefs[scavDef].maxWeaponRange
	else
		UnitRange[scav] = 10
	end
	if not BossWaveStarted or BossWaveStarted == false then
		attackTarget = Spring.GetUnitNearestEnemy(scav, 200000, false)
	else
		if AliveEnemyCommanders and AliveEnemyCommandersCount > 0 then
			if AliveEnemyCommandersCount > 1 then
				for i = 1,AliveEnemyCommandersCount do
					-- let's get nearest commander
					local separation = Spring.GetUnitSeparation(scav,AliveEnemyCommanders[i])
					if not lowestSeparation then
						lowestSeparation = separation
						attackTarget = AliveEnemyCommanders[i]
					end
					if separation < lowestSeparation then
						lowestSeparation = separation
						attackTarget = AliveEnemyCommanders[i]
					end
				end
				lowestSeparation = nil
			elseif AliveEnemyCommandersCount == 1 then
				attackTarget = AliveEnemyCommanders[1]
			end
		end
	end
	if attackTarget == nil then
		attackTarget = Spring.GetUnitNearestEnemy(scav, 200000, false)
	end
	local x,y,z = Spring.GetUnitPosition(attackTarget)
	local range = UnitRange[scav]
	local x = x + math_random(-range*3,range*3)
	local z = z + math_random(-range*3,range*3)
	if (not BossWaveStarted) and (UnitDefs[scavDef].canFly or (UnitRange[scav] > unitControllerModuleConfig.minimumrangeforfight)) then
		Spring.GiveOrderToUnit(scav, CMD.FIGHT,{x,y,z}, {"shift", "alt", "ctrl"})
	else
		Spring.GiveOrderToUnit(scav, CMD.MOVE,{x,y,z}, {"shift", "alt", "ctrl"})
	end	
	attackTarget = nil
end
