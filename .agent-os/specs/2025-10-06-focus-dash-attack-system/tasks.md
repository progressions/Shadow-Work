# Spec Tasks

> Status: IMPLEMENTATION COMPLETE

## Tasks

- [x] 1. Implement focus input state handling
  - [x] 1.1 Write tests for focus state entry, hold timer, and stored vectors
  - [x] 1.2 Implement hold-`J` focus state management with aim/retreat buffers
  - [x] 1.3 Integrate focus state with movement/facing suppression and exit conditions
  - [x] 1.4 Expose focus metadata for downstream systems (dash, combat)
  - [x] 1.5 Verify all tests pass

- [x] 2. Build directional mapping and aim indicators
  - [x] 2.1 Write tests for eight-direction mapping and indicator state transitions
  - [x] 2.2 Map WASD combinations to normalized vectors during focus state
  - [x] 2.3 Implement visual indicator updates for aim and retreat directions
  - [x] 2.4 Verify all tests pass

- [x] 3. Define melee focus attack sequencing
  - [x] 3.1 Write tests for melee attack + post-attack dash timing under focus
  - [x] 3.2 Execute melee strikes using stored aim direction while in focus
  - [x] 3.3 Trigger automatic retreat dash after melee recovery when configured
  - [x] 3.4 Verify all tests pass

- [x] 4. Define ranged focus attack sequencing
  - [x] 4.1 Write tests for ranged dash-then-fire behavior and cooldown gating
  - [x] 4.2 Execute retreat dash prior to projectile spawn when focus retreat set
  - [x] 4.3 Fire projectile using stored aim direction with proper offsets
  - [x] 4.4 Verify all tests pass

- [x] 5. Integrate dash metadata and companion hooks
  - [x] 5.1 Write tests for dash reason tagging and companion trigger interactions
  - [x] 5.2 Tag focus-initiated dashes with distinct metadata for downstream systems
  - [x] 5.3 Ensure dash-triggered abilities (e.g., Canopy Dash Mend) respect new metadata
  - [x] 5.4 Verify all tests pass
