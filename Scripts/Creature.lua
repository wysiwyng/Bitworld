class "Creature" (Entity)

Creature.ATTACK = 0

--[[  ** AI modes ** ]]

Creature.SEEK_MODE = 0
Creature.ATTACK_MODE = 1
Creature.FLEE_MODE = 2

function Creature:Creature(creatureIndex)

	--[[  *** Default creature properties *** ]]

	self.HP = 3			 -- Health
	self.maxHP = 0		  -- Maximum health
	self.gold = 0		   -- How much gold a creature has
	self.arrowCharge = 0	-- State of the arrow charge
	self.freezeTimer = 0	-- Freezing timer
	self.blood = "Blood"	-- Name of the blood material to use

	-- Creature states

	self.dummy = false		-- Dummy creature
	self.charging = false	 --  is creature charging an attack
	self.dead = false		 -- is creature dead?
	self.friendly = false
	self.archer = false
	self.cloaked = false
	self.blocking = false
	self.frozen = false
	self.collideWalls = false
	self.boss = false

	-- Spellcasting
	self.spellChargeMax = 5
	self.spellCharge = 0
	self.spellFired = true
	self.spellID = 0

	-- AI properties
	self.aiMode = 0
	self.thinkAttackTimer = 0
	self.thinkAttackMode = 0	
	self.targetPoint = nil
	self.aiArcherTimer = 0
	self.pathThinkTimer = 100000
	self.targetPath = nil
	self.targetPathLength = 0
	self.targetPathIndex = 0

	-- Rendering
	self.bodyAdjust = 0

	if math.random(10) < 6 then
		self.rightAttack = true
	else
		self.rightAttack = false
	end 

	Entity.Entity(self)

	self.ownsChildren = true

	self.levelScale = 0.3 * 0.25
	local scale = self.levelScale

	self.creatureIndex = creatureIndex
	self.baseXScale = 1

	self.yAccel = 0
	self.xAccel = 0
	self.zAccel = 0

	self.shadow = ScenePrimitive(ScenePrimitive.TYPE_PLANE, 0.08,0.08,0)
	self.shadow:setPosition(0.0, 0.001, 0.00)
	self.shadow:setColor(1,1,1,0.78)
	self.shadow.depthWrite = false
	self.shadow:setMaterialByName("Shadow", Services.ResourceManager:getGlobalPool())
	self:addChild(self.shadow)

	self.bodyAnchor = Entity()
	self:addChild(self.bodyAnchor)  

	indexX = (creatureIndex % 8)
	indexY = 7-(math.floor(creatureIndex/8))

	cellSizeX = 1/8
	cellSizeY = 1/8

	self.icon = ScenePrimitive(ScenePrimitive.TYPE_VPLANE, 0.04,0.04)

	self.icon:setMaterialByName("Exclamation", Services.ResourceManager:getGlobalPool())
	self.icon.depthTest = false
	self.icon:setPosition(0.04, 0.14)
	self.icon.billboardMode = true
	self.icon.billboardRoll = true
	self:addChild(self.icon)
	self.icon.visible = false
	self.icon:setColor(1,1,1,0)
	self.iconVal = 0


	self.slash = ScenePrimitive(ScenePrimitive.TYPE_VPLANE, 0.15,0.15,0)

	self.slash:setMaterialByName("Slash", Services.ResourceManager:getGlobalPool())
	self.slash:setBlendingMode(Renderer.BLEND_MODE_LIGHTEN)
	self.slash.depthTest = false
	self.slash:setPosition(0.06, 0.08)

	self.slash.billboardMode = true
	self.slash.billboardRoll = true
	self.slash:setScale(0.8,0.8,0.8)
	self.slash:setColor(1,1,1,0.6)

	self.bodyAnchor:addChild(self.slash)


	local bodyMesh = Mesh(Mesh.TRI_MESH)
	bodyMesh.indexedMesh = false
	local sheight = scale  

	local i = 0
	local j = 0

	-- if boss
	if self.creatureIndex == 666 then	
		self.boss = true
		self.bodyAdjust = -0.01
		
		self.baseXScale = 6

		bodyMesh:addVertexWithUV((i*self.levelScale)+scale,0,(j*scale),1,0)  
		bodyMesh:addVertexWithUV((i*scale)+scale,sheight,(j*scale),1,1)
		bodyMesh:addVertexWithUV((i*scale),sheight,(j*scale),0,1)
 
		bodyMesh:addVertexWithUV((i*scale),0,(j*scale),0,0)	   
		bodyMesh:addVertexWithUV((i*scale)+scale,0,(j*scale),1,0)  
		bodyMesh:addVertexWithUV((i*scale),sheight,(j*scale),0,1)
  
		bodyMesh:calculateNormals()

		self.rBody = SceneMesh.SceneMeshFromMesh(bodyMesh)
		self.body = self.rBody

		bodyMesh = Mesh(Mesh.TRI_MESH)
		bodyMesh.indexedMesh = false

		bodyMesh:addVertexWithUV((i*self.levelScale)+scale,0,(j*scale),0,0)  
		bodyMesh:addVertexWithUV((i*scale)+scale,sheight,(j*scale),0,1)
		bodyMesh:addVertexWithUV((i*scale),sheight,(j*scale),1,1)
 
		bodyMesh:addVertexWithUV((i*scale),0,(j*scale),1,0)	   
		bodyMesh:addVertexWithUV((i*scale)+scale,0,(j*scale),0,0)  
		bodyMesh:addVertexWithUV((i*scale),sheight,(j*scale),1,1)
  
		bodyMesh:calculateNormals()
		self.lBody = SceneMesh.SceneMeshFromMesh(bodyMesh)

		self.lBody:Translate(0,-self.levelScale,0)
		self.rBody:Translate(0,-self.levelScale,0)

		self.lBody:setMaterialByName("DragonBody", Services.ResourceManager:getGlobalPool())
		self.rBody:setMaterialByName("DragonBody", Services.ResourceManager:getGlobalPool())

		self:setScale(6,6,6)
		--self.y = self.levelScale*4*0.5
	else  

		bodyMesh:addVertexWithUV((i*scale)+scale,0,(j*scale),(indexX * cellSizeX) + cellSizeX,indexY*cellSizeY)  
		bodyMesh:addVertexWithUV((i*scale)+scale,sheight,(j*scale),(indexX * cellSizeX) + cellSizeX,(indexY * cellSizeY) + cellSizeY)
		bodyMesh:addVertexWithUV((i*scale),sheight,(j*scale),indexX*cellSizeX,(indexY * cellSizeY) + cellSizeY)

		bodyMesh:addVertexWithUV((i*scale),0,(j*scale),(indexX * cellSizeX),(indexY * cellSizeY))	   
		bodyMesh:addVertexWithUV((i*scale)+scale,0,(j*scale),(indexX * cellSizeX)+cellSizeX,(indexY * cellSizeY))  
		bodyMesh:addVertexWithUV((i*scale),sheight,(j*scale),(indexX * cellSizeX),(indexY * cellSizeY)+cellSizeY)
  
		bodyMesh:calculateNormals()
		self.rBody = SceneMesh.SceneMeshFromMesh(bodyMesh)
		self.body = self.rBody

		indexX = indexX + 1

		bodyMesh = Mesh(Mesh.TRI_MESH)
		bodyMesh.indexedMesh = false

		bodyMesh:addVertexWithUV((i*scale)+scale,0,(j*scale),(indexX * cellSizeX) - cellSizeX,indexY*cellSizeY)  
		bodyMesh:addVertexWithUV((i*scale)+scale,sheight,(j*scale),(indexX * cellSizeX) - cellSizeX,(indexY * cellSizeY) + cellSizeY)
		bodyMesh:addVertexWithUV((i*scale),sheight,(j*scale),indexX*cellSizeX,(indexY * cellSizeY) + cellSizeY)

		bodyMesh:addVertexWithUV((i*scale),0,(j*scale),(indexX * cellSizeX),(indexY * cellSizeY))	   
		bodyMesh:addVertexWithUV((i*scale)+scale,0,(j*scale),(indexX * cellSizeX)-cellSizeX,(indexY * cellSizeY))  
		bodyMesh:addVertexWithUV((i*scale),sheight,(j*scale),(indexX * cellSizeX),(indexY * cellSizeY)+cellSizeY)
  
		bodyMesh:calculateNormals()
		self.lBody = SceneMesh.SceneMeshFromMesh(bodyMesh)

		self.lBody:Translate(0,0,0)
		self.rBody:Translate(0,0,0)

		self.lBody:setMaterialByName("Creature", Services.ResourceManager:getGlobalPool())
		self.rBody:setMaterialByName("Creature", Services.ResourceManager:getGlobalPool())
	end
  
	self.rBody.billboardMode = true
	self.rBody.billboardRoll = true
	self.rBody.alphaTest = true

	self.lBody.billboardMode = true
	self.lBody.billboardRoll = true
	self.lBody.alphaTest = true

	self.bodyAnchor:addChild(self.rBody)
	self.bodyAnchor:addChild(self.lBody)

	self.lBody.visible = false

	local shieldMesh = Mesh(Mesh.TRI_MESH)
	shieldMesh.indexedMesh = false

	shieldMesh:addVertexWithUV((i*self.levelScale)+scale,0,(j*scale),1,0)  
	shieldMesh:addVertexWithUV((i*scale)+scale,sheight,(j*scale),1,1)
	shieldMesh:addVertexWithUV((i*scale),sheight,(j*scale),0,1)

	shieldMesh:addVertexWithUV((i*scale),0,(j*scale),0,0)	   
	shieldMesh:addVertexWithUV((i*scale)+scale,0,(j*scale),1,0)
	shieldMesh:addVertexWithUV((i*scale),sheight,(j*scale),0,1)

	shieldMesh:calculateNormals()

	self.shield = SceneMesh.SceneMeshFromMesh(shieldMesh)
	self.shield:setMaterialByName("Shield", Services.ResourceManager:getGlobalPool())
	self.bodyAnchor:addChild(self.shield)

	self.shield.billboardMode = true
	self.shield.billboardRoll = true

	self.shieldX = 0.025
	self.shieldY = 0.01

	self.shield.visible = false
	self.hasShield = false
  
	self.xSpeed = 0
	self.zSpeed = 0
	self.movDirMod = 1
	self.speed = 0.5
	self.moving = false
	self.jumping = false
	self.attacking = false
	self.slash.visible = false
	self.moveVal = math.random(100)
	self.cloakAgainTimer = 0
	self.falling = false
	self.dragonAttacking = false
	self.dragonAttackVal = 0
	self:Update(0.1)
	self.targetCreature = nil
