# Spec Tasks

These are the tasks to be completed for the spec detailed in @.agent-os/specs/2025-10-05-sound-variant-randomization/spec.md

> Created: 2025-10-05
> Status: Ready for Implementation

## Tasks

- [ ] 1. Implement Sound Variant Detection System
  - [ ] 1.1 Write test suite for variant detection (verify detection of _1, _2, _3 patterns)
  - [ ] 1.2 Add global.sound_variant_lookup initialization in obj_game_controller Create event
  - [ ] 1.3 Implement asset iteration logic to scan all sound resources
  - [ ] 1.4 Add pattern detection for _1 suffixes and sequential variant counting
  - [ ] 1.5 Populate global.sound_variant_lookup struct with variant counts
  - [ ] 1.6 Add debug logging to show detected variants (optional, controlled by flag)
  - [ ] 1.7 Verify test suite passes with sample variant sounds

- [ ] 2. Enhance play_sfx() Function for Variant Selection
  - [ ] 2.1 Write test suite for play_sfx() variant randomization
  - [ ] 2.2 Modify play_sfx() in scr_sfx_functions.gml to handle both string and asset parameters
  - [ ] 2.3 Add variant lookup logic using global.sound_variant_lookup
  - [ ] 2.4 Implement random variant selection with irandom_range()
  - [ ] 2.5 Add fallback to base sound when no variants exist
  - [ ] 2.6 Add debug logging for variant selection (controlled by global.debug_sound_variants flag)
  - [ ] 2.7 Verify backward compatibility with existing non-variant sounds
  - [ ] 2.8 Verify all tests pass

- [ ] 3. Create Test Variant Sound Files
  - [ ] 3.1 Create test sound files: snd_test_variant_1, snd_test_variant_2, snd_test_variant_3
  - [ ] 3.2 Create test sound with 2 variants: snd_test_two_1, snd_test_two_2
  - [ ] 3.3 Create test sound without variants: snd_test_single (no suffix)
  - [ ] 3.4 Verify variant detection system identifies all test sounds correctly
  - [ ] 3.5 Test play_sfx() calls with each test sound type

- [ ] 4. Performance Testing and Optimization
  - [ ] 4.1 Create performance test that calls play_sfx() 100+ times per second
  - [ ] 4.2 Benchmark cache building time at game start
  - [ ] 4.3 Benchmark runtime variant selection overhead
  - [ ] 4.4 Verify performance impact is negligible (< 1ms per call)
  - [ ] 4.5 Document performance results

- [ ] 5. Integration and Documentation
  - [ ] 5.1 Test integration with existing sound effects (ensure no regressions)
  - [ ] 5.2 Add usage documentation to CLAUDE.md or relevant docs file
  - [ ] 5.3 Create example variant sound files for Canopy's shield trigger (snd_shield_trigger_1, _2, _3)
  - [ ] 5.4 Verify system works in actual gameplay with combat sounds
  - [ ] 5.5 Final verification that all tests pass and system is production-ready
