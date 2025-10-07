# Spec Requirements Document

> Spec: Yorna Triggers Completion
> Created: 2025-10-07

## Overview

Complete Yorna's combat trigger system to enable all three of her offensive abilities (On-Hit Strike, Expose Weakness, and Execution Window) and update the debug affinity system to work for all recruited companions instead of only Canopy.

## User Stories

### Combat Enhancement with Yorna

As a player with Yorna recruited, I want her triggers to activate during combat, so that I can experience her full offensive support capabilities and see bonus damage, armor debuffs, and execution bonuses in action.

When I land hits on enemies with Yorna following me, I should see her On-Hit Strike trigger add bonus damage with visual feedback. At higher affinity levels (8+ and 10), I should see Expose Weakness armor debuffs on enemies and Execution Window damage bonuses when I perform dash attacks or critical hits.

### Companion Affinity Testing

As a developer testing companion mechanics, I want the K key to increase affinity for all recruited companions, so that I can efficiently test affinity-gated triggers for any companion without targeting only Canopy.

When I press K with any companions recruited, all of them should gain +1 affinity with visual feedback showing the new affinity levels.

## Spec Scope

1. **On-Hit Strike Trigger** - Implement Yorna's base trigger that adds +2 bonus damage every time the player lands a hit (0.5s cooldown)
2. **Expose Weakness Trigger** - Implement affinity 8+ trigger that reduces nearby enemy armor by 2 for 3 seconds when player dashes or crits (5s cooldown)
3. **Execution Window Trigger** - Implement affinity 10 trigger that gives Yorna 2x damage and 3 armor pierce for 2 seconds when player dashes or crits (10s cooldown)
4. **Universal Affinity Debug** - Update K key debug command to increase affinity for all recruited companions instead of only Canopy
5. **Companion Notification System** - Create notification functions for player hit events, dash events, and crit events to trigger companion abilities

## Out of Scope

- Yorna actually attacking enemies (she only provides buffs/debuffs)
- Visual effects for triggers beyond floating text and existing systems
- UI indicators for active trigger buffs/debuffs
- Balance adjustments to trigger values
- Other companions' triggers (Hola, Oyin, etc.)

## Expected Deliverable

1. Yorna's On-Hit Strike trigger activates when player hits enemies, adding visible bonus damage with cooldown management
2. Yorna's Expose Weakness trigger activates at affinity 8+ on dash/crit, reducing enemy armor with visual feedback
3. Yorna's Execution Window trigger activates at affinity 10 on dash/crit, providing damage bonuses
4. K key increases affinity for all recruited companions with debug output showing all affected companions
5. All triggers respect their cooldowns and affinity unlock requirements