end


function Creature:checkHitZ(fromZ, toZ, fromX, toX)
	if self.boss == true then
		if ((fromZ < self:getPosition().z and fromZ > self:getPosition().z-0.3) or (toZ < self:getPosition().z and toZ > self:getPosition().z-0.3)) and self:getPosition().x > fromX  and self:getPosition().x < toX then
			return true
		else
			return false
		end
	else
		if self:getPosition().z < fromZ and self:getPosition().z > toZ and self:getPosition().x > fromX  and self:getPosition().x < toX then
			return true
		else
			return false
		end
	end
end


function Creature:checkHitX(fromX, toX, fromZ, toZ)
	if self.boss == true then
		if ((fromX > self:getPosition().x and fromX < self:getPosition().x+0.3) or (toX > self:getPosition().x and toX < self:getPosition().x+0.3)) and self:getPosition().z > fromZ  and self:getPosition().z < toZ then
			return true
		else
			return false
		end
	else
		if self:getPosition().x > fromX and self:getPosition().x < toX and self:getPosition().z > fromZ  and self:getPosition().z < toZ then
			return true
		else
			return false
		end
	end
end


function Creature:Fall()
	self.falling = true
end

function Creature:showIcon(iconName)
	self.icon.visible = true
	self.icon:setMaterialByName(iconName, Services.ResourceManager:getGlobalPool())
	self.icon:setColor(1,1,1,1)
	self.iconVal = 1
