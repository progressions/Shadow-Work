# Shield Block System - Lite Summary

Implement a defensive shield blocking mechanic allowing players to hold a key to raise an equipped shield and mitigate incoming damage. Normal blocks reduce damage to chip values while hazards still spawn; perfect block timing (tight window) destroys projectiles entirely without hazard spawn. Shield properties like arc width and cooldown vary by shield size, and player movement is locked to shield facing direction like ranged focus.

## Key Points
- Hold block key with shield equipped to enter shielding state with locked facing direction
- Perfect block window (tight timing) destroys projectiles without hazard spawn and shorter cooldown
- Normal blocks reduce damage to chip values but hazards still spawn
- Shield properties (arc width, cooldown) configurable per shield size/tier
