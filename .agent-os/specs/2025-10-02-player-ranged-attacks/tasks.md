# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-10-02-player-ranged-attacks/spec.md

> Created: 2025-10-02
> Status: Ready for Implementation

## Tasks

- [ ] 1. Repurpose obj_arrow as projectile object
  - [ ] 1.1 Update obj_arrow Create_0.gml to set projectile properties (creator, damage, speed=6, direction, image_angle)
  - [ ] 1.2 Create obj_arrow Step_0.gml event with collision detection
  - [ ] 1.3 Implement Tiles_Col tilemap collision with destroy and sound
  - [ ] 1.4 Implement obj_enemy_parent collision with damage application and sounds
  - [ ] 1.5 Implement out-of-bounds detection and destroy
  - [ ] 1.6 Verify or create spr_arrow sprite for projectile (16x4 pixels, horizontal orientation)
  - [ ] 1.7 Test arrow spawning, movement, and collision behavior

- [ ] 2. Modify player attack system for ranged weapons
  - [ ] 2.1 Update player_handle_attack_input() to detect ranged weapons (requires_ammo property)
  - [ ] 2.2 Add ammo check using has_ammo("arrows") before firing
  - [ ] 2.3 Implement arrow spawning logic with direction calculation from facing_dir
  - [ ] 2.4 Add consume_ammo("arrows", 1) after arrow spawn
  - [ ] 2.5 Add bow firing sound effect (snd_bow_fire placeholder)
  - [ ] 2.6 Ensure melee attack logic remains unchanged for non-ranged weapons
  - [ ] 2.7 Test ranged vs melee weapon switching and attack behavior

- [ ] 3. Add sound effects system for ranged combat
  - [ ] 3.1 Create snd_bow_fire placeholder sound asset
  - [ ] 3.2 Create snd_arrow_hit_enemy placeholder sound asset
  - [ ] 3.3 Create snd_arrow_hit_wall placeholder sound asset
  - [ ] 3.4 Integrate play_sfx() calls in obj_arrow collision events
  - [ ] 3.5 Test sound playback timing for arrow fire, enemy hit, and wall hit

- [ ] 4. Final integration and testing
  - [ ] 4.1 Test with all bow types (wooden_bow, longbow, crossbow, heavy_crossbow)
  - [ ] 4.2 Verify arrow consumption and "no ammo" behavior
  - [ ] 4.3 Test attack cooldown for different bow attack speeds
  - [ ] 4.4 Test player movement during and after arrow firing
  - [ ] 4.5 Test edge cases (close range, wall adjacent, room bounds)
  - [ ] 4.6 Verify damage application matches bow weapon stats
  - [ ] 4.7 Document any issues or future enhancements needed