end

function Creature:jump()
	if self.jumping == false then
		jumpSound:Play()
		self.yAccel = 3
		self.jumping = true
	end
end

function Creature:Unfreeze()
	self.frozen = false
	if self.boss == true then
		self.body:setMaterialByName("DragonBody", Services.ResourceManager:getGlobalPool())
	else
		self.body:setMaterialByName("Creature", Services.ResourceManager:getGlobalPool())
	end

	self.shield:setMaterialByName("Shield", Services.ResourceManager:getGlobalPool())
end

function Creature:Cloak()
	if self.cloakAgainTimer < 2 then return end
	if self.cloaked == false then
		cloakSound:Play()
		self.cloaked = true
		self.cloakTimer = 0
		level:losePlayer()
	end
end

function Creature:Uncloak()
	uncloakSound:Play()
	self.cloaked = false
	self.cloakAgainTimer = 0
end

function Creature:Freeze()
	
	if self.frozen == true and self == self.level.player then
		return
	end

	self.frozen = true
	self.hurting = false

	if self.boss == true then
		self.body:setMaterialByName("DragonBodyLight", Services.ResourceManager:getGlobalPool())
	else
		self.body:setMaterialByName("CreatureLight", Services.ResourceManager:getGlobalPool())
		self.shield:setMaterialByName("ShieldLight", Services.ResourceManager:getGlobalPool())
	end

	self.freezeTimer = 0
	self:setSpeed(0,0)
end


function Creature:shootArrow()
	arrowShootSound:Play()
	level:shootArrow(self)
end

function Creature:castSpell()
--	self.castSpellSound:Play()
	arrowChargeSound:Stop()
	if self.spellID == 0 then
		local fireball = level:castFireball(self)
		if self.boss == true then
			fireball.y = 0.3
			self.lBody:setMaterialByName("DragonBodyAttack", Services.ResourceManager:getGlobalPool())
			self.rBody:setMaterialByName("DragonBodyAttack", Services.ResourceManager:getGlobalPool())
			self.dragonAttacking = true
			self.dragonAttackVal = 0
		end
	elseif self.spellID == 1 then
		level:castIceball(self)
	end
end

function Creature:attack()

	if self.attacking == false then
		attackSound:Play()
--		self:Unblock()
		if self.hurting == true and self.shieldHurt == false then
			self.body:setMaterialByName("CreatureNoWeaponHurt", Services.ResourceManager:getGlobalPool())
		else
			self.body:setMaterialByName("CreatureNoWeapon", Services.ResourceManager:getGlobalPool())
		end
		if self.movDirMod == 1 then
			self.slash:setPositionX(0.06)
			self.slash:setPositionY(0.08)
			self.slash:setMaterialByName("Slash", Services.ResourceManager:getGlobalPool())
		else
			self.slash:setPositionX(0.00)
			self.slash:setPositionY(0.05)
			self.slash:setMaterialByName("SlashB", Services.ResourceManager:getGlobalPool())
		end
		self.slash:setRoll(120)
		self.slash.visible = true
		self.attacking = true
	end
	
	self.level:creatureAttack(self)
end

