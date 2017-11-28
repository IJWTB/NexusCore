--[[-------------------------------------------------
	Developed by Nexus [BR]

	@license: Attribution-NonCommercial 4.0 International - <https://creativecommons.org/licenses/by-nc/4.0/legalcode>
	@user Steam Profile: http://steamcommunity.com/profiles/76561197983103320

	Created: 05-11-2012
	Updated: 30-07-2016	08:03 PM
---------------------------------------------------]]

if ( SERVER ) then
	local math = math
	local type = type
	local game = game
	local util = util
	local string = string
	local tobool = tobool
	local Vector = Vector
	local CurTime = CurTime
	
	local fallDamageCVar = GetConVar( "mp_falldamage" )
	
	-- Loading Messages
	Msg( "/====================================\\\n")
	Msg( "||     Nexus Core (E2 Functions)    ||\n" )
	Msg( "||----------------------------------||\n" )
	
	-- Register
	E2Lib.RegisterExtension("nexuscore", true)
	
	local antiSpamTimeout = 2
	local fallDamageList = {}
	
	local function getFallDamage( ply, speed )
		if ( fallDamageList[ply:UniqueID()] == "ENABLE" or not fallDamageList[ply:UniqueID()] ) then -- realistic fall damage is on
			if ( fallDamageCVar:GetInt() > 0 ) then -- realistic fall damage is on
				return speed * 0.225; -- near the Source SDK value
			end
			
			return 10
		elseif ( fallDamageList[ply:UniqueID()] == "DISABLE" ) then
			return 0
		end
	end
	hook.Add( "GetFallDamage", "nexuscore.getfalldamage", getFallDamage )
	
	
	local function Animate( Ent, Animation )
		-- If Entity is Valid and Animation are not Empty
		if ( Ent:IsValid() and Animation ~= "" ) then
			-- If Entity is not animated
			if ( not Ent.Animated ) then
				-- This must be run once on entities that will be animated
				Ent.Animated = true
				Ent.AutomaticFrameAdvance = true
				-- Think on Entity
				local OldThink = Ent.Think
				function Ent:Think()
					OldThink(self)
					self:NextThink( CurTime() )
					return true
				end
			end
			
			-- If Animation is String
			if ( type(Animation) == "string" ) then
				-- If Animation are not Empty
				if ( string.Trim(Animation) == "" ) then
					Animation = 0
				else
					-- Find Animation Number
					Animation = Ent:LookupSequence( string.Trim( Animation ) ) or 0
				end
			end
			
			-- Floor
			Animation = math.floor( Animation )
			
			-- Reset Sequence
			Ent:ResetSequence( Animation )
			-- Set Cycle of Zero
			Ent:SetCycle( 0 )
			-- Set PlayBack Rate at One
			Ent:SetPlaybackRate( 1 )
		end
	end
	
	-- Log Loading Message
	Msg( "|| Loading...                       ||\n" )
	
	--[[-------------------------------------------------
		Function: teleport
	---------------------------------------------------]]
	
	__e2setcost(50)
	
	e2function void entity:teleport(vector pos)
		local isAdmin = false
		local antiSpam = false
		local propProtection = false
		local ReUseList = {}
		local Ent = this
		
		-- If entity is not Valid
		if ( this and this:IsValid() ) then 
			-- If Game is Single Player then Return True
			if ( game.SinglePlayer() ) then isAdmin = true end
			-- If is Admin quit with true
			if ( self.player:IsAdmin() ) then isAdmin = true end
			
			if ( not isAdmin ) then
				-- Set Player In ReUseList
				if ( not ReUseList[self.player:UniqueID()] ) then
					ReUseList[self.player:UniqueID()] = -1
				end
				
				-- Check if user are not spaming with the e2
				if ( ReUseList[self.player:UniqueID()] == -1 ) then
					antiSpam = true
				elseif ( CurTime() > ReUseList[self.player:UniqueID()] ) then 
					antiSpam = true
				end
				
				-- If Pass
				if ( antiSpam ) then
					-- Set ReUseList Timeout
					ReUseList[self.player:UniqueID()] = CurTime() + antiSpamTimeout
					-- If This is a Player
					if ( not this:IsPlayer() ) then
						Ent = this.player
					end
					-- Check if is Allowed
					propProtection = ( this == self.player or E2Lib.isOwner(self, this) or E2Lib.isFriend( Ent, self.player) )
				end
			end
		end
		
		-- If Player is Admin or passed on AntiSpam and Prop Protection
		if ( isAdmin or ( antiSpam and propProtection ) ) then
			-- If is Player
			if ( this:IsPlayer() ) then
				-- If Player is In Vehicle
				if ( this:InVehicle() ) then
					-- Force Player get out from Vehicle
					this:ExitVehicle()
				end 
			end
			-- Teleport entity to Position
			this:SetPos( Vector(pos[1], pos[2], pos[3]) )
		end
	end
	
	--[[-------------------------------------------------
		Function: playerUniqueID
	---------------------------------------------------]]
	
	__e2setcost(5)
	
	e2function number entity:playerUniqueId()
		-- If entity is not Valid
		if ( not this:IsValid() ) then return 0 end 
		-- If entity is Not a Player
		if ( not this:IsPlayer() ) then return 0 end
		-- Return Player UniqueID
		return this:UniqueID()
	end
	
	--[[-------------------------------------------------
		Function: ApplyPlayerForce
	---------------------------------------------------]]
	
	__e2setcost(20)
	
	e2function void entity:applyPlayerForce(vector pos)
		local isAdmin = false
		local propProtection = false
		local Ent = this
		
		-- If entity is not Valid
		if ( this:IsValid() and this:IsPlayer() ) then
			-- If Game is Single Player then Return True
			if ( game.SinglePlayer() ) then isAdmin = true end
			-- If is Admin quit with true
			if ( self.player:IsAdmin() ) then isAdmin = true end
			
			if ( not isAdmin ) then
				-- If This is a Player
				if ( not this:IsPlayer() ) then
					Ent = this.player
				end
				-- Check if is Allowed
				propProtection = ( this == self.player or E2Lib.isOwner(self, this) or E2Lib.isFriend( Ent, self.player) )
			end
		end
		
		-- If Player is Admin or passed on AntiSpam and Prop Protection
		if ( isAdmin or propProtection ) then
			-- If is Player
			if ( this:IsPlayer() ) then
				-- If Player is In Vehicle
				if ( this:InVehicle() ) then
					-- Force Player get out from Vehicle
					this:ExitVehicle()
				end 
			end
			-- Apply Velocity to entity
			this:SetVelocity( Vector(pos[1],pos[2],pos[3]) )
		end
	end
	
	--[[-------------------------------------------------
		Function: hasNoCollideAll
	---------------------------------------------------]]
	
	__e2setcost(1)
	
	e2function number entity:hasNoCollideAll()
		-- If entity is not Valid
		if ( not this:IsValid() ) then return false end 
		
		-- Return if entity has No CollideAll
		return tobool( this:GetCollisionGroup() == COLLISION_GROUP_WORLD )
	end
	
	--[[-------------------------------------------------
		Function: setCollideAll
	---------------------------------------------------]]
	
	__e2setcost(50)
	
	e2function void entity:setNoCollideAll()
		local isAdmin = false
		local propProtection = false
		local Ent = this
		
		-- If entity is not Valid
		if ( this:IsValid() and not this:IsPlayer() ) then
			-- If Game is Single Player then Return True
			if ( game.SinglePlayer() ) then isAdmin = true end
			-- If is Admin quit with true
			if ( self.player:IsAdmin() ) then isAdmin = true end
			
			if ( not isAdmin ) then
				-- If This is a Player
				if ( not this:IsPlayer() ) then
					Ent = this.player
				end
				-- Check if is Allowed
				propProtection = ( this == self.player or E2Lib.isOwner(self, this) or E2Lib.isFriend( Ent, self.player) )
			end
		end
		
		-- If Player is Admin or passed on Prop Protection
		if ( isAdmin or propProtection ) then
			-- Apply Velocity to entity
			this:SetCollisionGroup( COLLISION_GROUP_WORLD )
		end
	end
	
	--[[-------------------------------------------------
		Function: removeNoCollideAll
	---------------------------------------------------]]
	
	__e2setcost(25)
	
	e2function void entity:removeNoCollideAll()
		local isAdmin = false
		local propProtection = false
		local Ent = this
		
		-- If entity is not Valid
		if ( this:IsValid() and not this:IsPlayer() ) then
			-- If Game is Single Player then Return True
			if ( game.SinglePlayer() ) then isAdmin = true end
			-- If is Admin quit with true
			if ( self.player:IsAdmin() ) then isAdmin = true end
			
			if ( not isAdmin ) then
				-- If This is a Player
				if ( not this:IsPlayer() ) then
					Ent = this.player
				end
				-- Check if is Allowed
				propProtection = ( this == self.player or E2Lib.isOwner(self, this) or E2Lib.isFriend( Ent, self.player) )
			end
		end
		
		-- If Player is Admin or passed on Prop Protection
		if ( isAdmin or propProtection ) then
			-- Remove No CollideAll
			this:SetCollisionGroup( COLLISION_GROUP_NONE )
		end
	end

	--[[-------------------------------------------------
		Function: setOwner
	---------------------------------------------------]]
	
	__e2setcost(200)
	
	e2function void entity:setOwner(entity player)
		-- If is not valid then quit
		if ( not this:IsValid() ) then return end
		-- If is player then quit
		if ( this:IsPlayer() ) then return end
		-- If Player is Really a player then quit
		if ( not player:IsPlayer() ) then return end

		-- Check if Player is not Admin and Game is Not SinglePlayer
		if ( self.player:IsAdmin() and not game.SinglePlayer() ) then
			-- Set Owner
			-- this.Owner = player
			this:SetPlayer( player )
		end	
	end
	
	--[[-------------------------------------------------
		Function: ignite
	---------------------------------------------------]]
	
	__e2setcost(50)
	
	e2function void entity:ignite()
		local isAdmin = false
		local propProtection = false
		local Ent = this
		
		-- If entity is not Valid
		if ( this:IsValid() ) then
			-- If Game is Single Player then Return True
			if ( game.SinglePlayer() ) then isAdmin = true end
			-- If is Admin quit with true
			if ( self.player:IsAdmin() ) then isAdmin = true end
			
			if ( not isAdmin ) then
				-- If This is a Player
				if ( not this:IsPlayer() ) then
					Ent = this.player
				end
				-- Check if is Allowed
				propProtection = ( this == self.player or E2Lib.isOwner(self, this) or E2Lib.isFriend( Ent, self.player) )
			end
		end
		
		-- If Player is Admin or passed on Prop Protection
		if ( isAdmin or propProtection ) then
			-- Ignite
			this:Ignite( 99999999, 0 )
		end
	end
	
	--[[-------------------------------------------------
		Function: extinguish
	---------------------------------------------------]]
	
	__e2setcost(15)
	
	e2function void entity:extinguish()
		local isAdmin = false
		local propProtection = false
		local Ent = this
		
		-- If entity is not Valid
		if ( this:IsValid() ) then
			-- If Game is Single Player then Return True
			if ( game.SinglePlayer() ) then isAdmin = true end
			-- If is Admin quit with true
			if ( self.player:IsAdmin() ) then isAdmin = true end
			
			if ( not isAdmin ) then
				-- If This is a Player
				if ( not this:IsPlayer() ) then
					Ent = this.player
				end
				-- Check if is Allowed
				propProtection = ( this == self.player or E2Lib.isOwner(self, this) or E2Lib.isFriend( Ent, self.player) )
			end
		end
		
		-- If Player is Admin or passed on Prop Protection
		if ( isAdmin or propProtection ) then
			-- If Is On Fire
			if ( this:IsOnFire() ) then
				-- Extinguish
				this:Extinguish()
			end
		end
	end
	
	--[[-------------------------------------------------
		Function: setHealth
	---------------------------------------------------]]
	
	__e2setcost(100)
	
	e2function void entity:setHealth(number amount)
		-- If is not valid then quit
		if ( not this:IsValid() ) then return end
		-- If is not valid player then quit
		if ( not this:IsPlayer() ) then return end
		
		-- Check if Player is not Admin and Game is Not SinglePlayer
		if ( self.player:IsAdmin() or game.SinglePlayer() ) then
			this:SetHealth( amount )
		end
	end
	
	
	--[[-------------------------------------------------
		Function: takeDamage
	---------------------------------------------------]]
	
	__e2setcost(45)
	
	e2function void entity:takeDamage(number damageAmount)
		local isAdmin = false
		local antiSpam = false
		local propProtection = false
		local ReUseList = {}
		local Ent = this
		
		-- If entity is not Valid
		if ( this:IsValid() and not this:IsPlayer() ) then
			-- If Game is Single Player then Return True
			if ( game.SinglePlayer() ) then isAdmin = true end
			-- If is Admin quit with true
			if ( self.player:IsAdmin() ) then isAdmin = true end
			
			if ( not isAdmin ) then
				-- Set Player In ReUseList
				if ( not ReUseList[self.player:UniqueID()] ) then
					ReUseList[self.player:UniqueID()] = -1
				end
				
				-- Check if user are not spaming with the e2
				if ( ReUseList[self.player:UniqueID()] == -1 ) then
					antiSpam = true
				elseif ( CurTime() > ReUseList[self.player:UniqueID()] ) then
					antiSpam = true
				end
				
				-- If Pass
				if ( antiSpam ) then
					-- Set ReUseList Timeout
					ReUseList[self.player:UniqueID()] = CurTime() + antiSpamTimeout
					
					-- If This is a Player
					if ( not this:IsPlayer() ) then
						Ent = this.player
					end
					-- Check if is Allowed
					propProtection = ( this == self.player or E2Lib.isOwner(self, this) or E2Lib.isFriend( Ent, self.player) )
				end
			end
		end
		
		-- If Player is Admin or passed on AntiSpam and Prop Protection
		if ( isAdmin or ( antiSpam and propProtection ) ) then
			-- Take Damage
			this:TakeDamage( damageAmount, self.player, self )
		end
	end
	
	--[[-------------------------------------------------
		Function: set
	---------------------------------------------------]]
	
	__e2setcost(15)
	
	e2function void entity:set(string input, string param)
		-- If is not valid then quit
		if ( not this:IsValid() ) then return end
		
		-- Check if Player is not Admin and Game is Not SinglePlayer
		if ( self.player:IsAdmin() or game.SinglePlayer() ) then
			this:Fire( input, param )
		end
	end
	
	e2function void entity:set(string input, number param)
		-- If is not valid then quit
		if ( not this:IsValid() ) then return end
		
		-- Check if Player is not Admin and Game is Not SinglePlayer
		if ( self.player:IsAdmin() or game.SinglePlayer() ) then
			this:Fire( input, param )
		end
	end
	
	--[[-------------------------------------------------
		Function: tableToJson
	---------------------------------------------------]]
	
	__e2setcost(20)
	
	e2function string tableToJson(table data)
		-- If is not valid then quit
		if ( type( data ) ~= "table" ) then return "" end
		
		-- Convert Table to Json
		return util.TableToJSON( data )
	end
	
	e2function table jsonToTable(string data)
		if ( data == "" ) then return end
		return util.JSONToTable( data )
	end
	
	
	--[[-------------------------------------------------
		Function: animate
	---------------------------------------------------]]
	
	__e2setcost(50)
	
	e2function void entity:animate(number Animation)
		local isAdmin = false
		local propProtection = false
		
		-- If entity is not Valid
		if ( this:IsValid() ) then
			-- If This is a Player then quit
			if ( this:IsPlayer() ) then return end
			-- If Game is Single Player then Return True
			if ( game.SinglePlayer() ) then isAdmin = true end
			-- If is Admin quit with true
			if ( self.player:IsAdmin() ) then isAdmin = true end
			
			if ( not isAdmin ) then
				-- Check if is Allowed
				propProtection = ( this == self.player or E2Lib.isOwner(self, this) or E2Lib.isFriend(this, self.player) )
			end
		end
		
		-- If Player is Admin or passed on Prop Protection
		if ( isAdmin or propProtection ) then
			Animate( this, Animation )
		end
	end
	
	__e2setcost(55)
	
	e2function void entity:animate(string Animation)
		local isAdmin = false
		local propProtection = false
		
		-- If entity is not Valid
		if ( this:IsValid() ) then
			-- If This is a Player then quit
			if ( this:IsPlayer() ) then return end
			-- If Game is Single Player then Return True
			if ( game.SinglePlayer() ) then isAdmin = true end
			-- If is Admin quit with true
			if ( self.player:IsAdmin() ) then isAdmin = true end
			
			if ( not isAdmin ) then
				-- Check if is Allowed
				propProtection = ( this == self.player or E2Lib.isOwner(self, this) or E2Lib.isFriend(this, self.player) )
			end
		end
		
		-- If Player is Admin or passed on Prop Protection
		if ( isAdmin or propProtection ) then
			Animate( this, Animation )
		end
	end
	
	__e2setcost(60)
	
	e2function void entity:animate(number Sequence, number Speed)
		local isAdmin = false
		local propProtection = false
		
		-- If entity is not Valid
		if ( this:IsValid() ) then
			-- If This is a Player then quit
			if ( this:IsPlayer() ) then return end
			-- If Game is Single Player then Return True
			if ( game.SinglePlayer() ) then isAdmin = true end
			-- If is Admin quit with true
			if ( self.player:IsAdmin() ) then isAdmin = true end
			
			if ( not isAdmin ) then
				-- Check if is Allowed
				propProtection = ( this == self.player or E2Lib.isOwner(self, this) or E2Lib.isFriend(this, self.player) )
			end
		end
		
		-- If Player is Admin or passed on Prop Protection
		if ( isAdmin or propProtection ) then
			Animate( this, Sequence )
			this:SetPlaybackRate( math.max(Speed, 0) )
		end
	end
	
	__e2setcost(60)
	
	e2function void entity:animate(string Animation, number Speed)
		local isAdmin = false
		local propProtection = false
		
		-- If entity is not Valid
		if ( this:IsValid() ) then
			-- If This is a Player then quit
			if ( this:IsPlayer() ) then return end
			-- If Game is Single Player then Return True
			if ( game.SinglePlayer() ) then isAdmin = true end
			-- If is Admin quit with true
			if ( self.player:IsAdmin() ) then isAdmin = true end
			
			if ( not isAdmin ) then
				-- Check if is Allowed
				propProtection = ( this == self.player or E2Lib.isOwner(self, this) or E2Lib.isFriend(this, self.player) )
			end
		end
		
		-- If Player is Admin or passed on Prop Protection
		if ( isAdmin or propProtection ) then
			Animate( this, Animation )
			this:SetPlaybackRate( math.max(Speed, 0) )
		end
	end
	
	__e2setcost(5)
	
	e2function number entity:getAnimation()
		if ( not this:IsValid() ) then return 0 end
		return this:GetSequence() or 0
	end
	
	__e2setcost(10)
	
	e2function number entity:getAnimationByName(string Animation)
		if ( not this:IsValid() ) then return 0 end
		if ( string.Trim( Animation ) == "") then
			return 0
		else
			return this:LookupSequence( string.Trim( Animation ) ) or 0
		end
	end
	
	--[[-------------------------------------------------
		Function: disableFallDamage
	---------------------------------------------------]]
	
	__e2setcost(50)
	
	e2function number entity:disableFallDamage()
		local isAdmin = false
		local propProtection = false
		local Ent = this
		
		-- If entity is not Valid
		if ( this:IsValid() and this:IsPlayer() ) then
			-- If Game is Single Player then Return True
			if ( game.SinglePlayer() ) then isAdmin = true end
			-- If is Admin quit with true
			if ( self.player:IsAdmin() ) then isAdmin = true end
			
			if ( not isAdmin ) then
				-- If This is a Player
				if ( not this:IsPlayer() ) then
					Ent = this.player
				end
				-- Check if is Allowed
				propProtection = ( this == self.player or E2Lib.isOwner(self, this) or E2Lib.isFriend( Ent, self.player) )
			end
		end
		
		-- If Player is Admin or passed on AntiSpam and Prop Protection
		if ( isAdmin or propProtection ) then
			-- Apply Velocity to entity
			fallDamageList[this:UniqueID()] = "DISABLE"
		end
	end
	
	--[[-------------------------------------------------
		Function: enableFallDamage
	---------------------------------------------------]]
	
	__e2setcost(50)
	
	e2function number entity:enableFallDamage()
		local isAdmin = false
		local propProtection = false
		local Ent = this
		
		-- If entity is not Valid
		if ( this:IsValid() and this:IsPlayer() ) then
			-- If Game is Single Player then Return True
			if ( game.SinglePlayer() ) then isAdmin = true end
			-- If is Admin quit with true
			if ( self.player:IsAdmin() ) then isAdmin = true end
			
			if ( not isAdmin ) then
				-- If This is a Player
				if ( not this:IsPlayer() ) then
					Ent = this.player
				end
				-- Check if is Allowed
				propProtection = ( this == self.player or E2Lib.isOwner(self, this) or E2Lib.isFriend( Ent, self.player) )
			end
		end
		
		-- If Player is Admin or passed on AntiSpam and Prop Protection
		if ( isAdmin or propProtection ) then
			-- Apply Velocity to entity
			fallDamageList[this:UniqueID()] = "ENABLE"
		end
	end
	
	--[[-------------------------------------------------
		Function: egpHUDSetPlayer
	---------------------------------------------------]]
	
	__e2setcost(50)
	
	e2function void entity:egpHUDSetPlayer(entity ply)
	
		local isAdmin = false
		local propProtection = false
		local Ent = this
		
		-- If entity is not Valid
		if ( this:IsValid() and not this:IsPlayer() ) then
			-- If Game is Single Player then Return True
			if ( game.SinglePlayer() ) then isAdmin = true end
			-- If is Admin quit with true
			if ( self.player:IsAdmin() ) then isAdmin = true end
			
			if ( not isAdmin ) then
				-- If This is a Player
				if ( not this:IsPlayer() ) then
					Ent = this.player
				end
				-- Check if is Allowed
				propProtection = ( this == self.player or E2Lib.isOwner(self, this) or E2Lib.isFriend( Ent, self.player ) )
			end
		end
		
		-- If Player is Admin or passed on AntiSpam and Prop Protection
		if ( isAdmin or propProtection ) then
			if ( ply:IsValid() and Ent:IsValid() ) then
				umsg.Start( "EGP_HUD_Use", ply )
					umsg.Entity( Ent )
					umsg.Char( 1 )
				umsg.End()
			elseif ( Ent:IsValid() ) then
				umsg.Start( "EGP_HUD_Use", nil )
					umsg.Entity( Ent )
					umsg.Char( -1 )
				umsg.End()
			end
		end
	end
	
	-- Clear E2 cost for external functions
	__e2setcost(nil)

	-- Log Loading Message
	Msg( "|| Load Complete!                   ||\n" )
	Msg( "\\====================================/\n" )
end