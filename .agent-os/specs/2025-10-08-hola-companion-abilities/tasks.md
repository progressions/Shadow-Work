# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-10-08-hola-companion-abilities/spec.md

> Created: 2025-10-08
> Status: Ready for Implementation

## Tasks

- [ ] 1. Create Centralized Aura Getter Functions
  - [ ] 1.1 Add `get_companion_enemy_slow(enemy_x, enemy_y)` to `scr_companion_system.gml`
  - [ ] 1.2 Add `get_companion_dash_cd_reduction()` to `scr_companion_system.gml`
  - [ ] 1.3 Add `get_companion_deflection_bonus(companion_id)` to `scr_companion_system.gml`
  - [ ] 1.4 Verify all functions follow existing pattern (loop companions, check auras, apply affinity scaling automatically)
  - [ ] 1.5 Test functions return correct scaled values at affinity 3.0, 5.0, 7.0, 10.0
  - [ ] 1.6 Confirm functions handle cases when no companions are active (return defaults)

- [ ] 2. Implement Slowing Aura (Enemy Speed Reduction)
  - [ ] 2.1 Find enemy movement speed calculation in enemy state functions
  - [ ] 2.2 Call `get_companion_enemy_slow(x, y)` to get speed multiplier
  - [ ] 2.3 Apply multiplier to final movement speed calculation
  - [ ] 2.4 Verify enemies within 120px radius move slower (visible in gameplay)
  - [ ] 2.5 Test at affinity 3.0 (30% slow), 5.0 (50% slow), 10.0 (150% capped)
  - [ ] 2.6 Confirm aura deactivates when Hola dismissed from party

- [ ] 3. Implement Slipstream Passive Aura (Dash Cooldown Reduction)
  - [ ] 3.1 Modify `player_handle_dash_cooldown.gml`
  - [ ] 3.2 Replace manual aura checking with `get_companion_dash_cd_reduction()` call
  - [ ] 3.3 Ensure function result includes both passive aura AND active trigger
  - [ ] 3.4 Test dash cooldown recovery rate without Hola (baseline)
  - [ ] 3.5 Verify 20% faster recovery at affinity 5.0
  - [ ] 3.6 Test scaling at affinity 3.0 (12%) and 10.0 (60%)
  - [ ] 3.7 Confirm stacking with active trigger (20% + 35% = 55% total)

- [ ] 4. Implement Maelstrom Deflection Bonus
  - [ ] 4.1 Modify `obj_enemy_arrow/Step_0.gml` wind deflection section (lines 1-38)
  - [ ] 4.2 Call `get_companion_deflection_bonus("hola")` to get bonus deflection
  - [ ] 4.3 Add bonus to base deflection chance before roll
  - [ ] 4.4 Trigger Maelstrom with 4+ enemies at affinity 10
  - [ ] 4.5 Verify increased projectile deflection during 4-second window
  - [ ] 4.6 Confirm timer countdown and deactivation after 240 frames
  - [ ] 4.7 Test deflection rate: base 25% → 50% with Maelstrom active

- [ ] 5. Add Debug Output for Hola Auras
  - [ ] 5.1 Extend O key debug output in `obj_player/Step_0.gml` (lines 260-279)
  - [ ] 5.2 Add Hola-specific aura status display when recruited
  - [ ] 5.3 Show affinity value and aura multiplier
  - [ ] 5.4 Display slowing aura percentage (base → scaled)
  - [ ] 5.5 Display slipstream passive percentage (base → scaled)
  - [ ] 5.6 Show maelstrom deflect timer when active
  - [ ] 5.7 Test debug output at different affinity levels (3.0, 5.0, 7.0, 10.0)

- [ ] 6. Comprehensive Testing & Verification
  - [ ] 6.1 Recruit Hola and verify all 7 features work (4 existing + 3 new)
  - [ ] 6.2 Test slowing aura visibility in combat scenarios
  - [ ] 6.3 Measure dash cooldown improvement with passive aura
  - [ ] 6.4 Verify Maelstrom deflection bonus triggers correctly
  - [ ] 6.5 Confirm affinity scaling works for all three new features
  - [ ] 6.6 Test feature interaction (slowing + deflection + passive dash boost)
  - [ ] 6.7 Verify performance with multiple enemies in slowing aura radius
  - [ ] 6.8 Verify centralized functions work correctly (no manual scaling anywhere)
  - [ ] 6.9 Document final status: 7/7 Hola features functional