function Creature:setSpeed(xSpeed,zSpeed)
  
  self.xSpeed = xSpeed
  self.zSpeed = zSpeed
  
  if xSpeed == 0 and zSpeed == 0 then
	self.moving = false
  else
	if levelRotate == true then
	if zSpeed ~= 0 then
		if zSpeed < 0 then
			self.rBody.visible = true
			self.lBody.visible = false
			self.body = self.rBody
			self.movDirMod = 1
		else
			self.lBody.visible = true
			self.rBody.visible = false
			self.body = self.lBody
			self.movDirMod = -1
		end
	end
	else
	if xSpeed ~= 0 then
		if xSpeed < 0 then
			self.lBody.visible = true
			self.rBody.visible = false
			self.body = self.lBody
			self.movDirMod = -1
		else
			self.rBody.visible = true
			self.lBody.visible = false
			self.body = self.rBody
			self.movDirMod = 1
		end
	end
	end
	self.moving = true
  end

end

function Creature:useItem(item)
	if item.type == "heart" then
		heartPickupSound:Play()
		if self.HP < self.maxHP then
			self.HP = self.HP + 1
		end
	elseif item.type == "golds" then
		goldPickupSound:Play()
		self.gold = self.gold + 10
	end
end

function Creature:Die()
	pauseVal = 0.06
	hud.flashVal = 0.5
	hud.flashColor = Color(1.0, 1.0, 1.0, 1.0)
	self.dead = true
	self.dying = true
	self:setSpeed(0,0)
	self.moving = false
	self.slash.visible = false
	if self.level.player == self then
		doGameOver()
	elseif self.boss == true then
		doGameEnd()
	else
		if random() < 0.1 then
			 self.level:dropItem(self:getPosition().x, self:getPosition().z, "heart")
			 return
		elseif random() < 0.3 then
			 self.level:dropItem(self:getPosition().x, self:getPosition().z, "golds")
			return
		end	   

	end
end

function Creature:Block()
	--   self.shield.visible = true
	if self.blocking == false then
		self.blocking = true
		shieldUpSound:Play()
			self.shieldHurt = true
			self:Hurt()

	end
end

function Creature:Unblock()
   --	self.shield.visible = false
	if self.blocking == true then
		self.blocking = false
		shieldDownSound:Play()
	end
end


function Creature:Hurt()
	self.hurting = true
	self.collideWalls = true
	self.hurtVal = 0

	if self.frozen == true then
		self:Unfreeze()
	end

	if self.level.player ~= self then
		if self.targetCreature == nil then
			self:showIcon("Exclamation")
			alertSound:Play()
			self.targetCreature = self.level.player
		end
	end

	if self.shieldHurt ~= true then
		if self.boss == true then 
			self.lBody:setMaterialByName("DragonBodyHurt", Services.ResourceManager:getGlobalPool())
			self.rBody:setMaterialByName("DragonBodyHurt", Services.ResourceManager:getGlobalPool())
		else
			self.lBody:setMaterialByName("CreatureHurt", Services.ResourceManager:getGlobalPool())
			self.rBody:setMaterialByName("CreatureHurt", Services.ResourceManager:getGlobalPool())
		end

		if self.level.player == self then
			hud.flashVal = 1.0
			pauseVal = 0.04
			hud.flashColor = Color(1.0, 0.0, 0.0, 1.0)
		end

		if self.dummy == true then
			dummyHurtSound:Play()
		else
			hurtSound:Play()
		end
	else
		shieldHitSound:Play()
	end
	
	if self.frozen == false then
		self.shield:setMaterialByName("ShieldHurt", Services.ResourceManager:getGlobalPool())
	end
end

function Creature:getHit()
	if self.dead == true then return false end

	if self.blocking == true then
			self.shieldHurt = true
			self:Hurt()
			return false
	else
		self.HP = self.HP - 1
		if self.HP <= 0 then
			self:Hurt()
			self:Die()
		else
			self:Hurt()
		end 
	end
	return true
end

function Creature:thinkAttackMelee(e)
	if self.targetCreature == nil then return end

	if self.thinkAttackMode == 0 then
		 self.targetPoint = {}
		 if self.hasShield == true then
			  self:Block()
		 end

		if levelRotate == true then
			if self.rightAttack == true then
				self.targetPoint.y = self.targetCreature:getPosition().z + 0.1
			else
				self.targetPoint.y = self.targetCreature:getPosition().z - 0.08
			end
			self.targetPoint.x = self.targetCreature:getPosition().x
		else
			if self.rightAttack == true then
				self.targetPoint.x = self.targetCreature:getPosition().x + 0.1
			else
				self.targetPoint.x = self.targetCreature:getPosition().x - 0.08
			end
			self.targetPoint.y = self.targetCreature:getPosition().z
		end
		 self:followTargetPoint()
	else   
		 self:followTargetPoint()
	end

	self.thinkAttackTimer = self.thinkAttackTimer + (1000 * e)

	if self.thinkAttackTimer > 1000 then
		if self.thinkAttackMode == 0 then
			self.thinkAttackMode = 1
			self.targetPoint = self.fallbackTargetPoint
		
		  if levelRotate == true then
		 if self.rightAttack == true then
			 self:setSpeed(-0.001,0)
		 else
			 self:setSpeed(0.001,0)
		 end
		else
		 if self.rightAttack == true then
			 self:setSpeed(0,-0.001)
		 else
			 self:setSpeed(0,0.001)
		 end

		end
			self:Unblock()
			self:attack()
		else
			self.fallbackTargetPoint = {}
			self.fallbackTargetPoint.x = self:getPosition().x
			self.fallbackTargetPoint.y = self:getPosition().z
		   self.thinkAttackMode = 0
		end
		self.thinkAttackTimer = 0
	end
