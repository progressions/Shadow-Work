# Spec Requirements Document

> Spec: Shield Block System
> Created: 2025-10-16
> Status: Planning

## Overview

Implement a defensive shield blocking mechanic that allows players to press a key to raise their equipped shield and reduce or negate incoming projectile and melee damage. Perfect block timing destroys projectiles entirely, while normal blocks allow hazard projectiles to spawn on landing.

## User Stories

### Blocking Incoming Projectiles

As a player, I want to raise my shield to block incoming arrows and hazard projectiles, so that I can mitigate damage through timing and positioning.

The player presses and holds the shield block key (to be mapped). If a shield is equipped, the player enters shield block state: facing direction locks (like ranged focus), animation plays to raise shield, and they can move in this focused direction. When released, shield lowers and enters cooldown. Normal blocks reduce damage to chip values, perfect blocks (tight window) destroy projectiles entirely without spawning hazards.

### Perfect Block Timing Reward

As a skilled player, I want a brief perfect block window to reward responsive timing, so that mastery feels rewarding.

When the shield raise animation completes, there's a tight window (framerate TBD) where blocking becomes "perfect." During perfect block, projectiles are destroyed on contact without creating hazards. A visual shield sprite flash indicates when the perfect block window is active. Perfect blocks have a shorter cooldown than normal blocks as reward.

### Shield Variety and Balance

As a player with different equipped shields, I want shield properties to affect blocking, so that equipment choice matters.

Shields with different sizes affect: block arc width (bigger shield = wider arc), and cooldown duration (bigger shield = longer cooldown). All shields require the same button hold to activate blocking.

## Spec Scope

1. **Shield Block State** - New PlayerState that locks facing direction like ranged focus, plays shield raise animation, and allows movement in focused direction only.

2. **Block Detection & Damage Reduction** - Detect collisions with incoming projectiles (arrows, hazard projectiles) during shield block and apply chip damage using existing DR calculation system.

3. **Perfect Block Window** - Tight reactive frame window after shield animation completes that destroys projectiles entirely without hazard spawn, with visual feedback.

4. **Cooldown System** - Track cooldown after shield release, prevent re-blocking during cooldown, shorter cooldown for perfect blocks.

5. **Shield Properties** - Configure block arc width and cooldown duration per shield based on size/tier.

6. **Animation System** - Support new player shield animations (raise and hold), different animation frames for each facing direction.

## Out of Scope

- Melee attack deflection (saving for future)
- Shield durability or damage tracking
- Stamina system (not in current game)
- Shield bash or counter-attack mechanics
- Knockback immunity during block (knockback still applies)

## Expected Deliverable

1. Player can equip a shield and press block key to raise it, reducing incoming damage to chip values and preventing hazard spawning on perfect block.
2. Perfect block window clearly telegraphed with sprite flash, destroying projectiles entirely with shorter cooldown reward.
3. Shield properties (block arc, cooldown) are configurable per shield type, affecting blocking effectiveness.

## Spec Documentation

- Tasks: @.agent-os/specs/2025-10-16-shield-block-system/tasks.md
- Technical Specification: @.agent-os/specs/2025-10-16-shield-block-system/sub-specs/technical-spec.md
