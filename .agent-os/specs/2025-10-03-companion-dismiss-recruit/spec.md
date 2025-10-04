# Spec Requirements Document

> Spec: Companion Dismiss and Recruit System
> Created: 2025-10-03
> Status: Planning

## Overview

Implement a companion dismissal and recruitment system that allows players to dismiss companions from their party, positioning them in the world where they can be recruited again later. This system includes full serialization of companion state (position, quest flags, dialogue flags, party status) for save/load functionality.

## User Stories

### Dismissing a Companion

As a player, I want to dismiss a companion from my party, so that I can explore solo or manage party composition.

When the player chooses to dismiss a companion through dialogue, the companion stops following the player, is removed from the active party, and remains positioned at their current world coordinates. The companion transitions to a "dismissed" state where they can be found and recruited again.

### Recruiting a Dismissed Companion

As a player, I want to recruit a previously dismissed companion, so that I can have them rejoin my party.

When the player speaks to a dismissed companion in the world, a "Join me" dialogue option appears. Selecting this option recruits the companion back into the party, and they resume following the player with all their previous quest progress, dialogue flags, and state intact.

### Persistent Companion State

As a player, I want my companions' states to persist across save/load, so that dismissed companions remain where I left them with all their progress intact.

When the player saves the game, all companion data (position, quest flags, dialogue flags, party membership status) is serialized. Upon loading, dismissed companions spawn at their saved positions with all flags and state restored exactly as they were.

## Spec Scope

1. **Companion Dismissal** - Add dialogue option and function to dismiss companions, positioning them at current coordinates and removing from party
2. **Companion Recruitment** - Add "Join me" dialogue option for dismissed companions to rejoin the party
3. **Companion State Serialization** - Serialize all companion data (position, quest/dialogue flags, party status) for save/load
4. **Companion State Deserialization** - Restore companion state from save data, spawning dismissed companions at saved positions
5. **Party Status Management** - Track and update companion party membership status (active/dismissed)

## Out of Scope

- Multiple party member slots (assumes single companion system)
- Companion dismissal limits or cooldowns
- Special dismissal locations or safe zones
- Companion AI behavior while dismissed (they remain stationary)
- Visual indicators for dismissed companion locations on map

## Expected Deliverable

1. Players can dismiss companions through dialogue, and companions remain in the world at their dismissal location
2. Players can recruit dismissed companions by speaking to them and selecting "Join me"
3. Companion state (position, flags, party status) persists correctly across save/load cycles

## Spec Documentation

- Tasks: @.agent-os/specs/2025-10-03-companion-dismiss-recruit/tasks.md
- Technical Specification: @.agent-os/specs/2025-10-03-companion-dismiss-recruit/sub-specs/technical-spec.md
