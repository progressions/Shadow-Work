# Chest and Breakable Tracking System

This document explains how to implement chest and breakable object tracking for the save system.

## Chest Tracking

When you create chest objects in the future, add the following to enable save/load persistence:

### obj_chest_parent Create Event

```gml
// Generate unique chest ID for tracking
chest_id = string(room) + "_chest_" + string(x) + "_" + string(y);

// Chest state
opened = false;
```

### When Chest is Opened (in chest interaction code)

```gml
if (!opened) {
    opened = true;

    // Track opened chest for room state persistence
    array_push(global.opened_chests, chest_id);

    // Change sprite to open chest
    sprite_index = spr_chest_open;

    // Give player loot
    // ... your chest loot code here ...
}
```

The save system will automatically:
- Save which chests are opened when leaving a room
- Restore opened chests when returning to a room
- Keep chests opened across save/load cycles

## Breakable Tracking

When you create breakable objects (crates, barrels, etc.), add the following:

### obj_breakable_parent Create Event

```gml
// Generate unique breakable ID for tracking
breakable_id = string(room) + "_breakable_" + string(x) + "_" + string(y);

// Breakable state
hp = 1; // Or however much HP the breakable has
```

### When Breakable is Destroyed (in collision or damage event)

```gml
hp -= damage;

if (hp <= 0) {
    // Track broken breakable for room state persistence
    array_push(global.broken_breakables, breakable_id);

    // Optional: Spawn loot
    // ... your loot spawning code here ...

    // Destroy the breakable
    instance_destroy();
}
```

The save system will automatically:
- Save which breakables are destroyed when leaving a room
- Prevent destroyed breakables from respawning when returning to a room
- Keep breakables destroyed across save/load cycles

## Important Notes

- **Unique IDs**: Each chest/breakable generates a unique ID based on room + position
- **Parent Objects**: Make sure to use `obj_chest_parent` and `obj_breakable_parent` as the parent objects
- **Room Persistence**: The system automatically handles room state when you transition between rooms
- **Save Files**: Chest and breakable states are included in save files automatically

## Testing

To test the tracking system:

1. Open a chest in a room
2. Leave the room and return
3. Verify the chest is still open
4. Save the game, load the game
5. Verify the chest is still open after loading
