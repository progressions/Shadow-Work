# Spec Requirements Document

> Spec: Breakable Object Base  
> Created: 2025-10-08  
> Status: Planning

## Overview

Build an inheritable breakable object framework that lets prop instances (grass tufts, pots, etc.) take melee damage, play a short break animation using the new `breakable_grass.png` export, emit particles, and remove themselves. The system should plug into existing melee attack hitboxes (`obj_attack`), ignore projectile collisions (`obj_arrow`), and give designers a straightforward way to configure per-variant durability and effects.

## User Stories

### Clearing Overgrowth

As a player, I want tall grass to shred when I swing my weapon, so the world feels reactive and I can reveal hidden tiles. When my melee hitbox overlaps the grass, it flashes, cracks apart, sprays leafy particles, and disappears without obstructing movement.

### Reusable Breakables

As a level designer, I want to drop different breakable props into rooms with minimal scripting, so I can mix grass, pottery, and other destructibles. I assign their sprite, durability, and particle palette while inheriting shared hit handling from `obj_breakable`.

### Combat Feedback Polish

As a VFX artist, I want consistent break burst timing hooked to the “breaking” frames from the new sprite sheet, so particles spawn right as the prop shatters and don’t trigger for projectiles.

## Spec Scope

1. **Parent Object Setup** – Implement `obj_breakable` (child of `obj_persistent_parent`) with Create, Step, and Collision(`obj_attack`) events that track HP, state (`idle`, `breaking`), animation control, and melee-only damage handling.
2. **Animation & Sprite Integration** – Loop frames 0‑3 (“unbroken”) while idle, then play frames 4‑7 (“breaking”) once on hit before destroying the instance.
3. **Particle Burst Hook** – Trigger a scripted particle burst (leaf/debris palette supplied by child objects) when the breaking animation starts or finishes.
4. **Child Configuration** – Set up `obj_breakable_grass` as the reference child: assign the new sprite, durability (1 hit), particle color struct, and optional sway offset timing.
5. **Persistence Hooks** – Ensure breakables serialize via `obj_persistent_parent` so destroyed props stay gone after room reloads (store broken flag, skip recreation).
6. **Design Documentation** – Document how designers create new breakable variants (properties, particle config, HP overrides) in project docs or object comments.

## Out of Scope

- Loot drops, inventory hooks, or score rewards tied to breakables.
- Blocking collision masks or navmesh updates (props stay non-solid before/after breaking).
- Projectile or environmental damage sources (future extension).
- Multi-hit combo reactions (juggle, knockback) beyond single-state break.

## Expected Deliverable

1. Melee swings (`obj_attack`) break grass props in playtest rooms; arrows pass through without triggering damage.
2. Breakable props loop their idle animation, react instantly on hit, play the full breaking sequence, spawn particles, and self-delete at animation end.
3. Destroyed breakables remain gone after reloading a room or save.
4. Designers can clone `obj_breakable_grass`, tweak a few variables, and get new theming without editing shared scripts.
5. Particle hooks accept palette overrides so future variants (pottery, crystals) can emit different debris.

## Spec Documentation

- Spec Summary: @.agent-os/specs/2025-10-08-breakable-object-base/spec-lite.md
- Technical Specification: @.agent-os/specs/2025-10-08-breakable-object-base/sub-specs/technical-spec.md
