# Technical Specification

This is the technical specification for the spec detailed in @.agent-os/specs/2025-10-05-ai-memory-event-system/spec.md

## Technical Requirements

### Global Event Bus System

- Create `global.ai_event_bus` as a `ds_list` in `obj_game_controller` Create event
- Clear the event bus at end of each frame in `obj_game_controller` End Step event
- Destroy the event bus properly in Game End event to prevent memory leaks
- Event structure: `{ type: String, x: Real, y: Real, data: Struct }`
- Event types include: "EnemyDeath", "Noise", "MajorThreat" (extensible string-based system)

### Event Broadcasting Function

- Create global script function `scr_broadcast_ai_event(type, x, y, [data_struct])`
- Function adds structured event to `global.ai_event_bus`
- Optional data parameter allows passing additional context (e.g., damage type, source ID)
- Function should be callable from any object/script context

### Perception System

- Add `perception_radius` variable to AI entities (default: 250 pixels)
- In Step event, iterate through `global.ai_event_bus` and calculate distance to each event
- Events within perception radius are "perceived" and converted to memories
- Self-filtering: AI should ignore events where `event.data.source == self.id` (optional)

### Memory Storage & Management

- Add `my_memories = []` array to each AI entity
- Memory structure: `{ type: String, x: Real, y: Real, timestamp: Real }`
- Add `memory_ttl` variable (default: 30000ms = 30 seconds)
- Add `memory_purge_timer` counter (default: 60 frames between purge checks)
- Memory purging: Remove memories where `(current_time - memory.timestamp) > memory_ttl`
- Purge logic runs every 60 frames (not every frame) for performance

### AI Entity Implementation

- Implement memory system in `obj_enemy_parent` or create new `obj_thinking_enemy_parent`
- Memory perception logic in Step event (before existing AI logic)
- Memory purge logic in Step event (periodic, timer-based)
- Individual enemies can query their own `my_memories` array for decision-making

### Party Controller Integration

- Add identical memory system variables to `obj_enemy_party_controller`
- Party controller perceives events like individual enemies (acts as additional AI entity)
- Extend `update_party_state()` function to analyze party controller's memories
- Morale logic: Count "EnemyDeath" memories within recent time window (e.g., 15 seconds)
- Threshold check: If deaths >= 50% of party size, force state change to cautious/desperate
- Party state changes propagate to all party members through existing party system

### Performance Considerations

- Event bus cleared every frame prevents unbounded growth
- Memory purge runs every 60 frames (not every frame) to reduce overhead
- Use array iteration instead of ds_list for memory storage (modern GML performance)
- Struct-based events and memories (lightweight, no manual cleanup needed)

### Integration Points

- Call `scr_broadcast_ai_event("EnemyDeath", x, y)` in enemy Destroy event or death state
- Existing enemy AI state machines can query `my_memories` array to inform decisions
- Existing party formation and state system receives memory-based state changes
- No changes required to existing combat or damage systems

### Code Location

- Event bus initialization: `objects/obj_game_controller/Create_0.gml`
- Event bus cleanup: `objects/obj_game_controller/End_Step_0.gml` and Game End event
- Broadcasting function: New script file `scripts/scr_broadcast_ai_event/scr_broadcast_ai_event.gml`
- Memory system: `objects/obj_enemy_parent/Create_0.gml` and `Step_0.gml`
- Party integration: `objects/obj_enemy_party_controller/Step_0.gml` (modify existing `update_party_state`)

## External Dependencies

No new external dependencies required. This feature uses only built-in GameMaker functions:
- `ds_list_create()`, `ds_list_add()`, `ds_list_clear()`, `ds_list_destroy()`
- `distance_to_point()`
- `current_time`
- Array functions: `array_push()`, `array_delete()`, `array_length()`
- Struct creation and property access (native GML)
