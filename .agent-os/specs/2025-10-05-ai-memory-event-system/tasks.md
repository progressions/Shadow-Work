# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-10-05-ai-memory-event-system/spec.md

> Created: 2025-10-05
> Status: IMPLEMENTATION COMPLETE

## Tasks

- [x] 1. Implement Global Event Bus System
  - [x] 1.1 Write tests for event bus creation, broadcasting, and clearing
  - [x] 1.2 Add `global.ai_event_bus` ds_list initialization in `obj_game_controller` Create event
  - [x] 1.3 Add event bus clearing in `obj_game_controller` End Step event
  - [x] 1.4 Add event bus destruction in `obj_game_controller` Game End event
  - [x] 1.5 Create `scr_broadcast_ai_event(type, x, y, [data_struct])` script function
  - [x] 1.6 Verify all tests pass

- [x] 2. Implement Memory System for Individual Enemies
  - [x] 2.1 Write tests for memory perception, storage, and expiration
  - [x] 2.2 Add memory variables to `obj_enemy_parent` Create event (my_memories, perception_radius, memory_ttl, memory_purge_timer)
  - [x] 2.3 Implement perception logic in `obj_enemy_parent` Step event (iterate event bus, check distance, create memories)
  - [x] 2.4 Implement memory purge logic in `obj_enemy_parent` Step event (periodic cleanup of expired memories)
  - [x] 2.5 Add self-filtering to prevent enemies from perceiving their own events
  - [x] 2.6 Verify all tests pass

- [x] 3. Integrate Memory System with Enemy Party Controller
  - [x] 3.1 Write tests for party controller memory perception and morale breaking
  - [x] 3.2 Add memory system variables to `obj_enemy_party_controller` Create event
  - [x] 3.3 Add perception and purge logic to `obj_enemy_party_controller` Step event
  - [x] 3.4 Extend `update_party_state()` function to analyze death memories
  - [x] 3.5 Implement morale threshold logic (deaths >= 50% of party triggers state change)
  - [x] 3.6 Verify all tests pass

- [x] 4. Integrate Event Broadcasting with Enemy Death
  - [x] 4.1 Write tests for death event broadcasting
  - [x] 4.2 Add `scr_broadcast_ai_event("EnemyDeath", x, y)` call to enemy death handling code
  - [x] 4.3 Test that nearby enemies perceive and store death events in their memories
  - [x] 4.4 Verify all tests pass

- [x] 5. End-to-End Testing and Validation
  - [x] 5.1 Create test scenario: 4-bandit party in test room
  - [x] 5.2 Verify death events are broadcast and perceived by nearby enemies
  - [x] 5.3 Verify morale breaking triggers when 2+ enemies die within 15 seconds
  - [x] 5.4 Verify party state changes from aggressive to cautious
  - [x] 5.5 Verify memories expire after 30 seconds
  - [x] 5.6 Verify no memory leaks or performance degradation
  - [x] 5.7 Test with different enemy types and party configurations
  - [x] 5.8 Verify all tests pass and feature is complete
