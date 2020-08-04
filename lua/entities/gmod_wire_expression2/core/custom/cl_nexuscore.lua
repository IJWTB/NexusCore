-- Player functions
E2Helper.Descriptions["applyPlayerForce"]   = "Applies force on the player toward the given vector. Requires prop protection or admin to use on other players."
E2Helper.Descriptions["enableFallDamage"]   = "Sets whether the player should be affected by fall damage or not. Requires prop protection or admin to use on other players."
E2Helper.Descriptions["teleport"]           = "Sets the player's position to the given vector. Requires prop protection to use on other players."

-- Entity functions
E2Helper.Descriptions["extinguish"]         = "Extinguishes the entity if it is on fire. Requires prop protection or admin to use on others' entities. Rate limited to 0.5 seconds."
E2Helper.Descriptions["ignite"]             = "Sets the entity on fire with an optional time in seconds and a radius. Requires prop protection or admin to use on others' entities. Rate limited to 0.5 seconds."
E2Helper.Descriptions["hasNoCollideAll"]    = "Returns whether the entity currently has nocollide-all applied."
E2Helper.Descriptions["setNoCollideAll"]    = "Enables or disables nocollide-all on the given entity. Requires prop protection or admin to use on other players."
E2Helper.Descriptions["set"]                = "Fires an entity's input. Requires admin or singleplayer to use."
E2Helper.Descriptions["setHealth"]          = "Sets the entity's health to the given number. Requires prop protection to use on others' entities."
E2Helper.Descriptions["setOwner"]           = "Changes the entity's owner to the given player. Requires admin or singleplayer to use."
E2Helper.Descriptions["takeDamage"]         = "Applies the given damage to the entity. Requires prop protection to use on others' entities."

-- Animation functions
E2Helper.Descriptions["animate"]            = "Resets the entity's current animation sequence with the passed numeric sequence or animation name. Requires prop protection or admin to use on others' entities."
E2Helper.Descriptions["getSequence"]        = "Gets the entity's current numeric animation sequence."
E2Helper.Descriptions["getAnimation"]       = "Gets the entity's current numeric animation sequence (alias of getSequence)."
E2Helper.Descriptions["lookupSequence"]     = "Gets the entity's numeric animation sequence from the animation name."
E2Helper.Descriptions["getAnimationByName"] = "Gets the entity's numeric animation sequence from the animation name (alias of lookupSequence)."
E2Helper.Descriptions["getSequenceList"]    = "Gets the list of animation sequences available on the entity."
E2Helper.Descriptions["sequenceDuration"]   = "Gets the duration of the entity's current sequence, or the duration of the passed sequence."
E2Helper.Descriptions["setCycle"]           = "Sets the entity's current animation sequence cycle, i.e. how far into the animation to start. Value between 0 to 1."
E2Helper.Descriptions["setPlaybackRate"]    = "Sets the entity's current animation sequence playback rate, i.e. how slow/fast the animation should progress."

-- EGP functions
E2Helper.Descriptions["egpHudTogglePlayer"] = "Sets whether the given player can see the Wire EGP HUD or not. Requires prop protection and PlayerUse to use on other players."
E2Helper.Descriptions["egpHudToggle"]       = "Toggles the visibility of the player's Wire EGP HUD on themselves."
