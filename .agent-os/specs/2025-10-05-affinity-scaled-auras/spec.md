# Spec Requirements Document

> Spec: Affinity-Scaled Companion Auras
> Created: 2025-10-05

## Overview

Implement dynamic scaling for all companion passive auras based on affinity level, where auras are less effective at low affinity and scale up to 3x effectiveness at maximum affinity (10.0). This creates meaningful progression in companion relationships and rewards players for investing in companion bonds.

## User Stories

### Companion Growth Reflects Relationship

As a player, I want my companion's passive benefits to grow stronger as our relationship deepens, so that I feel rewarded for building affinity and can tangibly see the impact of our bond.

When I recruit a companion at affinity 3.0, their auras provide reduced effectiveness (approximately 60% of current values). As I complete quests, make dialogue choices, and give gifts to increase affinity, their aura strength grows. By affinity 10.0, the companion's auras are 3x as powerful as the current baseline, making them significantly more valuable in combat and exploration.

### Strategic Companion Selection

As a player, I want to prioritize which companions to invest affinity in, so that I can make strategic choices about party composition based on my playstyle.

Different companions offer different auras (Canopy's regeneration vs Hola's ranged DR). By understanding how these scale with affinity, I can choose to focus on deepening bonds with companions whose auras best support my build, creating replayability and strategic depth.

## Spec Scope

1. **Affinity-Based Scaling Formula** - Implement a diminishing returns formula that scales aura effectiveness from ~0.6x at affinity 3.0 to 3.0x at affinity 10.0.
2. **Default Affinity Change** - Update companion default affinity from 1.0 to 3.0 to match the new scaling system.
3. **Aura Value Calculation** - Modify all companion aura application functions to multiply base values by the affinity scaling multiplier.
4. **Regeneration Aura Scaling** - Scale Canopy's regeneration aura (and any other healing auras) based on affinity.
5. **Damage Reduction Aura Scaling** - Scale protective/DR auras (Canopy, Hola, Nellis, etc.) based on affinity with appropriate caps.

## Out of Scope

- Visual effects or UI indicators for aura strength
- Tooltip changes or HUD displays
- New aura types or companion abilities
- Affinity gain/loss mechanics (already implemented)
- Companion trigger scaling (triggers already use affinity-based unlocks)

## Expected Deliverable

1. At affinity 3.0, companion auras provide approximately 60% effectiveness compared to current fixed values.
2. At affinity 10.0, companion auras provide 300% effectiveness (3x) compared to current fixed values.
3. The scaling curve uses diminishing returns so early affinity gains feel impactful.
4. All existing companion auras (protective, regeneration, wind_ward, etc.) scale correctly with affinity.
5. Debug command to verify scaling calculations at different affinity levels.
