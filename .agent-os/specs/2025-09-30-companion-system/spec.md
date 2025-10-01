# Spec Requirements Document

> Spec: Companion System - Phase 1 (Canopy)
> Created: 2025-09-30
> Status: Planning

## Overview

Implement a companion system that allows players to recruit NPC allies who follow them, provide passive benefits through auras, and activate special abilities during combat. Phase 1 focuses on establishing the core companion infrastructure and implementing the first companion, Canopy, as a proof of concept.

The companion system will support up to 12 total companions (Canopy + 11 others planned for future phases), with the player able to have active companions in their party. Companions will have persistent state including affinity levels, recruitment status, and quest progression flags that persist across game sessions.

## User Stories

1. **As a player, I want to recruit Canopy as a companion** so that I have an ally who follows me and helps in combat
   - Player approaches Canopy NPC in the world
   - Player interacts with Canopy to initiate recruitment
   - Canopy joins the player's party and begins following
   - Canopy's recruitment persists across game sessions

2. **As a player, I want my companion to follow me intelligently** so they stay nearby without blocking my movement
   - Companion follows at 24-32 pixel distance
   - Companion uses pathfinding to navigate around obstacles
   - Companion doesn't interfere with player combat or movement
   - Companion transitions between rooms with the player

3. **As a player, I want passive benefits from my companion** so they provide value even when not actively fighting
   - Canopy provides Protective aura (+1 DR to player)
   - Canopy provides Regeneration aura (passive HP recovery)
   - Auras activate when companion is in party and active
   - Aura effects stack with other game systems

4. **As a player, I want my companion to help in combat** so they provide active support during dangerous situations
   - Canopy activates Shield trigger when player HP drops below threshold
   - Shield provides temporary damage reduction
   - Trigger has cooldown to prevent spam
   - Visual/audio feedback when trigger activates

5. **As a player, I want to build affinity with my companion** so our relationship grows stronger over time
   - Affinity system tracks relationship level (1.0-10.0)
   - Affinity can be increased through gameplay (future implementation)
   - Affinity value persists across game sessions
   - Foundation for future affinity-based features

## Spec Scope

### Phase 1 Deliverables

1. **Core Companion Infrastructure**
   - `obj_companion_parent` object with instance-based data storage
   - Companion state management (recruited, active, following)
   - Animation system using existing sprite assets
   - Persistent flag for room transitions

2. **Canopy Implementation**
   - `obj_canopy` inheriting from `obj_companion_parent`
   - Recruitment interaction system
   - Following AI behavior with pathfinding
   - Protective aura (+1 DR to player)
   - Regeneration aura (passive HP recovery)
   - Shield trigger (activates at low player HP)
   - Animation using `spr_canopy` sprite sheet

3. **Aura System**
   - Aura definition structure (type, value, conditions)
   - Aura application to player stats
   - Multiple simultaneous auras support
   - Clean aura removal on companion deactivation

4. **Trigger System**
   - Trigger definition structure (conditions, effects, cooldowns)
   - Trigger evaluation during gameplay
   - Effect application and expiration
   - Cooldown management

5. **Following AI**
   - Distance-based following (24-32 pixel range)
   - Pathfinding using `move_and_collide()`
   - Collision avoidance with enemies and obstacles
   - Smooth movement animation

6. **Save/Load Integration**
   - Serialize companion state (is_recruited, affinity, quest_flags)
   - Serialize active party composition
   - Restore companion state on game load
   - Handle companion spawning on room entry

### Quest Flags System (Infrastructure Only)

- `quest_flags` struct on each companion instance for future expansion
- No specific quest implementations in Phase 1
- Foundation for future companion-specific questlines

## Out of Scope

### Future Phases (Not Phase 1)

1. **Other 11 Companions**
   - Additional companion characters beyond Canopy
   - Unique abilities and auras for each companion
   - Individual recruitment quests

2. **Quest System Integration**
   - Companion-specific questlines
   - Quest flag interactions
   - Story progression tied to companions

3. **Dialogue System**
   - Conversation trees with companions
   - Context-sensitive dialogue
   - Affinity-based dialogue variations

4. **Advanced Affinity Features**
   - Affinity gain through gameplay actions
   - Affinity-based ability unlocks
   - Companion progression system

5. **Party Management UI**
   - Visual party roster
   - Companion swapping interface
   - Affinity and stats display

6. **Companion Combat AI**
   - Active attacking behavior
   - Target selection
   - Damage dealing to enemies

7. **Multiple Active Companions**
   - Party size management (2-4 companions)
   - Formation positioning
   - Coordinated behavior

## Expected Deliverable

A fully functional companion system with Canopy as the first recruitable companion. The deliverable includes:

### Technical Components

- `obj_companion_parent` - Base object for all companions
- `obj_canopy` - First companion implementation
- Companion management functions in `@scripts/scripts.gml`
- Save/load integration for companion persistence

### Functional Requirements

1. **Recruitment**: Player can recruit Canopy through interaction
2. **Following**: Canopy intelligently follows the player
3. **Auras**: Protective (+1 DR) and Regeneration auras active when recruited
4. **Trigger**: Shield activates when player HP < 30%
5. **Persistence**: Canopy's recruitment status and affinity persist across sessions
6. **Room Transitions**: Canopy follows player between rooms
7. **Animation**: Canopy uses appropriate animation states (idle, walking)

### Testing Criteria

- Canopy can be recruited and joins party
- Following behavior maintains 24-32 pixel distance
- Auras apply correctly to player stats
- Shield trigger activates at low HP with proper cooldown
- Companion state persists through save/load cycle
- Companion transitions between rooms correctly
- No pathfinding issues or collision bugs
- Animation states match movement behavior

### Code Quality Standards

- Ruby-style naming conventions (snake_case)
- Instance-based data storage (not global variables except party tracking)
- Clean separation between parent and child companion objects
- Reusable aura and trigger systems for future companions
- Comprehensive inline documentation
- No performance issues with pathfinding calculations

## Spec Documentation

- Tasks: @.agent-os/specs/2025-09-30-companion-system/tasks.md
- Technical Specification: @.agent-os/specs/2025-09-30-companion-system/sub-specs/technical-spec.md
