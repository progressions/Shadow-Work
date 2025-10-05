# Spec Requirements Document

> Spec: Enemy Approach Variation
> Created: 2025-10-05
> Status: Planning

## Overview

Implement varied enemy approach patterns to make combat more dynamic and challenging by adding randomized flanking behavior. Enemies will choose perpendicular approach angles (above/below or left/right relative to their direct path) when within close range of the player, preventing predictable straight-line attacks.

## User Stories

### Unpredictable Combat Encounters

As a player engaged in combat with spawned enemies, I want enemies to approach from varying angles, so that I cannot simply spam attacks in one direction and must adapt to changing threats.

When enemies get within close range of the player (e.g., 100-150 pixels), they have a chance to select an offset approach angle perpendicular to their direct path. An enemy approaching from the right might circle to attack from above or below, while an enemy approaching from above might swing around to attack from the left or right. This creates dynamic positioning that requires the player to reposition and time attacks more carefully.

### Tactical Combat Challenge

As a player facing multiple enemies from a spawner, I want their attack patterns to feel intelligent and varied, so that combat remains challenging and engaging rather than repetitive.

The system applies a random chance (e.g., 30-50%) for enemies to choose flanking approaches when they enter engagement range. This randomization means some enemies will attack head-on while others will flank, creating varied combat scenarios even with the same enemy types. The player must stay mobile and aware of surroundings rather than camping in one spot.

### Balanced Difficulty Scaling

As a player, I want the enemy approach variation to feel fair and readable, so that I can learn patterns and improve my combat skills without feeling cheated by erratic AI.

Enemies commit to their chosen approach angle once selected and don't constantly recalculate, making their movement predictable once initiated. The flanking offset is significant enough to matter (perpendicular angles) but not so extreme that enemies circle endlessly. Close-range triggers ensure enemies don't waste time flanking from far away where it wouldn't impact combat.

## Spec Scope

1. **Approach Variation Detection** - Detect when enemies enter close range (100-150 pixels) of player to trigger approach angle selection
2. **Flanking Angle Calculation** - Calculate perpendicular approach angles (±90 degrees from direct path) when enemies are within trigger range
3. **Random Flanking Selection** - Apply configurable chance (30-50%) for enemies to select flanking approach vs direct approach
4. **Target Position Offset** - Offset enemy target_x/target_y by perpendicular angle at fixed distance to create flanking path
5. **Approach Commitment** - Enemies commit to chosen approach angle until reaching destination or losing aggro

## Out of Scope

- Advanced tactical AI (formations, coordinated attacks)
- Pathfinding around obstacles during flanking (use existing pathfinding)
- Different flanking behavior per enemy type (all enemies use same system)
- Player detection of flanking intent (visual indicators, telegraphing)
- Flanking from extreme distances (only triggers at close range)

## Expected Deliverable

1. Enemies within 100-150 pixels of player have 30-50% chance to approach from perpendicular angles instead of straight-on
2. Flanking enemies visibly circle to attack from above/below (when approaching horizontally) or left/right (when approaching vertically)
3. Combat against spawned enemies feels varied and requires player repositioning, preventing simple attack-spam tactics

## Spec Documentation

- Tasks: @.agent-os/specs/2025-10-05-enemy-approach-variation/tasks.md
- Technical Specification: @.agent-os/specs/2025-10-05-enemy-approach-variation/sub-specs/technical-spec.md
