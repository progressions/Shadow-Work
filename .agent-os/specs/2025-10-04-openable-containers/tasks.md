# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-10-04-openable-containers/spec.md

> Created: 2025-10-04
> Status: IMPLEMENTATION COMPLETE

## Tasks

### Task 1: Core Container Interaction System

Implement the foundation of the openable container system with player interaction detection, animation control, and the interaction prompt.

**Subtasks:**
1. **Initialize obj_openable variables** - In Create_0.gml, set up all required variables: `is_opened = false`, `interaction_radius = 32`, `loot_mode = "specific"`, `loot_items = []`, `loot_table = []`, `loot_count = 1`, `loot_count_min = 1`, `loot_count_max = 1`, `use_variable_quantity = false`, `image_speed = 0`, `image_index = 0`

2. **Implement interaction detection** - In Step_0.gml, add distance check to obj_player using `point_distance()`, detect when player is within `interaction_radius` and not already opened

3. **Add SPACE key handler** - In Step_0.gml, check `keyboard_check_pressed(vk_space)` when player in range and call `open_container()` function to set `is_opened = true` and play `snd_chest_open`

4. **Create interaction prompt** - In Draw_0.gml, draw "[Space] Open" text 32 pixels above container when player in range and container not opened, use centered white text

5. **Implement animation controller** - In Step_0.gml, add animation logic that increments `image_index` by 0.2 when `is_opened == true`, freeze at frame 3 when animation completes

6. **Test basic interaction** - Place obj_chest in test room, verify player can approach, see prompt, press SPACE to trigger animation and hear opening sound

**Dependencies:** Existing obj_player object, snd_chest_open sound asset, obj_chest sprite with 4 frames

**Acceptance Criteria:**
- Player sees "[Space] Open" prompt when within 32 pixels of unopened container
- Pressing SPACE plays opening sound and starts 4-frame animation
- Animation freezes on frame 3 (fully opened state)
- Interaction only works once per container

---

### Task 2: Loot Spawning System

Implement the three loot modes (specific items, weighted random, variable quantity) and integrate with existing enemy loot system functions.

**Subtasks:**
1. **Create spawn_specific_loot() function** - In obj_openable, implement function that loops through `loot_items` array, calls `find_loot_spawn_position(x, y)` for each item, spawns items using `spawn_item(_pos.x, _pos.y, item_key, 1)`, plays `snd_loot_drop` at end

2. **Create spawn_random_loot() function** - Implement function that calculates spawn count (use `irandom_range(loot_count_min, loot_count_max)` if `use_variable_quantity == true`, else use `loot_count`), loops to spawn count, calls `select_weighted_loot_item(loot_table)` and spawns each item, plays `snd_loot_drop` at end

3. **Integrate loot spawn with animation** - In Step_0.gml animation block, when `image_index >= 3`, check `loot_mode` and call appropriate spawn function ("specific" calls spawn_specific_loot(), "random_weighted" calls spawn_random_loot())

4. **Add loot spawn flag** - Add `loot_spawned = false` variable to prevent duplicate spawning, check flag before spawning and set to true after

5. **Configure obj_chest with specific items** - In obj_chest Create_0.gml, set `loot_mode = "specific"` and `loot_items = ["iron_sword", "health_potion"]` for testing

6. **Test specific loot mode** - Verify opening chest spawns exact items from loot_items array on valid ground positions near container

7. **Configure test chest with weighted loot** - Create second obj_chest instance with `loot_mode = "random_weighted"`, `loot_count = 2`, and sample loot_table with gold_coin (weight 50), health_potion (weight 30), rare_gem (weight 5)

8. **Test weighted and variable loot** - Verify random loot spawning works with fixed count and with variable quantity using loot_count_min/max

**Dependencies:** scr_enemy_loot_system functions (find_loot_spawn_position, select_weighted_loot_item, spawn_item), snd_loot_drop sound, global.item_database

**Acceptance Criteria:**
- Specific mode spawns exact items from loot_items array
- Weighted mode spawns correct quantity of random items based on weights
- Variable quantity mode spawns random count between min/max range
- All items spawn on valid ground without overlapping container or walls
- Loot drop sound plays when items spawn
- Items only spawn once per container

---

### Task 3: Save/Load State Persistence

Integrate containers with the save system to track opened state across game sessions and room transitions.

**Subtasks:**
1. **Implement serialize() method** - In obj_openable, create serialize() function that returns struct with: `openable_id` (generated from object name + x + y coordinates), `is_opened`, `x`, `y`, `object_type` (using object_get_name)

2. **Implement deserialize() method** - Create deserialize(_data) function that sets `is_opened = _data.is_opened` and sets `image_index = is_opened ? 3 : 0` to display correct sprite frame

3. **Update room state serialization** - In scr_save_system/scr_save_system.gml, modify `serialize_room_state()` to collect all obj_openable instances and include their serialized data in room state struct

4. **Update room state deserialization** - Modify `deserialize_room_state(_data)` to iterate through saved container states and call deserialize() on matching container instances in room

5. **Add global opened containers tracking** - Create `global.opened_containers` array to track openable_id strings of opened containers, prevent loot re-spawning on deserialize

6. **Test save/load persistence** - Open chest, save game, reload save - verify chest remains open with correct sprite frame and does not re-spawn loot

7. **Test room transition persistence** - Open chest in room, leave room, return to room - verify chest state persists without re-spawning loot

**Dependencies:** scr_save_system, obj_persistent_parent (if exists, otherwise inherit from base object), room state serialization infrastructure

**Acceptance Criteria:**
- Opened containers remain open after saving and loading game
- Opened containers display frame 3 (open sprite) when room loads
- Loot does not re-spawn when returning to room with opened container
- Container state persists across room transitions
- Unique openable_id correctly identifies each container instance

---

### Task 4: Audio Integration and Child Object Setup

Add sound effects, create additional container types, and polish the system with proper audio timing.

**Subtasks:**
1. **Verify snd_chest_open asset** - Confirm snd_chest_open sound exists in project, test playback timing when open_container() is called

2. **Create or verify snd_loot_drop** - Check if snd_loot_drop exists, if not create placeholder or use existing item pickup sound, integrate with loot spawn functions

3. **Configure obj_chest loot examples** - Set up 3 different obj_chest instances in test room: one with specific items, one with weighted random (fixed count), one with variable quantity to demonstrate all modes

4. **Create obj_barrel child object** - Duplicate obj_chest to create obj_barrel, assign spr_barrel sprite (4 frames), configure with food-themed loot_table (apple, bread, cheese)

5. **Create obj_crate child object** - Duplicate obj_chest to create obj_crate, assign spr_crate sprite (4 frames), configure with tool/material themed loot_table

6. **Test audio timing** - Verify snd_chest_open plays immediately when SPACE pressed, snd_loot_drop plays when animation completes at frame 3, no audio overlaps or delays

7. **Add debug validation** - In obj_openable Create event, add validation loop that checks all item_keys in loot_items/loot_table exist in global.item_database, show_debug_message() warnings for missing items

8. **Final integration test** - Test all container types (chest, barrel, crate) with all loot modes, verify animations, audio, loot spawning, and save/load work correctly

**Dependencies:** Sound assets (snd_chest_open, snd_loot_drop), sprite assets for barrel and crate, global.item_database

**Acceptance Criteria:**
- Opening sound plays immediately when container begins opening
- Loot drop sound plays when animation completes and items spawn
- All three container types (chest, barrel, crate) work with appropriate sprites
- Debug validation warns about invalid item_keys in loot configuration
- All loot modes work correctly across all container types
- Audio timing feels responsive and polished
