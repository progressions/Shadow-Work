# Spec Requirements Document

> Spec: Grid-Based Lighting System
> Created: 2025-10-03
> Status: Planning

## Overview

Implement a grid-based lighting and darkness system for Shadow Work that uses 16x16 pixel cells to calculate light intensity with stepped falloff levels. The system will allow configurable per-room darkness levels (defaulting to fully lit), support player-held torches and world-placed light sources, and use maximum light intensity (non-additive) when multiple lights overlap.

## User Stories

### Exploring Dark Dungeons

As a player, I want to carry a torch to see in dark rooms, so that I can navigate dangerous dungeons and discover hidden areas.

The player equips a torch in their left hand from the inventory. When entering a dark dungeon room, the torch automatically illuminates a radius around the player in a grid-based pattern with stepped brightness levels (bright cells near the player, dimmer cells farther away). As the player moves, the lit area follows them, revealing enemies, items, and environmental hazards within the torch's radius.

### Configuring Atmospheric Lighting

As a level designer, I want to set different darkness levels for each room, so that I can create varied atmospheric experiences from bright outdoor areas to pitch-black dungeons.

Each room has a configurable darkness value from 0 (fully lit, no darkness overlay) to 1 (pitch black without light sources). Surface rooms default to 0 (no darkness), while dungeon rooms can be set to 0.8 or higher to create tense exploration moments. The system applies the darkness as a surface overlay that lights "punch through" using subtractive blending.

### Discovering Static Light Sources

As a player, I want to encounter torches and lamps in the world, so that I can use them as navigation landmarks and safe zones in dark areas.

Wall-mounted torches and standing lamps are placed in dungeon rooms. These static light sources emit light in the same grid-based pattern as player torches, with their own configurable radius. When multiple light sources overlap, the system uses the maximum brightness value for each grid cell rather than combining/adding intensities, preventing overly bright areas.

### Managing Torch Duration

As a player, I want torches to burn out after a duration, so that exploration feels tense and I need to manage my torch supply.

Each equipped torch has a duration timer that counts down while the torch is active. When the torch burns out, it disappears from the player's equipment slot. If the player has torches in inventory, a new one is automatically equipped to the left hand, maintaining the light source. If no torches remain in inventory, the light goes out. This creates strategic resource management during dungeon exploration.

### Delegating Light to Companions

As a player, I want to give my torch to a companion by pressing L, so that I can free up my left hand for a shield while still having light.

When the player presses L while holding a torch, the torch transfers from the player's left hand to the first companion in the party list. The companion becomes the light source with the same torch duration continuing to count down. When the companion's torch burns out, she automatically takes another torch from the player's inventory if available, maintaining the party's light source without player intervention.

## Spec Scope

1. **Grid-Based Light Map** - Divide each room into 16x16 pixel cells and track light intensity per cell using a ds_grid data structure.
2. **Stepped Light Falloff** - Calculate light in discrete brightness levels (e.g., 100%, 75%, 50%, 25%, 0%) based on distance from light source rather than smooth gradients.
3. **Room Darkness Configuration** - Add per-room darkness level variable (0-1 alpha) with default of 0 (fully lit), configurable via room creation code.
4. **Player-Held Torch Detection** - Integrate with existing item system to detect equipped torch and use its light_radius property to emit light at player position.
5. **World Light Source Objects** - Create obj_light_source parent object for placing torches/lamps in rooms with configurable radius property.
6. **Non-Additive Light Blending** - Use maximum light value when multiple sources overlap rather than combining intensities.
7. **Surface-Based Rendering** - Implement lighting using GameMaker surfaces with subtractive blend mode for performance.
8. **Torch Duration System** - Add torch_duration and torch_time_remaining properties to track torch burn time, removing torch when duration expires.
9. **Player Automatic Torch Replacement** - When player's torch burns out, automatically equip next torch from inventory if available.
10. **Companion Torch Carrying** - Add L key input to transfer player's torch to first companion, setting companion.carrying_torch flag and continuing torch duration.
11. **Companion Light Emission** - Detect companion.carrying_torch flag and emit light from companion position instead of player.
12. **Companion Automatic Torch Replacement** - When companion's torch burns out, automatically equip next torch from player's inventory if available.
13. **Torch Item Stack & Metadata** - Treat torches as stackable consumables and store their burn duration in item metadata so duration logic can consume the next torch without special casing.
14. **Inventory Torch Helpers** - Provide item-id-based helpers for checking and consuming torches, enabling burnout replacement without relying on inventory index assumptions.
15. **Companion Torch State Support** - Extend the active companion data model (flags, timers, emitters) so torch handoff works with existing `get_active_companions()` patterns instead of introducing new global lists.
16. **Pause-Safe Lighting** - Ensure the lighting controller respects `global.game_paused`, halting grid/surface updates when gameplay is paused.
17. **Surface Lifetime Handling** - Recreate lost surfaces and dispose surfaces/ds_grids in Clean Up to prevent leaks or crashes after context loss.
18. **Torch Sound Effects** - Play sound effect when equipping torch, when torch burns out, and loop torch burning sound while active.
19. **Companion Torch Transfer Sound** - Play specific sound effect when companion receives torch via L key or dialogue option.
20. **VN Dialogue Torch Request** - Add "Carry the torch for me" dialogue option in companion VN interface that sets carrying_torch flag and plays transfer sound.
21. **Save/Load Serialization** - Serialize and deserialize torch state (torch_active, torch_time_remaining), companion torch state (carrying_torch, torch_time_remaining), and torch inventory counts when saving/loading game.

## Out of Scope

- Smooth gradient lighting (using stepped/discrete levels only)
- Dynamic shadows cast by walls/objects
- Colored lighting (using white light only)
- Light flickering animations (can be added later)
- Line-of-sight occlusion by walls (grid cells don't check for wall blocking)
- Player-carried lanterns with different light patterns (torch only for now)

## Expected Deliverable

1. A lighting controller object (obj_lighting_controller) that renders darkness overlay and light sources correctly in test rooms.
2. Player character emits grid-based light when torch is equipped in left hand, with stepped brightness levels visible.
3. At least two test rooms: one with darkness level 0 (fully lit, no overlay) and one with darkness level 0.8 showing torch lighting.
4. Placeable world torch object (obj_torch_wall or obj_lamp_standing) that emits light with configurable radius.
5. Multiple overlapping lights correctly show maximum brightness (not additive) in overlapping grid cells.
6. Torch burns out after its duration expires and automatically equips a new torch from inventory if available.
7. When player has no torches in inventory, torch burns out and light goes dark.
8. Pressing L successfully transfers player's torch to first companion, who becomes the light source.
9. When companion's torch burns out, she automatically equips another torch from player's inventory if available.
10. Torch equip, burnout, and burning loop sound effects play at appropriate times.
11. Companion VN dialogue includes "Carry the torch for me" option that transfers torch with sound effect.
12. Save and load game preserves torch state (active, timer) for both player and companions.

## Spec Documentation

- Tasks: @.agent-os/specs/2025-10-03-grid-based-lighting/tasks.md
- Technical Specification: @.agent-os/specs/2025-10-03-grid-based-lighting/sub-specs/technical-spec.md