end

function Creature:thinkAttackArcher(e)
	if self.targetCreature == nil then return end
	local shouldBeShooting = false
	 
	if levelRotate == true then

	if self:getPosition().x > self.targetCreature:getPosition().x - 0.01 and self:getPosition().x < self.targetCreature:getPosition().x + 0.01 then
		shouldBeShooting = true
	else
		if self:getPosition().x > self.targetCreature:getPosition().x then
			self:setSpeed(-self.speed, self.zSpeed)
		else
			self:setSpeed(self.speed, self.zSpeed)	
		end
	end


	else

	if self:getPosition().z > self.targetCreature:getPosition().z - 0.01 and self:getPosition().z < self.targetCreature:getPosition().z + 0.01 then
		shouldBeShooting = true
	else
		if self:getPosition().z > self.targetCreature:getPosition().z then
			self:setSpeed(self.xSpeed, -self.speed)
		else
			self:setSpeed(self.xSpeed, self.speed)	
		end
	end

	end

	if shouldBeShooting == true then
	self:setSpeed(0,0)

	if self.aiArcherTimer > 3000 then

		  if levelRotate == true then
		 if self:getPosition().z > self.targetCreature:getPosition().z == true then
			 self:setSpeed(0,-0.001)
		 else
			 self:setSpeed(0,0.001)
		 end
		else
		 if self:getPosition().x > self.targetCreature:getPosition().x == true then
			 self:setSpeed(-0.001,0)
		 else
			 self:setSpeed(0.001,0)
		 end

		end

		local distance = self.targetCreature:getPosition():distance(self:getPosition())

		self.arrowCharge = (5 * (distance/0.9)) - 1 + (math.random() * 2)
		self:shootArrow()
		self.aiArcherTimer = 0
	end
	else
	end
end

function Creature:thinkAttackMage(e)
	if self.targetCreature == nil then return end
	local shouldBeShooting = false
	 
	if levelRotate == true then

	if self:getPosition().x > self.targetCreature:getPosition().x - 0.01 and self:getPosition().x < self.targetCreature:getPosition().x + 0.01 then
		shouldBeShooting = true
	else
		if self:getPosition().x > self.targetCreature:getPosition().x then
			self:setSpeed(-self.speed, self.zSpeed)
		else
			self:setSpeed(self.speed, self.zSpeed)	
		end
	end


	else

	if self:getPosition().z > self.targetCreature:getPosition().z - 0.01 and self:getPosition().z < self.targetCreature:getPosition().z + 0.01 then
		shouldBeShooting = true
	else
		if self:getPosition().z > self.targetCreature:getPosition().z then
			self:setSpeed(self.xSpeed, -self.speed)
		else
			self:setSpeed(self.xSpeed, self.speed)	
		end
	end

	end
  
	local timeOut = 3000

	if self.boss == true then
--		shouldBeShooting = true
		timeOut = 1500
	end

	if shouldBeShooting == true then
	self:setSpeed(0,0)
	if self.aiArcherTimer > timeOut then

		  if levelRotate == true then
		 if self:getPosition().z > self.targetCreature:getPosition().z == true then
			 self:setSpeed(0,-0.001)
		 else
			 self:setSpeed(0,0.001)
		 end
		else
		 if self:getPosition().x > self.targetCreature:getPosition().x == true then
			 self:setSpeed(-0.001,0)
		 else
			 self:setSpeed(0.001,0)
		 end

		end

		self:castSpell()
		self.aiArcherTimer = 0
	end
	else
	end
end

function Creature:thinkAttack(e)
	self.collideWalls = true
	if self.targetCreature == nil then return end

	if self.thinkType == AI_MELEE then
		self:thinkAttackMelee(e)
	elseif self.thinkType == AI_ARCHER then
		self:thinkAttackArcher(e)
	elseif self.thinkType == AI_MAGE then
		self:thinkAttackMage(e)
	end
end

function Creature:followTargetPoint()
		if self.targetPoint == nil then return end

		self.moving = true

	if levelRotate == true then
	if self:getPosition().z < self.targetPoint.y - 0.02 or self:getPosition().z > self.targetPoint.y + 0.02 then
		if self:getPosition().z < self.targetPoint.y then
			self:setSpeed(self.xSpeed,self.speed)
		else
			self:setSpeed(self.xSpeed,-self.speed)
		end
	else
			self:setSpeed(0,self.zSpeed)
	end

		if self:getPosition().x < self.targetPoint.x then
			self:setSpeed(self.speed,self.zSpeed)
		else
			self:setSpeed(-self.speed,self.zSpeed)
		end

	
	else
	if self:getPosition().x < self.targetPoint.x - 0.02 or self:getPosition().x > self.targetPoint.x + 0.02 then
		if self:getPosition().x < self.targetPoint.x then
			self:setSpeed(self.speed,self.zSpeed)
		else
			self:setSpeed(-self.speed,self.zSpeed)
		end
	else
			self:setSpeed(0,self.zSpeed)
	end

		if self:getPosition().z < self.targetPoint.y then
			self:setSpeed(self.xSpeed,self.speed)
		else
			self:setSpeed(self.xSpeed,-self.speed)
		end


	end		

