# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-10-03-grid-based-lighting/spec.md

> Created: 2025-10-03
> Status: IMPLEMENTATION COMPLETE

## Tasks

- [x] 1. Core Lighting Infrastructure
  - [x] 1.1 Create obj_lighting_controller object with Create, Step, Draw, and Clean Up events
  - [x] 1.2 Implement init_light_grid() to create ds_grid (grid_width x grid_height) with 16px cell size
  - [x] 1.3 Implement clear_light_grid() to reset all cells to 0 each frame
  - [x] 1.4 Implement add_light_source(x, y, radius) with stepped falloff algorithm (100%, 75%, 50%, 25%, 0%)
  - [x] 1.5 Implement surface-based render_lighting() with subtractive blend mode (bm_subtract)
  - [x] 1.6 Add pause-safe step() that respects global.game_paused flag
  - [x] 1.7 Implement surface lifetime handling (surface_dirty flag, recreation on context loss)
  - [x] 1.8 Add cleanup_surface() in Clean Up event (free surface, destroy ds_grid, reset references)

- [x] 2. Inventory System Extensions for Torches
  - [x] 2.1 Update torch item definition in scr_item_database with stack_size and burn_time_seconds metadata
  - [x] 2.2 Create inventory_has_item_id(_item_id) helper function
  - [x] 2.3 Create inventory_find_item_id(_item_id) helper function (returns slot index or -1)
  - [x] 2.4 Create inventory_consume_item_id(_item_id, _count) helper function (decrements stack, removes empty slots)
  - [x] 2.5 Verify torch stacking works correctly in inventory UI

- [x] 3. Player Torch System with Audio
  - [x] 3.1 Add torch_active, torch_time_remaining, torch_duration, torch_sound_emitter properties to obj_player
  - [x] 3.2 Create audio emitter in obj_player Create event and free in Clean Up event
  - [x] 3.3 Implement torch detection in Step event (check equipped.left_hand.item_id == "torch")
  - [x] 3.4 Add torch equip state change detection and play snd_torch_equip sound
  - [x] 3.5 Start looped snd_torch_burning_loop on emitter when torch becomes active
  - [x] 3.6 Implement torch duration countdown (decrement torch_time_remaining)
  - [x] 3.7 Add torch burnout logic: play snd_torch_burnout, stop burning loop, auto-equip from inventory
  - [x] 3.8 Update emitter position each frame while torch active

- [x] 4. Companion Torch System with Transfer Mechanics
  - [x] 4.1 Add carrying_torch, torch_time_remaining, torch_sound_emitter to obj_companion_parent
  - [x] 4.2 Create audio emitter for companions in Create event and free in Clean Up event
  - [x] 4.3 Implement L key handler in obj_player: transfer torch to first companion from get_active_companions()
  - [x] 4.4 Play snd_companion_torch_receive and start companion's burning loop on L key transfer
  - [x] 4.5 Implement companion torch countdown with auto-refill from player inventory using inventory_consume_item_id()
  - [x] 4.6 Create companion_take_torch_function() for VN dialogue integration
  - [x] 4.7 Register companion_take_torch function in obj_game_controller with ChatterboxAddFunction()
  - [x] 4.8 Add "Carry the torch for me" dialogue option to companion Yarn files

- [x] 5. World Light Sources and Room Configuration
  - [x] 5.1 Create obj_light_source parent object with light_radius and light_active properties
  - [x] 5.2 Create spr_torch_wall and spr_lamp_standing sprites
  - [x] 5.3 Create obj_torch_wall child object inheriting from obj_light_source
  - [x] 5.4 Create obj_lamp_standing child object inheriting from obj_light_source
  - [x] 5.5 Update obj_lighting_controller to detect all light sources (player, companions, world objects)
  - [x] 5.6 Create test room with darkness_level = 0 (fully lit) and verify no overlay renders
  - [x] 5.7 Create test room with darkness_level = 0.8 and place world light sources
  - [x] 5.8 Verify non-additive light blending (max brightness) with overlapping sources

- [x] 6. Sound Assets and Final Integration
  - [x] 6.1 Create/import snd_torch_equip sound asset
  - [x] 6.2 Create/import snd_torch_burnout sound asset
  - [x] 6.3 Create/import snd_torch_burning_loop sound asset (looped)
  - [x] 6.4 Create/import snd_companion_torch_receive sound asset
  - [x] 6.5 Test all torch sound triggers (equip, burnout, transfer, burning loop)
  - [x] 6.6 Verify all expected deliverables from spec.md
  - [x] 6.7 Performance test with 20+ light sources in single room
  - [x] 6.8 Final integration test: player torch → companion transfer → auto-refill → VN dialogue option

- [x] 7. Save/Load System Integration
  - [x] 7.1 Add torch state serialization to save system (torch_active, torch_time_remaining for player)
  - [x] 7.2 Add companion torch state serialization (carrying_torch, torch_time_remaining per companion)
  - [x] 7.3 Implement torch state deserialization in load system
  - [x] 7.4 Restore audio emitters and restart burning loop sounds when loading saved torch states
  - [x] 7.5 Test save with active player torch and verify state restoration on load
  - [x] 7.6 Test save with companion carrying torch and verify state restoration on load
  - [x] 7.7 Test save with multiple torches in inventory and verify counts preserved
  - [x] 7.8 Test edge case: save at moment of torch burnout/transfer
