# AI Memory & Morale System - Testing Guide

## Overview

The AI Memory & Event System allows enemies to perceive, remember, and react to significant world events like ally deaths. This guide explains how to observe and test the system in-game.

## Visual Debugging

When an `obj_enemy_party_controller` is active in the room, you'll see a debug overlay in the **top-right corner** showing:

- **State**: Current party state (AGGRESSIVE, CAUTIOUS, DESPERATE, etc.)
- **Party**: Number of alive enemies vs total party size
- **Recent Deaths**: Number of death events perceived in last 15 seconds
- **Morale Status**: Shows "MORALE BROKEN!" when threshold is crossed
- **Total Memories**: Total events stored in party controller memory

### Color Coding

- **Red/Orange State**: Aggressive or cautious
- **Red "Recent Deaths"**: Morale threshold reached (≥50% of party)
- **Red "MORALE BROKEN!"**: Party has switched to cautious state due to deaths
- **Green "Morale OK"**: Party morale is stable

## How to Test Morale Breaking

### Method 1: Test with Orc Raiding Party

1. Find a room with `obj_orc_raiding_party` (5 orcs in wedge formation)
2. Engage the party in combat
3. Watch the debug overlay in the top-right
4. Kill 2-3 orcs **quickly** (within 15 seconds)
5. Observe the following changes:
   - "Recent Deaths" count increases to 2-3
   - "MORALE BROKEN!" appears in red
   - State changes from "AGGRESSIVE" to "CAUTIOUS"
   - Surviving orcs change behavior (more defensive, less aggressive)

### Method 2: Test with Gate Guard Party

1. Find a room with `obj_gate_guard_party`
2. Follow the same process as above
3. Different party configurations may have different thresholds

## Expected Behavior

### Before Morale Break (Aggressive State)
- Enemies actively pursue player
- Coordinated attacks
- Maintain formation around player
- Red "AGGRESSIVE" state displayed
- High attack priority, normal flee/formation weights

### After Morale Break (Cautious State)
- **Attack weight reduced to 40%** - enemies much less aggressive
- **Flee weight increased 2.5x** - enemies retreat or keep distance
- **Formation weight increased 1.8x** - prioritize staying together
- Enemies will likely choose "flee" or "formation" objectives instead of "attack"
- Orange "CAUTIOUS" state displayed
- "Recent Deaths" shows 2+ (for 4-5 member parties)
- Surviving enemies will move away from player toward formation positions or flee targets

## Key Mechanics

### Perception Radius
- Enemies perceive death events within 250 pixels
- Both individual enemies and party controllers perceive events
- Events outside this radius are ignored

### Memory Time Window
- Death events are remembered for 30 seconds (full TTL)
- Only deaths within last 15 seconds count toward morale breaking
- Old memories are automatically purged every 60 frames

### Morale Threshold
- Morale breaks when **≥50% of party members** have died recently
- Examples:
  - 4-member party: 2+ deaths trigger morale break
  - 5-member party: 3+ deaths trigger morale break
  - 6-member party: 3+ deaths trigger morale break

## Testing Scenarios

### Scenario 1: Rapid Kills (Morale Should Break)
1. Engage 5-orc party
2. Kill 3 orcs within 10 seconds
3. **Expected**: "MORALE BROKEN!" appears, state → CAUTIOUS

### Scenario 2: Slow Kills (Morale Should NOT Break)
1. Engage 5-orc party
2. Kill 1 orc, wait 20 seconds
3. Kill another orc, wait 20 seconds
4. **Expected**: Old deaths expire from memory, morale stays OK

### Scenario 3: Memory Expiration
1. Engage party, kill 2 enemies quickly
2. Watch "MORALE BROKEN!" appear
3. Disengage and wait 15+ seconds without killing
4. **Expected**: "Recent Deaths" drops to 0, morale recovers

## Troubleshooting

### "Recent Deaths" not increasing
- Ensure you're killing enemies within perception radius (250px) of party controller
- Party controller position is usually near the party center
- Check that enemies are actually dying (not just taking damage)

### Morale not breaking despite deaths
- Verify deaths happened within 15-second window
- Check that Recent Deaths count shows ≥50% of party size
- Some custom party configurations may have modified thresholds

### No debug overlay visible
- Ensure there's an `obj_enemy_party_controller` instance in the room
- Check that party_members array is not empty
- Overlay appears in top-right corner of screen (GUI layer)

## Advanced Testing

### Manual Test Hotkeys (Optional)
- **F1**: Run death event broadcasting tests
- **F7**: Run AI event bus tests
- **F11**: Run AI memory system tests
- **F12**: Run party memory & morale tests

These run automated test suites in the console - use them if you want to verify the underlying system logic without manual testing.

## Implementation Notes

### For Developers

The morale breaking logic is in `obj_enemy_party_controller.update_party_state()`:

```gml
// Count recent death events from memory (within 15 second window)
var _recent_deaths = 0;
var _death_check_window = 15000; // 15 seconds
for (var i = 0; i < array_length(my_memories); i++) {
    var _mem = my_memories[i];
    if (_mem.type == "EnemyDeath" && (current_time - _mem.timestamp) < _death_check_window) {
        _recent_deaths++;
    }
}

// If 50% or more of the party has died recently, force cautious state
if (_recent_deaths >= array_length(party_members) * 0.5) {
    transition_to_state(PartyState.cautious);
}
```

Death events are broadcast in `scr_enemy_state_dead()` when an enemy completes its death animation.
