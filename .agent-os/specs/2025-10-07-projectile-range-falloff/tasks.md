# Spec Tasks

<<<<<<< HEAD
> Status: IMPLEMENTATION COMPLETE

=======
>>>>>>> projectile-range-falloff
## Tasks

- [x] 1. Implement range profile data module
  - [x] 1.1 Write tests for projectile range helper calculations (define debug verification steps)
  - [x] 1.2 Create `RangeProfile` enum and initialize profile structs in projectile range script
  - [x] 1.3 Implement helper functions to fetch profiles and compute distance multipliers
  - [x] 1.4 Verify helper outputs across point-blank, optimal, and long-range distances

- [x] 2. Integrate profiles with player projectile flow
  - [x] 2.1 Write tests for player projectile damage falloff (manual combat checklist)
  - [x] 2.2 Extend ranged weapon item definitions to reference range profiles
  - [x] 2.3 Update player projectile spawn logic to capture range data and track travel distance
  - [x] 2.4 Ensure `obj_arrow` applies the multiplier before resistance/DR math

<<<<<<< HEAD
- [x] 3. Apply falloff to enemy projectiles and debug hooks
  - [x] 3.1 Write tests for enemy projectile falloff behavior (encounter validation plan)
  - [x] 3.2 Assign range profiles to enemy projectile spawners and default projectiles
  - [x] 3.3 Multiply enemy projectile damage based on travel distance and enforce max travel limits
  - [x] 3.4 Validate debug logging/tuning tools respect `global.debug_mode`
=======
- [ ] 3. Apply falloff to enemy projectiles and debug hooks
  - [ ] 3.1 Write tests for enemy projectile falloff behavior (encounter validation plan)
  - [ ] 3.2 Assign range profiles to enemy projectile spawners and default projectiles
  - [ ] 3.3 Multiply enemy projectile damage based on travel distance and enforce max travel limits
  - [ ] 3.4 Validate debug logging/tuning tools respect `global.debug_mode`
>>>>>>> projectile-range-falloff