end

function Creature:loseSight()
	if self.dead == true then return end

	if self.targetCreature ~= nil then
		self:showIcon("Question")
		whereSound:Play()
	end

	self.targetCreature = nil
	self:setSpeed(0,0)
	self.aiMode = 0
end

function Creature:thinkSeek(e)
	self.collideWalls = false
	self:Unblock()
	
	local aggroDistance = 1
	if self.boss == true then aggroDistance = 2 end

	if self:getPosition():distance(self.level.player:getPosition()) < aggroDistance and self.level.player.cloaked == false then
		if self.targetCreature == nil then self:showIcon("Exclamation") alertSound:Play() end
		self.targetCreature = self.level.player
	end

	if self.targetPoint then
		if self:getPosition().x > self.targetPoint.x - 0.1 and self:getPosition().x < self.targetPoint.x + 0.1 and self:getPosition().z > self.targetPoint.y - 0.1 and self:getPosition().z < self.targetPoint.y + 0.1 then
			self.targetPoint = nil   
		end
	end
	
	self.pathThinkTimer  = self.pathThinkTimer + (250 * e)

	if self.targetCreature and self.targetPoint == nil and self.pathThinkTimer > 1000 then
		local targetPath = nil
		local targetPathLength = 0

		targetPath,targetPathLength = self.level:getTargetPath(self, self.targetCreature)

		self.targetPath = targetPath
		self.targetPathLength = targetPathLength
		self.targetPathIndex = 0
		self.pathThinkTimer = 0
	end

	if self.targetCreature and self.targetPoint == nil and self.targetPath ~= nil then
		if self.targetPathIndex < self.targetPathLength then
			self.targetPoint = self.targetPath[self.targetPathLength-self.targetPathIndex-1]
			self.targetPathIndex = self.targetPathIndex + 1
		else
			self.pathThinkTimer = 800 + math.random(200)
			self.targetPoint = nil
		end
	end	

	if self.targetPoint then
		self:followTargetPoint()
	else
		self:setSpeed(0,0)
		self.moving = false
	end
end

function Creature:Think(e)

	if self.dead == true or self.falling == true then
		return
	end

	if self.friendly == true or self.dummy == true then return end

	if self.frozen == true then
		self:setSpeed(0,0)
		self.moving = false
		return
	end

	self.aiArcherTimer = self.aiArcherTimer + 1000 * e

	if self.targetCreature ~= nil then
		local attackDistance = self.level.levelScale*2
		if self.thinkType == AI_ARCHER then
			attackDistance = self.level.levelScale*3
		end

		if self.boss == true then attackDistance = self.level.levelScale*5 end

		if self.targetCreature:getPosition():distance(self:getPosition()) < attackDistance then
			self.aiMode = 1
		else
			self.aiMode = 0
		end
	end
	
	if self.aiMode == 0 then
		self:thinkSeek(e)
	elseif self.aiMode == 1 then
		self:thinkAttack(e)
	end

end

function Creature:Update(e) 

	
	if self.dragonAttacking == true then
			self.dragonAttackVal = self.dragonAttackVal + e
			if self.dragonAttackVal > 0.3 then
				self.dragonAttacking = false
