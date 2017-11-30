Nexus Core
=====

Nexus Core is library of Expression 2 functions.

```lua
player:teleport(vector)
player:setHealth(number)
player:applyPlayerForce(vector)
player:enableFallDamage(0/1)

entity:takeDamage(number)
entity:hasNoCollideAll()
entity:getCollisionGroup()
entity:setNoCollideAll(0/1)
entity:setOwner(player)
entity:extinguish()

entity:set(string, string)
entity:set(string, number)

entity:ignite()
entity:ignite(number)
entity:ignite(number, number)

entity:animate(string)
entity:animate(string, number)
entity:animate(string, number, number)

entity:animate(number)
entity:animate(number, number)
entity:animate(number, number, number)

entity:setPlaybackRate(number)
entity:setCycle(number)
entity:lookupSequence(string) alias of entity:getAnimationByName(string)
entity:getSequence() alias of entity:getAnimation()
entity:getSequenceList()

entity:sequenceDuration()
entity:sequenceDuration(number)

wirelink:egpHudTogglePlayer(player, 0/1)
wirelink:egpHudToggle(0/1)
```
