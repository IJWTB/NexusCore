--[[-------------------------------------------------
	Developed by Nexus [BR]

	@license: Attribution-NonCommercial 4.0 International - <https://creativecommons.org/licenses/by-nc/4.0/legalcode>
	@user Steam Profile: http://steamcommunity.com/profiles/76561197983103320

	Created: 05-11-2012
	Updated: 30-07-2016	08:03 PM
---------------------------------------------------]]

if ( SERVER ) then
	local game = game
	local math = math
	local type = type
	local umsg = umsg
	local util = util
	local string = string
	local tobool = tobool
	local Vector = Vector
	local CurTime = CurTime
	local istable = istable
	local IsValid = IsValid
	local SysTime = SysTime
	local isstring = isstring
	local COLLISION_GROUP_NONE = COLLISION_GROUP_NONE
	local COLLISION_GROUP_WORLD = COLLISION_GROUP_WORLD
	
	local fallDamageCVar   = GetConVar( "mp_falldamage" )
	local isSinglePlayer   = game.SinglePlayer()
	local antiSpamTimeout  = 2 -- seconds
	local fallDamageList   = {}
	local antiSpamTeleport = {}
	local antiSpamDamage   = {}
	
	local function getFallDamage( ply, speed )
		local sid = ply:SteamID64()
		
		if ( fallDamageList[sid] or fallDamageList[sid] == nil ) then
			return fallDamageCVar:GetBool() and speed * 0.225 or 10
		end
		
		return 0
	end
	hook.Add( "GetFallDamage", "nexuscore.getfalldamage", getFallDamage )
	
	local function isAllowed( e2, ent )
		return isSinglePlayer
			or e2.player:IsAdmin()
			or ent == e2.player
			or E2Lib.isOwner( e2, ent )
			or E2Lib.isFriend( ent:IsPlayer() and ent or ent.player, e2.player )
	end
	
	local function canAnimate( e2, ent )
		return ( IsValid( ent ) and not ent:IsPlayer() )
			and (
				isSinglePlayer
				or e2.player:IsAdmin()
				or ent == e2.player
				or E2Lib.isOwner( e2, ent )
				or E2Lib.isFriend( ent, e2.player )
			)
	end
	
	local function doAnimation( ent, anim )
		if ( not IsValid( ent ) ) then return end
		
		if ( not ent.Animated ) then
			-- This must be run once on entities that will be animated
			ent.Animated = true
			ent.AutomaticFrameAdvance = true
			
			local think = ent.Think
			function ent:Think()
				think( self )
				self:NextThink( CurTime() )
				return true
			end
		end
		
		if ( isstring( anim ) ) then
			anim = anim:Trim()
			anim = anim ~= "" and anim or 0
			anim = ent:LookupSequence( anim ) or 0
		else
			anim = math.floor( anim )
		end
		
		ent:ResetSequence( anim )
		ent:SetCycle( 0 )
		ent:SetPlaybackRate( 1 )
	end
	
	-- Loading Messages
	Msg( "/====================================\\\n")
	Msg( "||     Nexus Core (E2 Functions)    ||\n" )
	Msg( "||----------------------------------||\n" )
	
	-- Register
	E2Lib.RegisterExtension( "nexuscore", true )
	
	-- Log Loading Message
	Msg( "|| Loading...                       ||\n" )
	
	
	--[[-------------------------------------------------
		Function: playerUniqueID
	---------------------------------------------------]]
	
	__e2setcost(5)
	
	e2function number entity:playerUniqueId()
		return IsValid( this ) and this:IsPlayer() and this:UniqueID() or 0
	end
	
	--[[-------------------------------------------------
		Function: teleport
	---------------------------------------------------]]
	
	__e2setcost(50)
	
	e2function void entity:teleport(vector pos)
		if ( not IsValid( this ) ) then return end
		
		local isNotSpam = false
		local isPropProtected = false
		local ent = this
		local sid = self.player:SteamID64()
		local systime = SysTime()
		
		local isAdmin = isSinglePlayer or self.player:IsAdmin()
		
		if ( not isAdmin ) then
			-- Check if user are not spaming with the e2
			if ( not antiSpamTeleport[sid] or systime > antiSpamTeleport[sid] ) then
				isNotSpam = true
			
				-- Set antiSpamTeleport Timeout
				antiSpamTeleport[sid] = systime + antiSpamTimeout
				
				isPropProtected = ( this == self.player or E2Lib.isOwner(self, this) or E2Lib.isFriend( this:IsPlayer() and ent or ent.player, self.player) )
			end
		end
		
		-- If Player is Admin or passed on AntiSpam and Prop Protection
		if ( isAdmin or ( isNotSpam and isPropProtected ) ) then
			if ( this:IsPlayer() ) then
				if ( this:InVehicle() ) then
					this:ExitVehicle()
				end 
			end
			
			-- Teleport entity to Position
			this:SetPos( pos )
		end
	end
	
	--[[-------------------------------------------------
		Function: ApplyPlayerForce
	---------------------------------------------------]]
	
	__e2setcost(20)
	
	e2function void entity:applyPlayerForce(vector pos)
		if ( not IsValid( this ) or not this:IsPlayer() ) then return end
		
		if ( isAllowed( self, this ) ) then
			if ( this:InVehicle() ) then
				this:ExitVehicle() -- Force Player get out from Vehicle
			end
			
			-- Apply Velocity to entity
			this:SetVelocity( pos )
		end
	end
	
	--[[-------------------------------------------------
		Function: hasNoCollideAll
	---------------------------------------------------]]
	
	__e2setcost(1)
	
	e2function number entity:hasNoCollideAll()
		return IsValid( this ) and tobool( this:GetCollisionGroup() == COLLISION_GROUP_WORLD )
	end
	
	--[[-------------------------------------------------
		Function: setCollideAll
	---------------------------------------------------]]
	
	__e2setcost(50)
	
	e2function void entity:setNoCollideAll()
		if ( not IsValid( this ) or this:IsPlayer() ) then return end
		
		if ( isAllowed( self, this ) ) then
			this:SetCollisionGroup( COLLISION_GROUP_WORLD )
		end
	end
	
	--[[-------------------------------------------------
		Function: removeNoCollideAll
	---------------------------------------------------]]
	
	__e2setcost(25)
	
	e2function void entity:removeNoCollideAll()
		if ( not IsValid( this ) or this:IsPlayer() ) then return end
		
		if ( isAllowed( self, this ) ) then
			this:SetCollisionGroup( COLLISION_GROUP_NONE )
		end
	end

	--[[-------------------------------------------------
		Function: setOwner
	---------------------------------------------------]]
	
	__e2setcost(200)
	
	e2function void entity:setOwner(entity ply)
		if ( not IsValid( this ) or this:IsPlayer() or not ply:IsPlayer() ) then return end
		
		if ( not isSinglePlayer and self.player:IsAdmin() ) then
			this:SetPlayer( ply )
		end	
	end
	
	--[[-------------------------------------------------
		Function: ignite
	---------------------------------------------------]]
	
	__e2setcost(50)
	
	e2function void entity:ignite()
		if ( not IsValid( this ) ) then return end
		
		if ( isAllowed( self, this ) ) then
			this:Ignite( 99999999, 0 )
		end
	end
	
	--[[-------------------------------------------------
		Function: extinguish
	---------------------------------------------------]]
	
	__e2setcost(15)
	
	e2function void entity:extinguish()
		if ( not IsValid( this ) or not this:IsOnFire() ) then return end
		
		if ( isAllowed( self, this ) ) then
			this:Extinguish()
		end
	end
	
	--[[-------------------------------------------------
		Function: setHealth
	---------------------------------------------------]]
	
	__e2setcost(100)
	
	e2function void entity:setHealth(number amount)
		if ( not IsValid( this ) or not this:IsPlayer() ) then return end
		
		if ( isSinglePlayer or self.player:IsAdmin() ) then
			this:SetHealth( amount )
		end
	end
	
	--[[-------------------------------------------------
		Function: takeDamage
	---------------------------------------------------]]
	
	__e2setcost(45)
	
	e2function void entity:takeDamage(number damageAmount)
		if ( not IsValid( this ) or this:IsPlayer() ) then return end
		
		local isNotSpam = false
		local isPropProtected = false
		local sid = self.player:SteamID64()
		local systime = SysTime()
		
		local isAdmin = isSinglePlayer or self.player:IsAdmin()
			
		if ( not isAdmin ) then
			-- Check if user are not spaming with the e2
			if ( not antiSpamDamage[sid] or systime > antiSpamDamage[sid] ) then
				isNotSpam = true
				
				-- Set antiSpamDamage Timeout
				antiSpamDamage[sid] = systime + antiSpamTimeout
				
				isPropProtected = ( this == self.player or E2Lib.isOwner(self, this) or E2Lib.isFriend( this:IsPlayer() and ent or this.player, self.player) )
			end
		end
		
		-- If Player is Admin or passed on AntiSpam and Prop Protection
		if ( isAdmin or ( isNotSpam and isPropProtected ) ) then
			this:TakeDamage( damageAmount, self.player, self )
		end
	end
	
	--[[-------------------------------------------------
		Function: set
	---------------------------------------------------]]
	
	__e2setcost(15)
	
	e2function void entity:set(string input, string param)
		if ( not IsValid( this ) ) then return end
		
		if ( isSinglePlayer or self.player:IsAdmin() ) then
			this:Fire( input, param )
		end
	end
	
	e2function void entity:set(string input, number param)
		if ( not IsValid( this ) ) then return end
		
		if ( isSinglePlayer or self.player:IsAdmin() ) then
			this:Fire( input, param )
		end
	end
	
	--[[-------------------------------------------------
		Function: tableToJson
	---------------------------------------------------]]
	
	__e2setcost(20)
	
	e2function string tableToJson(table tbl)
		return istable( tbl ) and util.TableToJSON( tbl ) or ""
	end
	
	e2function table jsonToTable(string str)
		return str:len() > 0 and util.JSONToTable( str ) or nil
	end
	
	
	--[[-------------------------------------------------
		Function: animate
	---------------------------------------------------]]
	
	__e2setcost(50)
	
	e2function void entity:animate(number anim)
		if ( not canAnimate( self, this ) ) then return end
		doAnimation( this, anim )
	end
	
	__e2setcost(55)
	
	e2function void entity:animate(string anim)
		if ( not canAnimate( self, this ) ) then return end
		doAnimation( this, anim )
	end
	
	__e2setcost(60)
	
	e2function void entity:animate(number anim, number speed)
		if ( not canAnimate( self, this ) ) then return end
		doAnimation( this, anim )
		this:SetPlaybackRate( math.max( speed, 0 ) )
	end
	
	__e2setcost(60)
	
	e2function void entity:animate(string anim, number speed)
		if ( not canAnimate( self, this ) ) then return end
		doAnimation( this, anim )
		this:SetPlaybackRate( math.max( speed, 0 ) )
	end
	
	__e2setcost(5)
	
	e2function number entity:getAnimation()
		return IsValid( this ) and this:GetSequence() or 0
	end
	
	__e2setcost(10)
	
	e2function number entity:getAnimationByName(string anim)
		anim = anim:Trim()
		return IsValid( this ) and anim ~= "" and this:LookupSequence( anim ) or 0
	end
	
	--[[-------------------------------------------------
		Function: disableFallDamage
	---------------------------------------------------]]
	
	__e2setcost(50)
	
	e2function number entity:disableFallDamage()
		if ( not IsValid( this ) or not this:IsPlayer() ) then return end
		local sid = this:SteamID64()
		if ( not fallDamageList[sid] )     then return end
		if ( not isAllowed( self, this ) ) then return end
		
		fallDamageList[sid] = false
	end
	
	--[[-------------------------------------------------
		Function: enableFallDamage
	---------------------------------------------------]]
	
	__e2setcost(50)
	
	e2function number entity:enableFallDamage()
		if ( not IsValid( this ) or not this:IsPlayer() ) then return end
		local sid = this:SteamID64()
		if ( fallDamageList[sid] )         then return end
		if ( not isAllowed( self, this ) ) then return end
		
		fallDamageList[this:SteamID64()] = true
	end
	
	--[[-------------------------------------------------
		Function: egpHUDSetPlayer
	---------------------------------------------------]]
	
	__e2setcost(50)
	
	e2function void entity:egpHUDSetPlayer(entity ply)
		if ( not IsValid( this ) or this:IsPlayer() ) then return end
		
		if ( isAllowed( self, this ) ) then
			ent = ent:IsPlayer() and ent or ent.player
			if ( IsValid( ent ) ) then
				umsg.Start( "EGP_HUD_Use", IsValid( ent ) and ent or nil )
					umsg.Entity( ent )
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