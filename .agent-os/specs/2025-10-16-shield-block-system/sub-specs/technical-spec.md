# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-10-16-shield-block-system/spec.md

> Created: 2025-10-16
> Version: 1.0.0

## Technical Requirements

### Player State Machine
- Add `PlayerState.shielding` to the enum
- When block key pressed + shield equipped: transition to shielding state
- Shielding state locks facing_dir (similar to ranged focus behavior)
- Movement restricted to current facing direction (use current ranged focus logic as template)
- Release block key or press attack key to exit shielding state

### Animation System
- Player sprite needs new shield raise/hold animation frames for each direction (down, right, left, up)
- `image_speed = 0` during shield hold (manual frame control)
- Animation plays on entry to shielding state, holds final frame
- Perfect block window triggers a sprite flash effect on final frame

### Block Detection & Damage Calculation
- Collision detection between obj_player (during shielding) and incoming projectiles (obj_enemy_arrow, obj_hazard_projectile)
- On collision: check if in perfect block window
  - **Perfect block**: destroy projectile, destroy target indicator if exists, prevent hazard spawn, trigger perfect block feedback
  - **Normal block**: apply existing chip damage calculation, projectile continues to spawn hazard
- Use existing DR system for normal block damage: treat as ranged attack collision, cap to minimum 1 chip damage

### Perfect Block Window
- Window exists from end of shield raise animation until player releases shield or moves
- Duration: configurable (start at 0.3s, tune to taste)
- Visual indicator: sprite flash when window opens (use existing flash system, 2-3 frame flash)
- Audio indicator: optional perfect block SFX (can be added later)

### Cooldown System
- Cooldown starts when player releases shield button
- Two cooldown values: `block_cooldown_normal` and `block_cooldown_perfect`
- Perfect block cooldown is shorter (e.g., 0.5s vs 1.0s, configurable)
- Can't re-enter shielding state during cooldown
- Cooldown display: optional UI indicator

### Shield Properties Configuration
- Each shield item adds properties to item database:
  - `shield_block_arc`: width of protected angle in degrees (e.g., 90, 120, 150)
  - `shield_block_cooldown_normal`: normal block cooldown in seconds
  - `shield_block_cooldown_perfect`: perfect block cooldown in seconds
- If shield not equipped, block key does nothing
- Default shield properties if not specified: 90° arc, 1.0s normal cooldown, 0.5s perfect cooldown

### Large Projectile Stagger
- Hazard projectiles can be configured with `causes_stagger_on_block: true`
- When such projectile hits shield during normal block (not perfect): apply staggered status to player
- Perfect block destroys projectile before stagger can apply

### Knockback During Block
- Knockback from projectiles still applies to player during block (physics is normal)
- Player pushed by knockback but shield state continues until button released

### Integration with Existing Systems
- Use existing `freeze_frame()` for perfect block impact feedback
- Use existing `spawn_damage_number()` for chip damage numbers on screen
- Reuse ranged focus movement/facing logic for shielding state
- Check for shield equipped using existing `get_equipped_item()` functions

## Approach

1. **Phase 1: State Machine & Input**
   - Add PlayerState.shielding enum value
   - Add block key binding and input detection
   - Implement state transition logic with shield equipped check
   - Implement shielding state movement restrictions (copy ranged focus logic)

2. **Phase 2: Animation & Visual Feedback**
   - Create/add shield raise animation frames to player sprite
   - Implement shield raise animation playback on state entry
   - Add perfect block window sprite flash effect
   - Test animation timing across all four directions

3. **Phase 3: Collision & Damage**
   - Implement collision detection during shielding state
   - Add perfect block window timer and detection
   - Implement perfect block (destroy projectile) logic
   - Implement normal block (chip damage) logic
   - Add projectile hazard spawn prevention on perfect block

4. **Phase 4: Cooldown & Polish**
   - Implement cooldown timer system
   - Add cooldown checks before entering shielding state
   - Differentiate perfect vs normal cooldown durations
   - Add shield properties to item database
   - Implement block arc angle checking (optional enhancement)

5. **Phase 5: Testing & Tuning**
   - Test perfect block window timing (adjust duration as needed)
   - Test cooldown balance (adjust normal vs perfect timings)
   - Test with different shield types and sizes
   - Test stagger on large projectile blocking
   - Balance chip damage values

## External Dependencies

No new external dependencies required. Uses existing GameMaker functionality and game systems.
