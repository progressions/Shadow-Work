# Spec Requirements Document

> Spec: Enemy Collision Damage & Chain Boss Attacks
> Created: 2025-10-16
> Status: Planning

## Overview

Implement a configurable collision damage system for all enemies that allows them to damage the player on contact, add advanced chain manipulation attacks to chain bosses (throw auxiliary at player, spin attack with orbiting auxiliaries), and implement an auxiliary-based damage reduction system where the chain boss's defense scales with the number of living auxiliaries.

## User Stories

### Collision Damage as Tactical Element

As a player, I want enemies to be dangerous to touch so that I must maintain spacing and positioning during combat, not just avoid their attack animations.

When the player runs into or gets cornered by enemies, they take collision damage with proper damage type and DR calculations. Some enemies (heavy melee bruisers, charging enemies) deal high collision damage, while ranged enemies deal minimal or no collision damage. The player learns which enemies are safe to approach and which require careful distance management.

### Dynamic Chain Boss Combat

As a player, I want the chain boss to use its auxiliaries as weapons through throwing and spinning attacks, so that the fight feels unique and the chains serve a mechanical purpose beyond visual constraint.

During the chain boss fight, the boss can grab an auxiliary's chain and throw it at the player like a projectile, dealing damage on impact and creating a dangerous arc attack. The boss can also enter a spin attack mode where it rotates rapidly, causing all auxiliaries to orbit at maximum chain length and sweep the arena. These attacks force the player to dodge and reposition dynamically.

### Auxiliary Shield Mechanic

As a player, I want the chain boss to be harder to damage when it has more auxiliaries alive, so that I'm incentivized to prioritize killing auxiliaries first and the fight has strategic depth.

The chain boss gains damage reduction based on how many auxiliaries are alive. With 4 auxiliaries alive, the boss might have +8 DR (2 per auxiliary), making it tanky. As auxiliaries die, the boss becomes more vulnerable. This creates a risk/reward decision: focus the boss while taking more damage from auxiliaries, or eliminate auxiliaries first to make the boss fight easier.

## Spec Scope

1. **Enemy Collision Damage System** - Add configurable collision damage to `obj_enemy_parent` with optional enable/disable flag, damage amount, damage type, and cooldown between hits.
2. **Player Invulnerability Frames** - Implement brief invulnerability after taking collision damage to prevent instant death from continuous contact (0.5-1 second).
3. **Chain Boss Throw Attack** - Boss targets player, grabs auxiliary chain, and flings auxiliary in parabolic arc toward player's position, auxiliary damages on collision.
4. **Chain Boss Spin Attack** - Boss rotates in place for 2-3 seconds, all auxiliaries orbit at maximum chain length creating a dangerous sweep attack.
5. **Auxiliary-Based Damage Reduction** - Chain boss gains bonus DR based on number of living auxiliaries (configurable DR per auxiliary, e.g., 2 DR each).
6. **Auxiliary Attack States** - Add new states for auxiliaries: `thrown` (projectile mode), `spinning` (orbit mode), `returning` (moving back to normal position).

## Out of Scope

- Chain as a damaging hitbox (chains remain purely visual)
- Reel in / healing mechanics (future enhancement)
- Multiple throw/spin variations (single implementation for now)
- Player ability to grab/interact with chains
- Boss AI decision-making for when to use throw vs spin (simple cooldown-based for now)

## Expected Deliverable

1. All enemies can be configured with collision damage that applies proper damage types and DR calculations, with visible invulnerability feedback on player when hit.
2. Chain boss can execute throw attack: selects random auxiliary, throws it at player in arc, auxiliary returns to boss afterward.
3. Chain boss can execute spin attack: rotates for 2-3 seconds, auxiliaries orbit at max chain length damaging player on contact, then return to normal behavior.
4. Chain boss displays increased toughness when auxiliaries are alive (visible through damage numbers showing reduced damage), DR bonus decreases as auxiliaries die.

## Spec Documentation

- Tasks: @.agent-os/specs/2025-10-16-enemy-collision-chain-attacks/tasks.md
- Technical Specification: @.agent-os/specs/2025-10-16-enemy-collision-chain-attacks/sub-specs/technical-spec.md
