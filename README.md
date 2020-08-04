[E2] NexusCore
=====

NexusCore is library of Expression 2 functions. The original library was written by the ZionDevelopers team, and has been significantly cleaned up and modified to provide hook calls for controlling player health, teleporting, and damaging.

```lua
--  Player functions
player:teleport(vector)
player:applyPlayerForce(vector)
player:enableFallDamage(0/1)

-- Entity functions
entity:hasNoCollideAll()
entity:getCollisionGroup()
entity:setNoCollideAll(0/1)
entity:setHealth(number)
entity:setOwner(player)
entity:takeDamage(number)

entity:ignite()
entity:ignite(number)
entity:ignite(number, number)
entity:extinguish()

entity:set(string, string)
entity:set(string, number)

-- Animation functions
entity:animate(string)
entity:animate(string, number)
entity:animate(string, number, number)

entity:animate(number)
entity:animate(number, number)
entity:animate(number, number, number)

entity:setPlaybackRate(number)
entity:setCycle(number)
entity:lookupSequence(string)
entity:getAnimationByName(string) -- alias of lookupSequence
entity:getSequence()
entity:getAnimation()             -- alias of getSequence
entity:getSequenceList()

entity:sequenceDuration()
entity:sequenceDuration(number)

-- EGP functions
wirelink:egpHudTogglePlayer(player, 0/1)
wirelink:egpHudToggle(0/1)
```

Significant changes (as per license requirements):
- The code has largely been cleaned up and reorganized to reduce repetitive code (antispam, prop protection calls)
- The function `entity:playerUniqueId()` is disabled to prevent its usage (it is poorly implemented and has key collisions, leading to potential security issues)
- The functions `tableToJson()` and `jsonToTable()` have been removed since there are official E2 functions now
- Added ability to allow external code to determine whether `setHealth/takeDamage/teleport` are allowed or not
