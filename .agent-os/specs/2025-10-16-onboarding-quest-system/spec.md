# Spec Requirements Document

> Spec: Onboarding Quest System
> Created: 2025-10-16
> Status: Planning

## Overview

A non-intrusive HUD-based onboarding system that guides new players through core game mechanics using a sequence of 6-8 tutorial quests. Each quest displays a single-sentence objective near the top of the screen and auto-resolves when the player completes the specified action, immediately triggering the next quest in sequence.

## User Stories

### New Player First-Time Experience
As a new player, I want to learn how to interact with the game's core systems through guided quests, so that I can understand the controls and mechanics without pausing the game or feeling lost.

Detailed workflow: Player starts game → First quest displays "It's dark! Press T to light a torch." → Player presses T → Quest auto-resolves → Next quest displays instructing them to find a chest → Player finds and opens chest → Quest resolves and continues sequence through combat, inventory, companions, and equipment mechanics.

### Persistent Tutorial Progress
As a player who saves mid-tutorial, I want my quest progress to be saved and restored, so that I don't lose progress or have to repeat completed onboarding quests.

Detailed workflow: Player completes 3 quests, saves game → Loads save → Previously completed quests remain completed, next uncompleted quest displays → Player can continue from where they left off.

## Spec Scope

1. **Onboarding Quest Sequence Definition** - Define 6-8 sequential tutorial quests with objectives, triggers, and display text stored in a centralized system (ideally in Yarn dialogue files).
2. **HUD Overlay Display System** - Render current quest text near the top of the screen in sentence case without pausing gameplay.
3. **Auto-Trigger Quest Resolution** - Automatically resolve quests when their trigger conditions are met (key press, NPC interaction, inventory action, etc.).
4. **Quest Marker System** - Display optional sprite-based animated markers at quest locations, including off-screen arrow indicators.
5. **Quest Persistence** - Store and restore onboarding quest completion flags through save/load system.
6. **Progressive Quest Advancement** - Automatically display the next quest after previous quest resolves, ending tutorial when all quests complete.
7. **Quest Notification Sounds** - Play "quest available" sound when new quest appears and "quest resolved" sound when quest completes.
8. **Quest XP Rewards** - Award small XP bonus to player upon quest completion, configurable per quest.

## Out of Scope

- Complex branching dialogue sequences (simple text-based objectives only)
- Voice acting or narration for quest prompts
- Quest reward items (only XP bonuses)
- Replayable tutorial mode (one-time sequence per game start)
- Mobile/console-specific control scheme tutorials

## Expected Deliverable

1. Onboarding quest system is integrated with existing quest infrastructure, storing flags in global.quest_flags for persistence
2. HUD overlay renders current quest objective text centered near top of screen and updates when quests auto-resolve
3. All 6-8 tutorial quests can be completed sequentially, with next quest auto-triggering, XP awarded per quest, and no quests replay after completion
4. Quest markers display as animated sprites at quest locations with optional off-screen arrow indicators
5. Sound effects play on quest available and quest resolved events

## Spec Documentation

- Tasks: @.agent-os/specs/2025-10-16-onboarding-quest-system/tasks.md
- Technical Specification: @.agent-os/specs/2025-10-16-onboarding-quest-system/sub-specs/technical-spec.md
