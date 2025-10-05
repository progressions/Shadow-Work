# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-10-04-companion-casting-animation/spec.md

## Technical Requirements

### 1. CompanionState Enum Modification
- **Location**: `scripts/scr_enums/scr_enums.gml:23-28`
- **Change**: Replace existing enum values with:
  ```gml
  enum CompanionState {
      waiting,    // Not recruited, standing at spawn position
      following,  // Recruited, following player
      casting     // Performing trigger animation
  }
  ```
- **Impact**: This will require updating all companion state checks throughout the codebase:
  - `obj_companion_parent/Create_0.gml:22` - initial state assignment
  - `obj_companion_parent/Step_0.gml:84` - state assignment when not recruited
  - `scripts/scr_companion_system/scr_companion_system.gml:10` - `get_active_companions()` function
  - `scripts/scr_companion_system/scr_companion_system.gml:300` - `recruit_companion()` function

### 2. Animation Data Structure Extension
- **Location**: `obj_companion_parent/Create_0.gml:106-118`
- **Add**: Extend `anim_data` struct with casting animations:
  ```gml
  anim_data = {
      // ... existing idle and walk animations ...

      // Casting animations (3 frames each for Canopy)
      casting_down: { start: 6, length: 3 },   // frames 6-8
      casting_right: { start: 9, length: 3 },  // frames 9-11
      casting_left: { start: 12, length: 3 },  // frames 12-14
      casting_up: { start: 15, length: 3 }     // frames 15-17
  };
  ```
- **Animation Speed**: Calculate frame duration as `100ms / 1000ms * room_speed` = ~6 frames per animation frame at 60fps
- **Add Variables**:
  ```gml
  casting_frame_index = 0;     // Current frame in casting animation
  casting_animation_speed = 6; // Frames to hold each animation frame
  casting_timer = 0;           // Timer for frame advancement
  previous_state = CompanionState.waiting; // State to return to after casting
  ```

### 3. Trigger Activation Integration
- **Location**: `scripts/scr_companion_system/scr_companion_system.gml:194-291` - `evaluate_companion_triggers()` function
- **Modify**: Each trigger activation point to set casting state:
  ```gml
  // Example for shield trigger activation (line ~211)
  if (hp_percent <= companion.triggers.shield.hp_threshold) {
      // Store current state before casting
      companion.previous_state = companion.state;

      // Enter casting state
      companion.state = CompanionState.casting;
      companion.casting_frame_index = 0;
      companion.casting_timer = 0;

      // Activate trigger
      companion.triggers.shield.active = true;
      companion.triggers.shield.cooldown = companion.triggers.shield.cooldown_max;
      companion.shield_timer = companion.triggers.shield.duration;
      spawn_floating_text(player_instance.x, player_instance.bbox_top - 10, "Shield!", c_aqua, player_instance);
      companion_play_trigger_sfx(companion, "shield");
  }
  ```
- **Apply to all triggers**: shield, guardian_veil, gust, dash_mend, aegis, slipstream_boost, maelstrom

### 4. Step Event State Management
- **Location**: `obj_companion_parent/Step_0.gml`
- **Add**: Casting state handling after line 23:
  ```gml
  // Handle casting state
  if (state == CompanionState.casting) {
      // Stop all movement during casting
      move_dir_x = 0;
      move_dir_y = 0;

      // Advance animation timer
      casting_timer++;

      // Advance frame every casting_animation_speed frames
      if (casting_timer >= casting_animation_speed) {
          casting_frame_index++;
          casting_timer = 0;

          // Check if animation complete (3 frames total)
          if (casting_frame_index >= 3) {
              // Return to previous state
              state = previous_state;
              casting_frame_index = 0;
          }
      }

      // Exit early - don't process following logic while casting
      exit;
  }
  ```
- **Modify**: Following behavior logic (line 24-85) to only run when `state == CompanionState.following`
- **Modify**: Idle behavior logic (line 80-85) to use `CompanionState.waiting` instead of checking `!is_recruited`

### 5. Draw Event Animation Rendering
- **Location**: `obj_companion_parent/Draw_0.gml`
- **Add**: Casting animation rendering logic:
  ```gml
  // Determine which animation to play
  if (state == CompanionState.casting) {
      // Select casting animation based on last_dir_index
      var anim_key = "";
      switch (last_dir_index) {
          case 0: anim_key = "casting_down"; break;
          case 1: anim_key = "casting_right"; break;
          case 2: anim_key = "casting_left"; break;
          case 3: anim_key = "casting_up"; break;
      }

      // Only play if companion has casting animations
      if (variable_struct_exists(anim_data, anim_key)) {
          var anim = anim_data[$ anim_key];
          image_index = anim.start + casting_frame_index;
      }
  }
  else {
      // ... existing idle/walk animation logic ...
  }
  ```

### 6. Companion-Specific Implementation
- **Canopy**: Has full casting animation sprite (frames 6-17) - fully supported
- **Other Companions**: Don't have casting frames yet
  - **Fallback Strategy**: Check if casting animation exists before using it
  - **Graceful Degradation**: If `casting_down` doesn't exist in `anim_data`, skip casting animation and activate trigger immediately
  - **Implementation**: Add existence check in trigger activation:
    ```gml
    // Only enter casting state if companion has casting animations
    if (variable_struct_exists(companion.anim_data, "casting_down")) {
        companion.previous_state = companion.state;
        companion.state = CompanionState.casting;
        // ... rest of casting setup
    } else {
        // Just activate trigger without casting animation
        companion.triggers.shield.active = true;
        // ... rest of trigger activation
    }
    ```

## Animation Frame Reference (Canopy)

Based on `companions-casting.json`:
- **Down**: frames 6-8 (3 frames, 100ms each)
- **Right**: frames 9-11 (3 frames, 100ms each)
- **Left**: frames 12-14 (3 frames, 100ms each)
- **Up**: frames 15-17 (3 frames, 100ms each)

Total casting animation duration: ~300ms (18 frames at 60fps)

## Edge Cases & Considerations

1. **Multiple Triggers Activating Simultaneously**: Only one trigger can cast at a time. If already casting, queue trigger activation for after animation completes
2. **Room Transitions**: Casting state should be interrupted if player changes rooms
3. **Companion Dismissal During Casting**: Reset state to `waiting` if dismissed mid-cast
4. **Save/Load**: No need to persist casting state - it's transient and will complete quickly
