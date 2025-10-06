# Spec Requirements Document

> Spec: Party Controller Performance Optimization
> Created: 2025-10-05

## Overview

Optimize the enemy party controller's decision weight calculation system by implementing staggered updates to reduce per-frame computational load. Currently, all party members have their decision weights recalculated every single frame, causing performance issues with 10-12 active enemies (500-1000 operations per frame). This optimization will reduce the load by 90% while maintaining responsive AI behavior.

## User Stories

### Performance Improvement During Large Battles

As a player, I want smooth gameplay during multi-party encounters, so that I can enjoy combat without lag or frame drops.

When fighting 2 orc raiding parties (10 enemies total) plus a spawner creating additional enemies, the game currently experiences noticeable lag due to every party member recalculating decision weights every frame. After optimization, only 1-2 enemies update per frame in round-robin fashion, spreading the computational load evenly and eliminating performance issues.

### Maintaining Responsive AI Behavior

As a player, I want enemies to respond quickly to combat situations, so that battles feel dynamic and challenging.

Despite staggered updates, each enemy still receives fresh decision weight calculations every 5-10 frames (0.08-0.16 seconds), which is fast enough to feel immediate while being 90% more efficient than the current system.

## Spec Scope

1. **Staggered Decision Weight Updates** - Implement round-robin update system where only 1-2 party members update per frame instead of all members
2. **Empty Party Controller Cleanup** - Add automatic destruction of party controllers when all members are dead to prevent resource waste
3. **Update Index Tracking** - Add `decision_update_index` counter to track which party member should update next
4. **Performance Measurement** - Add optional debug output to verify performance improvement

## Out of Scope

- Event-driven updates (saved for future optimization if needed)
- Changes to the AI memory system
- Changes to pathfinding algorithms
- Modifications to formation calculation logic (only when it runs, not how it works)

## Expected Deliverable

1. Combat with 10-12 enemies runs smoothly without noticeable lag
2. Party controllers automatically clean themselves up when all members are killed
3. Enemy AI behavior remains responsive with no noticeable delay in reactions