--				if self.hurting == false then
					self.lBody:setMaterialByName("DragonBody", Services.ResourceManager:getGlobalPool())
					self.rBody:setMaterialByName("DragonBody", Services.ResourceManager:getGlobalPool())
  --			  end
			end
	end

	if self.falling == true then
		self:Translate(0,-2 * e,0)
		self.yscale = 2
		return
	end

	self.iconVal = self.iconVal - e 
	self.icon:setColor(1,1,1,self.iconVal)
	if self.iconVal < 0 then
		self.icon.visible = false
	end
	
	self.cloakAgainTimer = self.cloakAgainTimer + e

	if self.cloaked == true then
		self.cloakTimer = self.cloakTimer + e
		if self.cloakTimer > 1.5 then
			self:Uncloak()
		end
	end

	if self.charging == true then
	if self.arrowCharge < 5 then 
		self.arrowCharge = self.arrowCharge + 8 * e
		self.body:setRoll(30 * (self.arrowCharge/5) * self.movDirMod)
	end
	end

	if self.spellCharging == true then
		if self.spellCharge < self.spellChargeMax then 
			self.spellCharge = self.spellCharge + 8 * e
		else
			self:castSpell()
			self.spellCharging = false
			self.spellCharge = 0
		end
	end


	if self.yAccel > -1000 then
		self.yAccel = self.yAccel - (20 * e)
	end

	if self.hurting == true then
		if self.xAccel > 0 then
			self.xAccel = self.xAccel - (10 * e)
		else
			self.xAccel = self.xAccel + (10 * e)
		end

		if self.zAccel > 0 then
			self.zAccel = self.zAccel - (10 * e)
		else
			self.zAccel = self.zAccel + (10 * e)
		end

	else
		self.zAccel = 0
		self.xAccel = 0
	end
	
	if self.dead == true then
		if self.dying == true then
			self.body:setScaleX(0.8)
			self.body:setScaleY(0.8)
			self.body:setRoll(self.body:getRoll() + 400 * e)
			self.shield:setRoll(self.shield:getRoll() + 100 * e)
			self.shield:setPositionY(self.shield:getPosition().y - e * 0.1)

			self.body:setPositionY(self.body:getPosition().y - e * 0.1)
			self.body:setPositionX(self.body:getPosition().x + e * 0.1)
			if self.body:getRoll() > 90 then
				self.dying = false
			end
		end
	else
	if self.attacking == true then
		if self.movDirMod == 1 then

	   if levelRotate == true then
			self.slash:setPositionZ(-0.065)
			self.slash:setPositionX(0.03)
		else
			self.slash:setPositionZ(0.00)
			self.slash:setPositionX(0.06)
		end

		self.slash:setRoll( self.slash:getRoll() - (1400 * e))
		if self.slash:getRoll() > 70 then
			self:setScaleX((self:getScale().x - 5 * e) * self.baseXScale)
			self.body:setRoll(self.body:getRoll() + 1000 * e)
		else
			self:setScaleX((self:getScale().x + 8 * e) * self.baseXScale)
			self.body:setRoll(self.body:getRoll() - 500 * e)
		end
		if self.slash:getRoll() < -30 then
			self.attacking  = false
			self.slash.visible = false
		if self.hurting == true and self.shieldHurt == false then
			self.body:setMaterialByName("CreatureHurt", Services.ResourceManager:getGlobalPool())
		else
			self.body:setMaterialByName("Creature", Services.ResourceManager:getGlobalPool())
		end
			self.body:setRoll(0)
		end
		else

		if levelRotate == true then
			self.slash:setPositionZ(0)
			self.slash:setPositionX(0.03)
		else
			self.slash:setPositionZ(0.00)
			self.slash:setPositionX(0)
		end

		self.slash:setRoll( self.slash:getRoll() + (1400 * e))
		if self.slash:getRoll() > 170 then
			self:setScaleX((self:getScale().x - 5 * e) * self.baseXScale)
			self.body:setRoll(self.body:getRoll() - 1000 * e)
		else
			self:setScaleX((self:getScale().x + 8 * e) * self.baseXScale)
			self.body:setRoll(self.body:getRoll() + 500 * e)
		end
		if self.slash:getRoll() > 200 then
			self.attacking  = false
			self.slash.visible = false
		if self.hurting == true and self.shieldHurt == false then
			self.body:setMaterialByName("CreatureHurt", Services.ResourceManager:getGlobalPool())
		else
			if self.frozen == false then
				self.body:setMaterialByName("Creature", Services.ResourceManager:getGlobalPool())
			end
		end

			self.body:setRoll(0)
		end			
		end
	else
		self:setScaleX(self.baseXScale)
	end

	if self.hasShield then
		if self.movDirMod == -1 then
			self.shieldX = 0.025
			self.shieldY = 0.01
			if self.blocking == true then				
				self.shieldX = -0.015
				self.shieldY = 0.03
			end
		else
			self.shieldX = -0.02
			self.shieldY = 0.01

			if self.blocking == true then
				self.shieldX = 0.025
				self.shieldY = 0.03
			end

		end
	end

	local playerY = 0

	self.shadow:setScale(1,1,1)
	self.shadow:setColor(1,1,1,0.6)

	if self.frozen == true then
		self.body:setScaleY(1)
	else

	if self.jumping == true then
		self.bodyAnchor:setPositionY(self.bodyAnchor:getPosition().y + self.yAccel * e)
		self.body:setScaleY(1 + (self.bodyAnchor:getPosition().y * 1.4))
		if self.body:getScale().y > 1.4 then
			self.body:setScaleY(1.4)
		end
		local scaleVal = (self.body:getScale().y - 1) / 0.4
		self.shadow:setScale(1+(scaleVal*2),1+(scaleVal*2),1)
		self.shadow:setColor(1,1,1,0.5 * (1-scaleVal))
		self.body:setScaleX(1 - (self.body:getScale().y-1))
		if self.bodyAnchor:getPosition().y < 0 then
			self.jumping = false
			self.bodyAnchor:setPositionY(0)
		end
	elseif self.moving == true then		
		self.moveVal = self.moveVal + (50 * e)
		playerY = math.sin(self.moveVal) * 0.01
		self.body:setPositionY((self.levelScale*0.225) + playerY)
		self.body:setScaleY(1 + (playerY * 20))
		
		if self.hasShield == true then
			if levelRotate == true then
				self.shield:setPosition(0.03,-0.01+self.shieldY+ (playerY*2),-self.shieldX)
			else
				self.shield:setPosition(self.shieldX,self.shieldY+ (playerY*2),0.02)
			end
		end

		--self.body.roll = (playerY * 800 * self.movDirMod ) - (math.abs(self.movDirMod -1)*4 )
		self.body:setRoll(playerY * 800)
	else
		self.moveVal = self.moveVal + (20 * e)
		playerY = math.sin(self.moveVal) * 0.01
		self.body:setPositionY((self.levelScale*0.225)+self.bodyAdjust)
		self.body:setScaleY(1 + (playerY * 20))
		playerY = math.cos(self.moveVal) * 0.01

		if self.hasShield == true then
			if levelRotate == true then
				self.shield:setPosition(0.05,self.shieldY + (math.sin(self.moveVal+0.5) * 0.01),-self.shieldX + (playerY*0.2) +0.005)
			else
				self.shield:setPosition(self.shieldX + (playerY*0.2) ,self.shieldY + (math.sin(self.moveVal+0.5) * 0.01),0.02)
			end
		end

		self.body:setScaleX(1 + (playerY * 5))
		self.body:setPositionX(0.04 - ((0.3 * 0.25 * self.body:getScale().x) * 0.5))
		if self.attacking == false and self.charging == false then
			self.body:setRoll(0)
		end
	end
	end
