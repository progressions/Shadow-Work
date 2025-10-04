# Grid-Based Lighting - Lite Summary

Implement a grid-based lighting and darkness system using 16x16 pixel cells with stepped falloff levels. Rooms have configurable darkness (0-1, default 0). Player-held torches and world light sources emit light using maximum intensity (non-additive). Torches have duration and burn out. Players can press L to give torch to first companion, who becomes the light source and auto-equips new torches from player inventory when hers burns out.

## Key Points
- 16x16 pixel grid cells with stepped light falloff levels
- Room darkness configurable (0-1 scale, default 0 = full brightness)
- Non-additive lighting: maximum intensity from overlapping sources wins
- Torches are stackable consumables with defined burn duration, burn out over time, and can be transferred to companions
- Inventory helpers operate by item id so torches auto-replace cleanly on burnout
- Companion auto-equips new torches from player inventory when current torch expires and lighting pauses with the rest of gameplay
