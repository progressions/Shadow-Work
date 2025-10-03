# Spawner System Testing Guide

## Task 1 Completion Summary

Task 1 has been successfully implemented with the following components:

### Created Files

1. **Enum Addition** - `scripts/scr_enums/scr_enums.gml`
   - Added `SpawnerMode` enum with `finite` and `continuous` values

2. **Helper Script** - `scripts/scr_spawner_helpers/`
   - `scr_spawner_helpers.gml` - Contains 6 helper functions:
     - `spawner_select_enemy()` - Weighted enemy selection
     - `spawner_can_spawn()` - Check spawn conditions
     - `spawner_cleanup_dead_enemies()` - Remove dead references
     - `spawner_check_proximity()` - Distance calculation
     - `spawner_spawn_enemy()` - Main spawn logic
     - `spawner_take_damage()` - Damage handling
   - `scr_spawner_helpers.yy` - Script resource file

3. **Spawner Object** - `objects/obj_spawner_parent/`
   - `obj_spawner_parent.yy` - Object definition
   - `Create_0.gml` - Configuration and state initialization
   - `Step_0.gml` - Proximity checking and spawn logic
   - `Draw_0.gml` - Visibility handling (with commented debug options)
   - `Collision_obj_attack.gml` - Damage handling

4. **Project Integration**
   - Updated `Shadow Work.yyp` to include new object and script

## How to Test in GameMaker

### Step 1: Open the Project

1. Open GameMaker Studio 2
2. Open the "Shadow Work" project
3. The new resources should appear in the Asset Browser:
   - Objects → obj_spawner_parent
   - Scripts → scr_spawner_helpers

### Step 2: Place a Spawner in a Test Room

1. Open any test room (e.g., `room_greenwood_forest_3`)
2. From the Asset Browser, drag `obj_spawner_parent` into the room
3. Click on the spawner instance to open the Instance Properties panel

### Step 3: Configure the Spawner (Optional)

In the Instance Creation Code, you can override the default values:

```gml
// Example: Finite spawner that spawns 5 orcs
spawn_mode = SpawnerMode.finite;
max_total_spawns = 5;
max_concurrent_enemies = 2;
spawn_table = [
    {enemy_object: obj_orc, weight: 1}
];

// Make it visible for testing
is_visible = true;
```

### Step 4: Test Basic Functionality

1. Press **F5** to run the game
2. Walk near the spawner location
3. Expected behavior:
   - Spawner should create enemies at the configured interval (default 3 seconds)
   - Maximum 2 enemies should be alive at once (default cap)
   - Check the Output window for debug messages

### Step 5: Test Proximity Activation

Create a proximity-based spawner:

```gml
proximity_enabled = true;
proximity_radius = 150;
is_visible = true;
spawn_table = [
    {enemy_object: obj_burglar, weight: 1}
];
```

Expected behavior:
- Spawner only spawns when player is within 150 pixels
- Stops spawning when player leaves the radius

### Step 6: Test Weighted Spawn Table

```gml
spawn_table = [
    {enemy_object: obj_orc, weight: 70},
    {enemy_object: obj_burglar, weight: 30}
];
max_concurrent_enemies = 5;
is_visible = true;
```

Expected behavior:
- Should spawn ~70% orcs and ~30% burglars over time
- Monitor debug output to verify distribution

### Step 7: Test Damageable Spawner

```gml
is_damageable = true;
is_visible = true;
hp_total = 20;
hp_current = 20;
spawn_mode = SpawnerMode.continuous;
```

Expected behavior:
- Spawner can be attacked by player
- Takes damage and shows debug messages
- When HP reaches 0, spawner stops spawning
- Spawned enemies remain active after spawner destruction

## Debug Information

To enable debug visualizations, uncomment the debug code in `objects/obj_spawner_parent/Draw_0.gml`:

- Shows spawn count, active enemies, timer, and status
- Shows proximity radius as yellow circle

## Known Limitations

- No sprite assigned (sprite_index = null), so visible spawners won't show graphics yet
- No audio effects configured (spawn_sound = noone by default)
- Save/load integration not yet implemented (Task 5)

## Next Steps

Once basic testing is complete, proceed to:
- Task 2: Implement weighted spawn system refinements
- Task 3: Proximity and enemy cap improvements
- Task 4: Damageable spawner mechanics
- Task 5: Save/load integration
- Task 6: Create example child spawner objects
