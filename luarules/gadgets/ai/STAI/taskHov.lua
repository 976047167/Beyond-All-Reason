local DebugEnabled = false

local function EchoDebug(inStr)
	if DebugEnabled then
		game:SendToConsole("taskHov: " .. inStr)
	end
end

function ConHover()
	if MyTB.side == UnitiesHST.CORESideName then
		unitName = "corch"
	else
		unitName = "armch"
	end
	local mtypedLv = GetMtypedLv(unitName)
	return BuildWithLimitedNumber(unitName, math.min((mtypedLv / 6) + 1, ai.conUnitPerTypeLimit))
end

function HoverMerl(tskqbhvr)
	local unitName = ""
	if MyTB.side == UnitiesHST.CORESideName then
		unitName = "cormh"
	else
		unitName = "armmh"
	end
	return BuildSiegeIfNeeded(unitName)
end

function HoverRaider(tskqbhvr)
	local unitName = ""
	if MyTB.side == UnitiesHST.CORESideName then
		unitName = "corsh"
	else
		unitName = "armsh"
	end
	return BuildRaiderIfNeeded(unitName)
end

function HoverBattle(tskqbhvr)
	local unitName = ""
	if MyTB.side == UnitiesHST.CORESideName then
		unitName = "corsnap"
	else
		unitName = "armanac"
	end
	return BuildBattleIfNeeded(unitName)
end

function HoverBreakthrough(tskqbhvr)
	local unitName = ""
	if MyTB.side == UnitiesHST.CORESideName then
		unitName = "corhal"
	else
		unitName = "armanac"
	end
	BuildBreakthroughIfNeeded(unitName)
end

function AAHover()
	if MyTB.side == UnitiesHST.CORESideName then
		return BuildAAIfNeeded("corah")
	else
		return BuildAAIfNeeded("armah")
	end
end


