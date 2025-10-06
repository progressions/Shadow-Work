# Spec Requirements Document

> Spec: Dual-Mode Enemy Combat
> Created: 2025-10-06

## Overview

Implement context-based attack mode switching for enemies, allowing them to intelligently choose between ranged and melee attacks based on player distance relative to their ideal_range threshold. This feature will enable more dynamic enemy AI behaviors, allowing enemies to engage at range when the player is distant and switch to melee when the player closes in, with tactical retreat mechanics for ranged-preferring enemies.

## User Stories

### Dynamic Combat Engagement

As a player, I want enemies to adapt their attack strategy based on my distance, so that combat encounters feel more tactical and unpredictable.

When I approach a dual-mode enemy from afar, they will use ranged attacks (arrows, javelins, fireballs) to harass me. As I close the distance and cross their ideal_range threshold, they will switch to melee attacks (sword strikes, claw swipes). If they prefer ranged combat, they will attempt to retreat and reposition to maintain their ideal fighting distance, creating a dynamic cat-and-mouse engagement.

### Formation-Based Tactics

As a player, I want enemy parties to coordinate their attack modes based on formation roles, so that group battles feel strategically designed.

When engaging an enemy party, ranged-specialized enemies in the back line maintain distance and provide covering fire, while melee-focused enemies in the front line charge and engage in close combat. Dual-mode enemies adapt their role based on their position in the formation - those in rear positions use ranged attacks, while those in forward positions switch to melee when I approach.

### Varied Enemy Archetypes

As a player, I want each enemy type to have unique combat preferences and behaviors, so that different encounters require different tactics.

A sandsnake warrior might prefer ranged javelin throws but can defend itself in melee when cornered. An orc raider might prefer brutal melee combat but carry throwing axes for distant targets. A greenwood bandit archer maintains distance with arrows but draws a dagger for desperate close-quarters defense. Each enemy's preferred mode creates distinct gameplay patterns.

## Spec Scope

1. **Distance-Based Mode Selection** - Enemies compare player distance to ideal_range to choose between ranged attacks (distance > ideal_range) and melee attacks (distance < ideal_range), with intelligent switching during combat.

2. **Retreat Mechanics for Ranged-Preferring Enemies** - Enemies configured with ranged preference will attempt tactical repositioning when player breaches their ideal_range threshold, maintaining optimal combat distance.

3. **Dual-Mode Configuration Properties** - Add configurable properties to obj_enemy_parent for enabling dual-mode behavior (enable_dual_mode flag), setting attack mode preferences (preferred_attack_mode), and defining melee-specific range thresholds (melee_range_threshold).

4. **Animation Support for Both Attack Types** - Extend enemy animation system to support separate melee attack animations (attack_down, attack_right, etc.) and ranged attack animations (ranged_attack_down, ranged_attack_right, etc.) with appropriate fallback handling.

5. **Party Formation Attack Mode Influence** - Integrate dual-mode decision logic with enemy party formation system so rear formation positions bias toward ranged attacks and front positions bias toward melee attacks.

## Out of Scope

- Weapon-switching animations or visual equipment changes (enemies use same sprite with different attack frames)
- Player or companion dual-mode attacks (this is enemy-only behavior)
- Complex AI tactics like cover-seeking, flanking maneuvers, or advanced kiting patterns beyond simple retreat
- Ammunition systems or limited ranged attack resources
- Mid-attack canceling or mode-switching during attack animations (commitment to current attack state)

## Expected Deliverable

1. Existing enemies (e.g., obj_sandsnake, obj_orc, obj_greenwood_bandit) can be configured with `enable_dual_mode = true` and will intelligently switch between ranged and melee attacks based on player distance relative to their ideal_range.

2. Enemy party formations influence dual-mode attack selection, with rear-positioned enemies favoring ranged attacks and front-positioned enemies favoring melee attacks when engaging the player.

3. Ranged-preferring dual-mode enemies (configured via `preferred_attack_mode = "ranged"`) will retreat to maintain ideal_range when player gets too close, creating dynamic kiting behavior during combat encounters.