end

	if self.hurting == true then
		self.hurtVal = self.hurtVal + 2 * e

		if self.shieldHurt ~= true then
			self.lBody:setColor(1-self.hurtVal,1-self.hurtVal,1-self.hurtVal,1)
			self.rBody:setColor(1-self.hurtVal,1-self.hurtVal,1-self.hurtVal,1)
		end

		self.shield:setColor(1-self.hurtVal,1-self.hurtVal,1-self.hurtVal,1)

		if self.hurtVal >= 1 then
--			if self ~= self.level.player then
--				self.collideWalls = false
--			end

			if self.boss == true then 
				self.lBody:setMaterialByName("DragonBody", Services.ResourceManager:getGlobalPool())
				self.rBody:setMaterialByName("DragonBody", Services.ResourceManager:getGlobalPool())
			else
				self.lBody:setMaterialByName("Creature", Services.ResourceManager:getGlobalPool())
				self.rBody:setMaterialByName("Creature", Services.ResourceManager:getGlobalPool())
			end
			self.shield:setMaterialByName("Shield", Services.ResourceManager:getGlobalPool())
			self.hurting = false
			self.shieldHurt = false
			self.lBody:setColor(1,1,1,1)
			self.rBody:setColor(1,1,1,1)
			self.shield:setColor(1,1,1,1)
		end
	end

	local translateOK = true
	local accelSpeed = 0.01

	local speedMod = 1
	if self.blocking == true then
		speedMod = 0.5
	end

	local selfX = self:getPosition().x
	local selfZ = self:getPosition().z

	if self.dummy == false then

	if self.collideWalls == true then
		if levelRotate == true then
			if self.xSpeed < 0 then 
			if self.level:canPass(self:getPosition().x + (self.xSpeed*e*speedMod)+(self.xAccel*accelSpeed)-0.1, selfZ) == false then
				translateOK = false
			end
			else
			if self.level:canPass(self:getPosition().x + (self.xSpeed*e*speedMod)+(self.xAccel*accelSpeed), selfZ) == false then
				translateOK = false
			end

			end
		else
		if self.movDirMod == 1 then
			if self.level:canPass(self:getPosition().x + (self.xSpeed*e*speedMod)+(self.xAccel*accelSpeed), selfZ) == false then
				translateOK = false
			end
		else
			if self.level:canPass(self:getPosition().x + (self.xSpeed*e*speedMod)+(self.xAccel*accelSpeed)-0.1, selfZ) == false then
				translateOK = false
			end
		end
		end
	end

	if translateOK == true then 
		if self.jumping == true then
			self:Translate((self.xSpeed*e*1.3*speedMod)+(self.xAccel*accelSpeed),0,0)
		else
			self:Translate((self.xSpeed*e*speedMod)+(self.xAccel*accelSpeed),0,0)
		end
	end

	translateOK = true

	if self.collideWalls == true then		
		if self.zSpeed < 0 then
			if self.level:canPass(selfX, (self.zAccel*accelSpeed) + self:getPosition().z + (self.zSpeed*e*speedMod)) == false then
				translateOK = false
			end
		else
			if self.level:canPass(selfX, (self.zAccel*accelSpeed) + self:getPosition().z + (self.zSpeed*e*speedMod)+0.1) == false then
				translateOK = false
			end
		end
	end

	if translateOK == true then 
		if self.jumping == true then
			self:Translate(0,0,(self.zAccel*accelSpeed) + (self.zSpeed*e*1.3*speedMod))
		else
			self:Translate(0,0,(self.zAccel*accelSpeed) +(self.zSpeed*e*speedMod))
		end
	end

	end
	
	if self.frozen == true then
		local frozenTime = 3000
		if self == self.level.player then frozenTime = 1000 end   

		self:setColor(0,0.2,0.8, 0.9)
		self.freezeTimer = self.freezeTimer + e * 1000
		
		if self.freezeTimer > frozenTime then 
			self:Unfreeze()
		end
	else
		self:setColor(1,1,1,1)
	end

	self.bodyAnchor:setScaleX(1)
	self.bodyAnchor:setScaleY(1)

	if self.cloaked == true then
		self:setColor(1,1,1,0.3)
	end


	if self.boss == true then
		if levelRotate == true then
			self.body:setPositionX(0.003)
		else
			self.body:setPositionX(0.03 * levelRotateVal)
		end
	else
		self.body:setPositionX(0.03 * levelRotateVal)
	end
  
end



