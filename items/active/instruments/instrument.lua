require "/scripts/mml.lua"
require "/scripts/util.lua"
require "/scripts/vec2.lua"

BASE_STEP = 69 --bravo

--just in case you nerds try anything funny
function findLowestStep(table)
	local lowest = math.huge
	for i,_ in pairs(table) do
		if lowest == nil or lowest > tonumber(i) then
			lowest = tonumber(i)
		end
	end

	return lowest
end

function findHighestStep(table)
	local lowest = 0
	for i,_ in pairs(table) do
		if lowest == nil or lowest < tonumber(i) then
			lowest = tonumber(i)
		end
	end

	return lowest
end

function findNextNoteWithFile(table, indexAsNb)
	local indexAsStr = tostring(indexAsNb)

	while table[indexAsStr] do
		if table[indexAsStr].file then
			return indexAsNb
		end

		indexAsNb = indexAsNb + 1
		indexAsStr = tostring(indexAsNb)
	end

	return indexAsNb
end

function processMapping(mapping)
	local step = findLowestStep(mapping)
	self.lowestNote = step
	self.highestNote = findHighestStep(mapping)
	local map = {}
	local lastFile = ""
	local lastFileStep = step
	local nextFileStep = findNextNoteWithFile(mapping, step + 1)
	local pitch = 1

	--probably not the optimal way to go about it but I don't remember how to lua so this works
	while mapping[tostring(step)] do
		if mapping[tostring(step)].file then
			lastFile = mapping[tostring(step)].file:gsub("%$instrument%$", self.instrument)
			lastFileStep = step
			nextFileStep = findNextNoteWithFile(mapping, step + 1)
		end

		animator.setSoundPool("step" .. tostring(step), { lastFile })

		if step ~= lastFileStep then
			pitch = 1.0 + (step - lastFileStep) / (nextFileStep - lastFileStep)
			animator.setSoundPitch("step" .. tostring(step), pitch, 0)
		else
			pitch = 1
		end

		map[step] = {{
			file = lastFile,
			pitch = pitch,
			freq = mapping[tostring(step)].f
		}}

		sb.logInfo("map[%s]: %s", step, map[step])

		step = step + 1
	end


	return map
end

function init()
	sb.logInfo("instrument.lua init()")
	--self.player = mml.newPlayer(string.lower("t140 fgab-<cdefedc>b-agfa<cfc>af"), "steps")

	-- all notes
	--self.player = mml.newPlayer(string.lower("t140 o1 cc+de-eff+ga-ab-b>cc+de-eff+ga-ab-b>cc+de-eff+ga-ab-b>cc+de-eff+ga-ab-b>cc+de-eff+ga-ab-b>cc+de-eff+ga-ab-b>cc+de-eff+ga-ab-b>cc+de-eff+ga-ab-b"), "steps")

	--twinkle twinkle
	self.player = mml.newPlayer(string.lower("t160 o5l8q7 ccggaag4 ffeeddc4"), "steps")	

	self.timer = 0
	self.noteTime = 0
	self.running = true

	self.instrument = config.getParameter("kind", "brightpiano")
	self.soundPath = "/sfx/instruments/" .. self.instrument .. "/"

	local tuning = root.assetJson(self.soundPath .. "tuning.config")
	self.mapping = processMapping(tuning.mapping)
	self.fadeout = tuning.fadeout
	self.lastNote = nil

	--sb.logInfo("mapping: %s", self.mapping)
end

function update(dt)
	--todo multiple channels
	if self.running then
		--sb.logInfo("timer: %s / %s| dt: %s", self.timer, self.noteTime, dt)
		if self.timer >= self.noteTime then
			self.timer = 0
			if self.lastNote then
				animator.setSoundVolume(self.lastNote, 0, self.fadeout)
				--animator.stopAllSounds(self.lastNote)
			end
			local ok, note, time, vol = coroutine.resume(self.player);

			if not ok then
				self.running = false
				self.noteTime = 0

				--remove once debug is not needed
				self.debugLastNote = nil 
				self.debugLastStep = nil
			else
				sb.logInfo("time: %s, note:%s (%s), vol: %s (%s) | dt: %s", time, note, note and BASE_STEP + note or nil, vol, handleVolume(vol), dt)
				self.noteTime = time
				if note then
					local step = BASE_STEP + note

					--todo generate notes on the fly when out of range instead of clamping?
					if step < self.lowestNote then --clamp octave up
						while step < self.lowestNote do
							step = step + 12
						end
					elseif step > self.highestNote then --clamp octave down
						while step > self.highestNote do
							step = step - 12
						end
					end

					local soundConf = self.mapping[step][1]
					local soundName = "step" .. tostring(step):gsub("(.*)%..*$","%1")
					--sb.logInfo("self.mapping[%s]: %s", BASE_STEP + note, soundConf)
					--sb.logInfo("self.mapping[%s]: %s | %s\n", BASE_STEP + note, soundConf, soundName)
					--sb.logInfo("sound conf: %s", soundConf)
					animator.playSound(soundName, 1)
					animator.setSoundVolume(soundName, 0.0 + handleVolume(vol), 0) --Daily Dangerous Didyouknow: there's no upper bound on max vol (please be careful)
					self.lastNote = soundName
					self.debugLastNote = note
					self.debugLastStep = step
				end
			end
		else
			self.timer = self.timer + dt
		end
	end

	world.debugText("n: %s (%s)\ntimer: %s\nnoteTime: %s\ndt: %s", self.debugLastNote or nil, self.debugLastStep or nil, self.timer, self.noteTime, dt, vec2.add(world.entityPosition(activeItem.ownerEntityId()), {2, 0}), "red")
end

function handleVolume(vol)
	if vol == nil then return 0 end
	while vol > 1 do
		vol = vol / 10
	end

	return vol
end