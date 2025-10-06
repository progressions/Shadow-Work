# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-10-05-party-controller-optimization/spec.md

## Technical Requirements

### 1. Staggered Update System

**Location:** `objects/obj_enemy_party_controller/Create_0.gml`

Add new variable:
- `decision_update_index = 0` - Tracks which party member updates next

**Location:** `objects/obj_enemy_party_controller/Step_0.gml`

Replace the current decision weight loop (lines 104-109):
```gml
// OLD CODE (every frame, all members):
for (var i = 0; i < array_length(party_members); i++) {
    var _enemy = party_members[i];
    if (instance_exists(_enemy)) {
        calculate_decision_weights(_enemy);
    }
}
```

With staggered update logic:
```gml
// NEW CODE (round-robin, 1-2 members per frame):
if (array_length(party_members) > 0) {
    // Calculate how many to update this frame (1-2 members)
    var _updates_per_frame = min(2, array_length(party_members));

    for (var i = 0; i < _updates_per_frame; i++) {
        // Wrap index around party size
        var _member_index = (decision_update_index + i) mod array_length(party_members);
        var _enemy = party_members[_member_index];

        if (instance_exists(_enemy)) {
            calculate_decision_weights(_enemy);
        }
    }

    // Advance index for next frame
    decision_update_index = (decision_update_index + _updates_per_frame) mod array_length(party_members);
}
```

**Performance Impact:**
- With 10 party members: 10 updates/frame → 2 updates/frame = **80% reduction**
- Each member still updates every 5 frames (0.083 seconds at 60fps)
- CPU load: 500-1000 ops/frame → 100-200 ops/frame

### 2. Empty Party Controller Cleanup

**Location:** `objects/obj_enemy_party_controller/Step_0.gml`

Add cleanup check at the end of Step event (after all other logic):
```gml
// Destroy party controller if all members are dead
if (array_length(party_members) == 0) {
    instance_destroy();
}
```

**Rationale:**
- Prevents empty controllers from running AI logic indefinitely
- Frees memory and processing resources
- Simple one-line check with minimal overhead

### 3. Optional Debug Output

**Location:** `objects/obj_enemy_party_controller/Draw_64.gml` (existing debug display)

Add performance metrics to debug overlay:
- Updates per frame count
- Current update index
- Members in party vs initial party size

Example addition:
```gml
// Add after line 75 (member count display)
draw_set_color(c_aqua);
draw_text(_x, _y, "Update Index: " + string(decision_update_index));
_y += _line_height;
```

### 4. Edge Cases to Handle

**Empty array handling:**
- `mod` operation with 0 will cause error
- Check `array_length(party_members) > 0` before update loop
- Already handled by cleanup in requirement #2

**Member death during update:**
- `on_member_death()` function removes members and calls `assign_formation_roles()`
- Index may become invalid if pointing to removed member
- Solution: Use `mod array_length()` to wrap index automatically
- `instance_exists()` check provides safety net

**Party size changes:**
- Index wraps correctly with `mod` operator
- No special handling needed

## Performance Measurement

Before optimization (with 10 party members):
- Decision weight calculations: 10 per frame
- Estimated operations: 500-1000 per frame

After optimization (with 10 party members):
- Decision weight calculations: 2 per frame
- Estimated operations: 100-200 per frame
- **Reduction: 80-90%**

Update frequency per enemy:
- Updates every 5 frames = 0.083 seconds at 60fps
- Still feels instant to player
- Responsive enough for combat AI decisions
