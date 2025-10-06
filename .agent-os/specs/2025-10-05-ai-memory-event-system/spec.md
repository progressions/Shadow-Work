# Spec Requirements Document

> Spec: AI Memory & Event System
> Created: 2025-10-05

## Overview

Implement a memory and event system that gives enemy AI the ability to perceive, remember, and react to significant world events, enabling more dynamic and intelligent behavior based on past experiences rather than just immediate situations.

## User Stories

### Morale-Based Tactical Response

As a player, I want enemies to react realistically to witnessing their allies dying in combat, so that encounters feel more tactical and dynamic rather than enemies mindlessly attacking until death.

When multiple enemies in a party witness several of their allies being killed within a short time window (e.g., 2 out of 4 bandits die within 15 seconds), the surviving enemies should change their behavior - becoming cautious, retreating to defensive positions, or attempting to flee. This creates more interesting combat scenarios where the player can break enemy morale through aggressive tactics.

### Intelligent Threat Awareness

As a player, I want enemies to remember and react to dangerous events they've witnessed nearby, so that combat feels more intelligent and enemies don't repeatedly make the same mistakes.

When an enemy perceives a major threat event (like a powerful explosion or a companion being killed), they should remember this for a reasonable time period (e.g., 30 seconds) and adjust their tactics accordingly - such as maintaining distance, seeking cover, or calling for reinforcements. This memory should fade over time, allowing enemies to return to normal behavior if the threat passes.

### Coordinated Party Awareness

As a player, I want enemy parties to share awareness of events through their controller, so that the group responds cohesively to threats rather than each enemy acting independently without coordination.

When one member of an enemy party perceives a significant event, the party controller should also be aware of it and can make strategic decisions affecting the entire group - such as changing formation, switching from aggressive to defensive tactics, or ordering a retreat. This creates more challenging and realistic group combat encounters.

## Spec Scope

1. **Global Event Bus** - Implement a frame-by-frame event broadcasting system that allows any game entity to publish significant events (deaths, sounds, threats) to a global list that is cleared each frame.

2. **Perception System** - Add perception radius mechanics to AI entities allowing them to "sense" nearby events based on distance, filtering out self-generated events and events outside their awareness range.

3. **Memory Storage** - Implement time-limited memory arrays for AI entities that store perceived events with timestamps, automatically purging expired memories to prevent performance degradation.

4. **Party Controller Integration** - Extend the existing `obj_enemy_party_controller` to use the memory system for making strategic party-wide decisions based on accumulated event memories.

5. **Morale Breaking Logic** - Implement decision-making logic that analyzes recent death events in memory to trigger state changes (aggressive → cautious/desperate) when morale thresholds are crossed.

## Out of Scope

- Visual or audio perception differentiation (all events use single perception radius)
- Player memory system (only AI enemies use this system)
- Positive reinforcement events (ally healed, leader buffed, etc.)
- Advanced memory query helper functions beyond basic type counting
- UI indicators showing enemy memory or awareness state
- Save/load persistence of enemy memories (memories are runtime-only)

## Expected Deliverable

1. **Event Broadcasting Works**: Player kills an enemy, death event is broadcast to global event bus, and nearby enemies can perceive and store the event in their memory arrays.

2. **Morale Breaking Triggers**: When 2 out of 4 bandits in a party are killed within 15 seconds, the party controller detects this through its memory system and changes party_state from aggressive to cautious, causing surviving bandits to change their behavior.

3. **Memory Expiration Functions**: After 30 seconds pass, old memories are automatically purged from enemy memory arrays, and enemies no longer react to those expired events.
