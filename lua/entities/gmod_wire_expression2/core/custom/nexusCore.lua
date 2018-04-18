--[[-------------------------------------------------
    Developed by Nexus [BR]

    @license: Attribution-NonCommercial 4.0 International - <https://creativecommons.org/licenses/by-nc/4.0/legalcode>
    @user Steam Profile: http://steamcommunity.com/profiles/76561197983103320

    Created: 05-11-2012
    Updated: 30-07-2016    08:03 PM
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
    
    --[[-------------------------------------------------------------------------
                                 LOCAL VARIABLES
    ---------------------------------------------------------------------------]]
    
    nexuscore = nexuscore or {}
    
    local isSinglePlayer   = game.SinglePlayer()
    local antiSpamTimeout  = 2 -- seconds
    
    local FUNCTION_DISABLED = 0
    local FUNCTION_ADMIN    = 1
    local FUNCTION_EVERYONE = 2
    local FUNCTION_CUSTOM   = 3
    
    local cvarfuncs = nexuscore.cvarfuncs or {
        [FUNCTION_DISABLED] = function( ply, ent, val, hookname ) return false end,
        [FUNCTION_ADMIN]    = function( ply, ent, val, hookname ) return isSinglePlayer or ply:IsAdmin() end,
        [FUNCTION_EVERYONE] = function( ply, ent, val, hookname ) return true end,
        [FUNCTION_CUSTOM]   = function( ply, ent, val, hookname ) return hook.Run( hookname, ply, ent, val ) end
    }
    
    local falldamage = nexuscore.falldamage or {}
    
    local antispam = nexuscore.antispam or {
        damage     = {},
        health     = {},
        teleport   = {},
        egp_player = {},
        egp_self   = {}
    }
    
    local fallDamageCVar = GetConVar( "mp_falldamage" )
    local setHealthCVar  = CreateConVar( "nexuscore_set_health",  FUNCTION_ADMIN, {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Controls the entity:setHealth() e2 function -- 0: disabled, 1: admin only, 2: everyone, 3: uses NexusCoreSetHealth hook for custom checking" )
    local takeDamageCVar = CreateConVar( "nexuscore_take_damage", FUNCTION_ADMIN, {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Controls the entity:takeDamage() e2 function -- 0: disabled, 1: admin only, 2: everyone, 3: uses NexusCoreTakeDamage hook for custom checking" )
    local teleportCVar   = CreateConVar( "nexuscore_teleport",    FUNCTION_ADMIN, {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_SERVER_CAN_EXECUTE}, "Controls the entity:teleport() e2 function -- 0: disabled, 1: admin only, 2: everyone, 3: uses NexusCoreTeleport hook for custom checking" )
    
    local MAX_IGNITE_VALUE = 99999999
    local SOURCE_FALL_DAMAGE_MULTIPLIER = 0.225
    local DEFAULT_FALL_DAMAGE = 10
    local NO_FALL_DAMAGE = 0
    
    nexuscore.falldamage = falldamage
    nexuscore.antispam   = antispam
    nexuscore.cvarfuncs  = cvarfuncs
    
    nexuscore.FUNCTION_DISABLED = FUNCTION_DISABLED
    nexuscore.FUNCTION_ADMIN    = FUNCTION_ADMIN
    nexuscore.FUNCTION_EVERYONE = FUNCTION_EVERYONE
    nexuscore.FUNCTION_CUSTOM   = FUNCTION_CUSTOM
    
    --[[-------------------------------------------------------------------------
                                 UTILITY FUNCTIONS
    ---------------------------------------------------------------------------]]
    
    local function isAllowedByWire( e2, ent )
        return ent == e2.player
            or E2Lib.isOwner( e2, ent )
            or E2Lib.isFriend( ent:IsPlayer() and ent or ent.player, e2.player )
    end
    
    local function isAllowed( e2, ent )
        return isSinglePlayer
            or e2.player:IsAdmin()
            or isAllowedByWire( e2, ent )
    end
    
    local function isAllowedNonPlayer( e2, ent )
        return ( IsValid( ent ) and not ent:IsPlayer() )
            and (
                isSinglePlayer
                or e2.player:IsAdmin()
                or ent == e2.player
                or E2Lib.isOwner( e2, ent )
            )
    end
    
    --[[-------------------------------------------------------------------------
                             NEXUS CORE E2 FUNCTIONS
    ---------------------------------------------------------------------------]]
    
    E2Lib.RegisterExtension( "nexuscore", true )
        
    --[[-------------------------------------------------
        Function: playerUniqueID
    ---------------------------------------------------]]
    
    --[[ There really should be no need to ever use PLAYER:UniqueID(), stick to SteamID/SteamID64/AccountID
    __e2setcost(5)
    
    e2function number entity:playerUniqueId()
        return IsValid( this ) and this:IsPlayer() and this:UniqueID() or 0
    end
    ]]
    
    --[[-------------------------------------------------
        Function: teleport
        Sets the player's position to the given vector.
    ---------------------------------------------------]]
    
    __e2setcost(75)
    
    e2function void entity:teleport(vector pos)
        if ( not IsValid( this ) or not this:IsPlayer() ) then return end
        
        local func = cvarfuncs[teleportCVar:GetInt()] or cvarfuncs[FUNCTION_DISABLED]
        if ( not func( self.player, this, amount, "NexusCoreTeleport" ) ) then return end
        
        --[[local curtime = SysTime()
        if ( antispam["teleport"][e2.player] and curtime == antispam["teleport"][e2.player] ) then return end
        antispam["teleport"][e2.player] = curtime]]
        
        if ( not isAllowedByWire( self, this ) ) then return end
        
        if ( this:InVehicle() ) then
            this:ExitVehicle()
        end 
        
        this:SetPos( Vector( pos[1], pos[2], pos[3] ) )
    end
    
    --[[-------------------------------------------------
        Function: setHealth
        Sets the player's health to the given number.
    ---------------------------------------------------]]
    
    __e2setcost(75)
    
    e2function void entity:setHealth(number amount)
        if ( not IsValid( this ) or not this:IsPlayer() ) then return end
        
        local func = cvarfuncs[setHealthCVar:GetInt()] or cvarfuncs[FUNCTION_DISABLED]
        if ( not func( self.player, this, amount, "NexusCoreSetHealth" ) ) then return end
        
        --[[local curtime = CurTime()
        if ( antispam["health"][e2.player] and curtime == antispam["health"][e2.player] ) then return end
        antispam["health"][e2.player] = curtime]]
        
        if ( not isAllowedByWire( self, this ) ) then return end
        
        this:SetHealth( amount )
    end
    
    --[[-------------------------------------------------
        Function: takeDamage
        Applies the given damage to the entity.
    ---------------------------------------------------]]
    
    __e2setcost(75)
    
    e2function void entity:takeDamage(number amount)
        if ( not IsValid( this ) or this:IsPlayer() ) then return end
        
        local func = cvarfuncs[takeDamageCVar:GetInt()] or cvarfuncs[FUNCTION_DISABLED]
        if ( not func( self.player, this, amount, "NexusCoreTakeDamage" ) ) then return end
        
        --[[local curtime = CurTime()
        if ( antispam["damage"][e2.player] and curtime == antispam["damage"][e2.player] ) then return end
        antispam["damage"][e2.player] = curtime + antiSpamTimeout]]
        
        if ( not isAllowedByWire( self, this ) ) then return end
        
        this:TakeDamage( amount, self.player, self )
    end
    
    --[[-------------------------------------------------
        Function: ApplyPlayerForce
        Applies force on the player toward the given vector.
    ---------------------------------------------------]]
    
    __e2setcost(20)
    
    e2function void entity:applyPlayerForce(vector pos)
        if ( not IsValid( this ) or not this:IsPlayer() or not isAllowed( self, this ) ) then return end
    
        if ( this:InVehicle() ) then
            this:ExitVehicle()
        end
        
        this:SetVelocity( Vector( pos[1], pos[2], pos[3] ) )
    end
    
    --[[-------------------------------------------------
        Function: hasNoCollideAll
        Returns whether the entity currently has nocollide-all applied.
    ---------------------------------------------------]]
    
    __e2setcost(5)
    
    e2function number entity:hasNoCollideAll()
        return IsValid( this ) and this:GetCollisionGroup() == COLLISION_GROUP_WORLD
    end
    
    --[[-------------------------------------------------
        Function: getCollisionGroup
        Gets the entity's current collision group enumeration.
        http://wiki.garrysmod.com/page/Enums/COLLISION_GROUP
    ---------------------------------------------------]]
    
    e2function number entity:getCollisionGroup()
        return IsValid( this ) and this:GetCollisionGroup() or nil
    end
    
    --[[-------------------------------------------------
        Function: setNoCollideAll
        Enables or disables nocollide-all on the given entity.
    ---------------------------------------------------]]
    
    __e2setcost(50)
    
    e2function void entity:setNoCollideAll(number enable)
        if ( not IsValid( this ) or this:IsPlayer() or not isAllowed( self, this ) ) then return end
        
        enable = tobool( enable )
        local group = this:GetCollisionGroup()
        
        if ( enable ) then
            if ( group == COLLISION_GROUP_WORLD ) then return end -- don't set the collision group if it hasn't changed
        else
            if ( group ~= COLLISION_GROUP_WORLD ) then return end -- don't remove the collision group if it's not nocollide-all'd
        end
                
        this:SetCollisionGroup( enable and COLLISION_GROUP_WORLD or COLLISION_GROUP_NONE )
    end
    
    --[[-------------------------------------------------
        Function: setOwner
    ---------------------------------------------------]]
    
    __e2setcost(200)
    
    e2function void entity:setOwner(entity ply)
        if ( not IsValid( this ) or this:IsPlayer() or not ply:IsPlayer() ) then return end
        if ( isSinglePlayer or not self.player:IsAdmin() ) then return end
        
        this:SetPlayer( ply )
    end
    
    --[[-------------------------------------------------
        Function: ignite
        Sets the entity on fire with an optional time in seconds and a radius.
    ---------------------------------------------------]]
    
    __e2setcost(50)
    
    e2function void entity:ignite()
        if ( not IsValid( this ) or not isAllowed( self, this ) ) then return end
        this:Ignite( MAX_IGNITE_VALUE, 0 )
    end
    
    e2function void entity:ignite(number seconds)
        if ( not IsValid( this ) or not isAllowed( self, this ) ) then return end
        this:Ignite( math.Clamp( seconds, 0, MAX_IGNITE_VALUE ), 0 )
    end
    
    e2function void entity:ignite(number seconds, number radius)
        if ( not IsValid( this ) or not isAllowed( self, this ) ) then return end
        this:Ignite( math.Clamp( seconds, 0, MAX_IGNITE_VALUE ), math.Clamp( radius, 0, MAX_IGNITE_VALUE ) )
    end
    
    --[[-------------------------------------------------
        Function: extinguish
        Extinguishes the entity if it is on fire.
    ---------------------------------------------------]]
    
    __e2setcost(15)
    
    e2function void entity:extinguish()
        if ( not IsValid( this ) or not this:IsOnFire() or not isAllowed( self, this ) ) then return end
        this:Extinguish()
    end
    
    --[[-------------------------------------------------
        Function: set
        Fires an entity's input. http://wiki.garrysmod.com/page/Entity/Fire
    ---------------------------------------------------]]
    
    __e2setcost(15)
    
    e2function void entity:set(string key, string value)
        if ( not IsValid( this ) ) then return end
        if ( not isSinglePlayer and not self.player:IsAdmin() ) then return end
        
        this:Fire( key, value )
    end
    
    e2function void entity:set(string key, number value)
        if ( not IsValid( this ) ) then return end
        if ( not isSinglePlayer and not self.player:IsAdmin() ) then return end
        
        this:Fire( key, value )
    end
    
    --[[-------------------------------------------------
        Function: tableToJson
    ---------------------------------------------------]]
    
    --[[ These functions aren't needed because Wire includes jsonEncode/jsonDecode natively
    
    __e2setcost(20)
    
    e2function string tableToJson(table tbl)
        return istable( tbl ) and util.TableToJSON( tbl ) or ""
    end
    
    e2function table jsonToTable(string str)
        return str:len() > 0 and util.JSONToTable( str ) or nil
    end
    ]]
    
    --[[-------------------------------------------------
        Function: animate
        Resets the entity's current animation sequence with the passed numeric sequence or animation name.
        Aliases allow passing the playback rate (speed) and the animation cycle (see further below).
    ---------------------------------------------------]]
    
    local function getEntityToAnimate( ent )
        return ent:GetClass() == "prop_effect" and IsValid( ent.AttachedEntity ) and ent.AttachedEntity or ent
    end
    
    
    local function doAnimation( ent, anim )
        if ( not IsValid( ent ) ) then return end
        
        ent = getEntityToAnimate( ent )
        
        -- Copied from wire hologram's animation code
        if ( not ent.Animated ) then
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
    end
    
    __e2setcost(50)
    
    e2function void entity:animate(number anim)
        if ( not isAllowedNonPlayer( self, this ) ) then return end
        doAnimation( this, anim )
        getEntityToAnimate( this ):SetPlaybackRate( 1 )
    end
    
    e2function void entity:animate(string anim)
        if ( not isAllowedNonPlayer( self, this ) ) then return end
        doAnimation( this, anim )
        getEntityToAnimate( this ):SetPlaybackRate( 1 )
    end
    
    __e2setcost(60)
    
    e2function void entity:animate(number anim, number speed)
        if ( not isAllowedNonPlayer( self, this ) ) then return end
        doAnimation( this, anim )
        getEntityToAnimate( this ):SetPlaybackRate( math.max( speed, 0 ) )
    end
    
    e2function void entity:animate(string anim, number speed)
        if ( not isAllowedNonPlayer( self, this ) ) then return end
        doAnimation( this, anim )
        getEntityToAnimate( this ):SetPlaybackRate( math.max( speed, 0 ) )
    end
    
    __e2setcost(70)
    
    e2function void entity:animate(number anim, number speed, number cycle)
        if ( not isAllowedNonPlayer( self, this ) ) then return end
        local ent = getEntityToAnimate( this )
        ent:SetPlaybackRate( math.max( speed, 0 ) )
        ent:SetCycle( math.Clamp( cycle, 0, 1 ) )
    end
    
    e2function void entity:animate(string anim, number speed, number cycle)
        if ( not isAllowedNonPlayer( self, this ) ) then return end
        doAnimation( this, anim )
        local ent = getEntityToAnimate( this )
        ent:SetPlaybackRate( math.max( speed, 0 ) )
        ent:SetCycle( math.Clamp( cycle, 0, 1 ) )
    end
    
    --[[-------------------------------------------------
        Function: setPlaybackRate
        Sets the entity's current animation sequence playback rate, i.e. how slow/fast the animation should progress.
    ---------------------------------------------------]]
    
    __e2setcost(25)
    
    e2function void entity:setPlaybackRate(number speed)
        return isAllowedNonPlayer( self, this ) and getEntityToAnimate( this ):SetPlaybackRate( math.max( speed, 0 ) )
    end
    
    --[[-------------------------------------------------
        Function: setCycle
        Sets the entity's current animation sequence cycle, i.e. how far into the animation to start.
        Values should be decimal numbers between 0 and 1, where 0.5 would mean halfway through the sequence.
    ---------------------------------------------------]]
    
    e2function void entity:setCycle(number cycle)
        return isAllowedNonPlayer( self, this ) and getEntityToAnimate( this ):SetCycle( math.Clamp( cycle, 0, 1 ) )
    end
    
    --[[-------------------------------------------------
        Function: lookupSequence
        Gets the entity's numeric animation sequence from the animation name (e.g. "idle_all_01" = 2)
    ---------------------------------------------------]]
    
    __e2setcost(50)
    
    e2function number entity:lookupSequence(string anim)
        anim = anim:Trim()
        return IsValid( this ) and anim ~= "" and getEntityToAnimate( this ):LookupSequence( anim ) or 0
    end
    
    e2function number entity:getAnimationByName(string anim)
        anim = anim:Trim()
        return IsValid( this ) and anim ~= "" and getEntityToAnimate( this ):LookupSequence( anim ) or 0
    end
    
    --[[-------------------------------------------------
        Function: getSequence
        Gets the entity's current numeric animation sequence.
    ---------------------------------------------------]]
    
    __e2setcost(15)
    
    e2function number entity:getSequence()
        return IsValid( this ) and getEntityToAnimate( this ):GetSequence() or 0
    end
    
    e2function number entity:getAnimation()
        return IsValid( this ) and getEntityToAnimate( this ):GetSequence() or 0
    end
    
    --[[-------------------------------------------------
        Function: getSequenceList
        Gets the list of animation sequences available on the entity.
    ---------------------------------------------------]]
    
    e2function array entity:getSequenceList()
        return IsValid( this ) and getEntityToAnimate( this ):GetSequenceList()
    end
    
    
    --[[-------------------------------------------------
        Function: sequenceDuration
        Gets the duration of the entity's current sequence, or the duration of the passed sequence.
    ---------------------------------------------------]]
    
    e2function number entity:sequenceDuration()
        return IsValid( this ) and getEntityToAnimate( this ):SequenceDuration()
    end
    
    e2function number entity:sequenceDuration(number sequence)
        return IsValid( this ) and getEntityToAnimate( this ):SequenceDuration( sequence )
    end
    
    --[[-------------------------------------------------
        Function: enableFallDamage
        Sets whether the player should be affected by fall damage or not.
        If the mp_falldamage convar is enabled, the damage is scaled based on the player's speed.
        Otherwise, a default of 10 damage is applied.
        
        Possible parameters are:
            -1: clear (leave fall damage up to server)
             0: prevent fall damage
             1: enable fall damage
    ---------------------------------------------------]]
    
    local function getFallDamage( ply, speed )
        local sid = ply:SteamID64()
        
        if ( falldamage[sid] ) then -- apply fall damage if explicitly enabled
            return fallDamageCVar:GetBool() and speed * SOURCE_FALL_DAMAGE_MULTIPLIER or DEFAULT_FALL_DAMAGE
        elseif ( falldamage[sid] == false ) then -- prevent fall damage if explicitly disabled
            return NO_FALL_DAMAGE
        end
    end
    hook.Add( "GetFallDamage", "nexuscore.getfalldamage", getFallDamage )
    
    __e2setcost(50)
    
    e2function number entity:enableFallDamage(number enable)
        if ( not IsValid( this ) or not this:IsPlayer() ) then return end
        
        enable = math.Clamp( math.floor( enable ), -1, 1 )
        if ( enable == -1 ) then
            enable = nil -- clear the player from the fall damage list
        else
            enable = tobool( enable )
        end
        
        if ( enable and falldamage[this:SteamID64()] ) then return end -- skip if enabling but already enabled
        if ( not isAllowed( self, this ) )    then return end
        
        falldamage[this:SteamID64()] = enable
    end
    
    --[[-------------------------------------------------
        Function: egpHudTogglePlayer
        Sets whether the given player can see the Wire EGP HUD or not.
    ---------------------------------------------------]]
    
    local function egpHud( func, e2, egp, ply, enable )
        if ( ply ~= nil ) then
            if ( IsValid( ply ) and not ply:IsPlayer() ) then return end
            
            --[[local curtime = CurTime()
            if ( antispam[func][e2.player] and antispam[func][e2.player] == curtime ) then return end
            antispam[func][e2.player] = curtime]]
            local canUse = hook.Run( "PlayerUse", e2.player, ply )
            
            if ( not isAllowedByWire( e2, ply ) and not canUse ) then return end
        end
        
        if ( not EGP:IsAllowed( e2, egp ) ) then return end
        
        umsg.Start( "EGP_HUD_Use", ply or e2.player )
            umsg.Entity( egp )
            if ( enable ~= nil ) then umsg.Char( math.Clamp( math.floor( enable ), -1, 1 ) ) end -- we can either send 0 or just not send the char 
        umsg.End()
    end
    
    __e2setcost(50)
    
    e2function void wirelink:egpHudTogglePlayer(entity ply, number enable)
        egpHud( "egp_player", self, this, ply, enable )
    end
    
    --[[-------------------------------------------------
        Function: egpHudToggle
        Toggles the visibility of the player's Wire EGP HUD on themselves.
    ---------------------------------------------------]]
    
    e2function void wirelink:egpHudToggle(number enable)
        egpHud( "egp_self", self, this, nil, enable )
    end
    
    -- Clear E2 cost for external functions
    __e2setcost(nil)
end