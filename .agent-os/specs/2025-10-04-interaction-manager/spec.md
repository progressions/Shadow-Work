# Spec Requirements Document

> Spec: Interaction Manager System
> Created: 2025-10-04

## Overview

Implement a centralized interaction manager that prevents multiple interactive objects (companions, chests, doors) from responding to the same input simultaneously. This system will use priority-based selection to determine which object should respond to player input, providing clear visual feedback and predictable behavior.

## User Stories

### Story 1: Clear Interaction Priority

As a player, I want only the nearest/most relevant interactive object to respond when I press the interaction key, so that I don't accidentally interact with the wrong object when multiple objects are nearby.

**Workflow:** When the player approaches an area with multiple interactive objects (e.g., a companion and a chest), the system identifies the highest-priority object within interaction range, displays a single interaction prompt for that object, and only that object responds when the player presses the interaction key. Priority is determined by a combination of object type (companions > quest markers > chests > doors) and distance from the player.

### Story 2: Consistent Visual Feedback

As a player, I want to see exactly which object I will interact with before pressing the button, so that I can make informed decisions about my actions.

**Workflow:** The interaction prompt appears only above the currently selected interactive object. As the player moves around, the prompt updates to follow the new highest-priority object. This eliminates confusion about which object will respond to input.

## Spec Scope

1. **Interaction Manager Object** - Create obj_interaction_manager singleton that runs at high priority and manages all interaction logic
2. **Priority System** - Implement weighted priority scoring based on object type and distance from player
3. **Interactive Object Interface** - Standardize all interactive objects with required properties (interaction_radius, interaction_priority, can_interact(), on_interact())
4. **Single Prompt Display** - Ensure obj_interaction_prompt only appears for the currently selected interactive object
5. **Input Routing** - Route SPACE key input through the manager to the selected object only

## Out of Scope

- Changing the visual design of interaction prompts
- Adding new interactive object types (will use existing: companions, chests, doors)
- Gamepad/controller input mapping (SPACE key only)
- Multiple simultaneous interactions

## Expected Deliverable

1. Player can approach multiple interactive objects and see only one interaction prompt at a time
2. Pressing SPACE interacts with only the object displaying the prompt
3. Priority correctly favors companions over chests, chests over doors, with distance as tiebreaker
4. Existing interactive objects (obj_chest, obj_companion_parent) work with minimal modifications
