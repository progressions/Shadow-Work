# Spec Requirements Document

> Spec: Enemy Party Controller
> Created: 2025-10-03

## Overview

Implement an enemy party controller system that enables groups of enemies to coordinate their behavior through formations, shared state, and weighted decision-making. This system will allow enemies to act tactically as a unit while maintaining individual pathfinding capabilities, creating more strategic and dynamic combat encounters.

## User Stories

### Strategic Enemy Encounters

As a game designer, I want to create coordinated enemy groups with formation-based tactics, so that combat encounters feel more tactical and challenging rather than individual enemies acting independently.

**Workflow:** Designer places an `obj_enemy_party_controller` (or child) in a room, configures party parameters (formation template, aggression settings, protection point), and assigns enemies to the party. When the player enters the area, enemies coordinate their positions and behavior based on party state (aggressive, cautious, desperate, protecting), dynamically adjusting their formation as members are killed and weights shift based on combat conditions.

### Dynamic Formation Adaptation

As a player, I want enemy groups to adapt their tactics based on casualties and my health, so that combat remains challenging and unpredictable throughout the encounter.

**Workflow:** Player engages a party of 5 enemies in aggressive formation. As the player defeats 2 enemies, the remaining 3 shift to a cautious formation. When the player's health drops below 30%, the party becomes emboldened and presses the attack. If only 1 enemy remains, it enters desperate state and may flee based on party configuration.

### Location Defense

As a game designer, I want enemy parties to guard specific locations (gates, chests, NPCs), so that I can create spatial objectives that require the player to overcome tactical defenders.

**Workflow:** Designer places a party controller in "protecting" mode at a gate with a defined protect_radius. Enemies maintain defensive formation around the protection point. If the player approaches, enemies engage but remain tethered to the protection area, returning to formation if the player retreats beyond the radius.

## Spec Scope

1. **Party Controller Object** - Create `obj_enemy_party_controller` with configurable formation templates, party states, decision weights, and member management
2. **Weighted Decision System** - Implement three-objective decision making (attack player, return to formation, flee) with dynamic weights based on party survival percentage, player HP, and total party HP
3. **Formation System** - Define formation templates using relative offsets that procedurally adjust based on party size and assign roles to party members
4. **Party State Machine** - Implement party states (protecting, aggressive, cautious, desperate, emboldened, retreating) with configurable transition thresholds
5. **Grid Pathfinding Integration** - Integrate with existing grid-based pathfinding so enemies use strategic positioning to reach attack targets or formation positions
6. **Party Leader System** - Support optional party leader designation with placeholder override function called on leader death
7. **Save/Load Integration** - Serialize party controller state including members, formation, current state, and leader designation
8. **Audio Feedback** - Trigger audio cues on party state transitions (battle cries, retreat horns, etc.)
9. **Debug Visualization** - Draw formation positions and party state information in debug mode

## Out of Scope

- Coordinated attack bonuses (flanking damage, synchronized attacks)
- Party-to-party combat (enemies fighting other enemy parties)
- Dynamic party membership (reinforcements joining, voluntary fleeing)
- Cross-room party persistence
- Visual indicators for party membership (colored outlines, overhead icons)
- Shared party resources (morale system, shared cooldowns)
- Individual enemy targeting (all party members target the player)

## Expected Deliverable

1. Player can encounter enemy parties that maintain formations, adapt tactics based on casualties and player health, and use grid pathfinding to coordinate attacks
2. Designer can place party controllers (base or inherited) in rooms with configurable formations, states, and behavior weights
3. Party state persists correctly through save/load cycles including member tracking and formation data
4. Debug mode displays formation positions and party state information for testing and tuning
