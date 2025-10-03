# Spec Requirements Document

> Spec: Quest System
> Created: 2025-10-03
> Status: Planning

## Overview

Implement a comprehensive quest system that allows NPCs (primarily companions) to give quests with multiple objective types, quest chains, progress tracking, and rewards including affinity increases and items. The system integrates with the existing Yarn dialogue system and companion affinity mechanics.

## User Stories

### Companion Quest Acceptance

As a player, I want to accept quests from companions through dialogue choices in the Yarn VN interface, so that I can help them with their personal storylines and build stronger relationships.

The player interacts with a companion using the existing talk menu (C hotkey), which opens the Yarn dialogue interface. When the companion offers a quest through dialogue ("Help me find my sister"), the player sees response options like "Yes, let's go" or "Not right now". Accepting the quest adds it to the player's active quest list, triggers an acceptance visual/audio effect, and begins tracking progress toward the quest objectives.

### Multi-Type Quest Objectives

As a player, I want to complete quests with varied objectives like killing specific enemies, collecting items, or reaching locations, so that quests feel diverse and engaging.

Quest objectives can include: killing a specific number of enemies (either by type like "greenwood_bandit" or by trait tag like "fireborne"), collecting quest items dropped by enemies, delivering quest items to NPCs or locations, reaching specific map markers, or spawning and defeating special quest enemies. Progress updates trigger visual/audio feedback, and the quest completes automatically when all objectives are met (unless the quest requires manual turn-in at an NPC).

### Quest Chain Progression

As a player, I want completing one quest to unlock the next quest in a companion's storyline, so that I experience a cohesive narrative arc with meaningful progression.

When a quest is marked as part of a chain and is completed, the next quest in the chain becomes immediately available. The companion's Yarn dialogue updates to reflect the new quest state, allowing the player to continue the story without additional triggers. Quest rewards (affinity and/or items) are granted upon completion, and quest chains can have multiple stages that build on each other.

## Spec Scope

1. **Quest Database and Definition System** - Create a global quest database in a dedicated script file with quest properties including ID, name, description reference, quest giver, objective types/parameters, rewards, prerequisites, and completion flags.

2. **Quest Objective Types** - Implement kill objectives (specific enemy types or trait tags), collection objectives (quest items dropped by enemies), delivery objectives (bring item to NPC/location), location objectives (reach and collide with quest marker), and spawn-and-kill objectives (special quest enemies).

3. **Quest Item System** - Add `ItemType.quest_item` to the existing item database with special behavior preventing dropping/discarding, and integration with delivery objectives.

4. **Quest Progress Tracking** - Store active quest data in `obj_player.active_quests` with progress counters for each objective, automatic completion detection when objectives are met, and optional manual turn-in requirements.

5. **Quest Rewards and Feedback** - Implement affinity reward increases for companion relationships, item rewards added to player inventory, quest chain unlocking, and distinct visual/audio effects for quest acceptance, progress updates, and completion.

## Out of Scope

- Quest abandonment or cancellation mechanics
- Quest failure conditions
- Timed or time-limited quests
- Repeatable or daily quest systems
- Quest journal or quest log UI (planned for future update)
- Quest sharing or multiplayer quest features

## Expected Deliverable

1. Player can accept a quest from a companion through Yarn dialogue, see quest acceptance feedback, and have the quest tracked in their active quests with objectives like "Kill 5 Greenwood Bandits" or "Collect 3 Wolf Pelts".

2. Quest objectives update automatically as the player progresses (killing enemies, collecting items, reaching locations), with visual/audio feedback on progress updates and completion, and rewards (affinity and/or items) are granted upon quest completion.

3. Completing the first quest in a chain immediately unlocks the next quest, allowing the companion's Yarn dialogue to offer the follow-up quest without additional setup or flags beyond the quest system.

## Spec Documentation

- Tasks: @.agent-os/specs/2025-10-03-quest-system/tasks.md
- Technical Specification: @.agent-os/specs/2025-10-03-quest-system/sub-specs/technical-spec.md
