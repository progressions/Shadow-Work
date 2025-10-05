# Spec Requirements Document

> Spec: Companion Testing Utility
> Created: 2025-10-05
> Status: Planning

## Overview

Create a quick testing utility function that allows developers to instantly recruit all three companions (Hola, Yorna, and Canopy) via a simple function call in a room start event. This utility should bypass the normal recruitment flow, VN intro sequences, and set all necessary flags to simulate that the companions have already been met and recruited, enabling rapid testing of companion-dependent features.

## User Stories

**Story 1: Quick Party Setup for Combat Testing**
As a developer testing companion combat mechanics, I want to instantly recruit all companions at the start of a test room so that I can immediately test party-based combat features without playing through the normal recruitment sequence.

Workflow:
1. Developer opens a test room in GameMaker IDE
2. Developer adds `quick_recruit_all_companions()` to the room's Room Start event
3. Developer runs the game (F5)
4. All three companions are immediately in the party with proper flags set
5. Developer can test combat, formations, and party mechanics immediately

**Story 2: Quest Testing with Full Party**
As a developer testing quests that require companions, I want to skip the VN intro sequences and recruitment process so that I can focus on testing quest mechanics without repetitive setup.

Workflow:
1. Developer creates a test room for quest testing
2. Developer calls `quick_recruit_all_companions()` in room start
3. All companions are recruited with VN intros marked as seen
4. Developer can immediately test companion-specific quest objectives and dialogue

**Story 3: Affinity System Testing**
As a developer testing the companion affinity system, I want companions to be recruited with configurable starting affinity values so that I can test affinity-based features at various relationship levels.

Workflow:
1. Developer calls `quick_recruit_companions_with_affinity(50)` in room start
2. All companions are recruited with 50 affinity
3. Developer can test affinity-based dialogue, bonuses, and progression

## Spec Scope

1. Create a `quick_recruit_all_companions()` function that recruits Hola, Yorna, and Canopy in a single call
2. Set all recruitment flags (`is_recruited = true`) for each companion
3. Mark VN intro sequences as completed (set appropriate `vn_intro_seen` or similar flags)
4. Initialize default affinity values for each recruited companion
5. Provide optional parameter support for custom affinity values via `quick_recruit_companions_with_affinity(affinity_value)`

## Out of Scope

- Automated testing framework or unit tests
- UI/debug menu for companion recruitment (command-line or visual interface)
- Ability to selectively recruit individual companions (only full party recruitment)
- Companion positioning or formation setup (uses existing system defaults)
- Save/load integration for testing saves
- Reverting or un-recruiting companions via utility

## Expected Deliverable

1. A working `quick_recruit_all_companions()` function that can be called from any room start event and results in Hola, Yorna, and Canopy being fully recruited with VN intros skipped
2. All companion flags and state properly initialized so companions behave identically to normally-recruited companions
3. Documentation in code comments explaining usage and what flags are set

## Spec Documentation

- Tasks: @.agent-os/specs/2025-10-05-companion-testing-utility/tasks.md
- Technical Specification: @.agent-os/specs/2025-10-05-companion-testing-utility/sub-specs/technical-spec.md
