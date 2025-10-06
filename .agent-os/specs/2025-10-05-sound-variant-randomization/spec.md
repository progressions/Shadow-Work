# Spec Requirements Document

> Spec: Sound Variant Randomization System
> Created: 2025-10-05

## Overview

Implement a centralized sound variant randomization system that automatically selects between multiple sound file variations to prevent audio repetition fatigue during fast-paced combat. The system will cache variant counts at game start for zero-performance-impact runtime selection, enhancing the "punchy" combat feel by adding audio variety without requiring custom code for each sound effect.

## User Stories

### Audio Variety for Combat Impact

As a player, I want to hear varied sound effects during repeated combat actions, so that the audio feels dynamic and engaging rather than repetitive and monotonous.

When the player performs repeated attacks or triggers companion abilities multiple times in a row, the system will automatically cycle through available sound variants (e.g., snd_shield_trigger_1, snd_shield_trigger_2, snd_shield_trigger_3) randomly, creating a more organic and impactful audio experience that matches the fast, punchy combat design philosophy.

### Developer Ease of Use

As a developer, I want to add sound variety without writing custom randomization code, so that I can quickly enhance audio feedback across the entire game.

When adding a new sound effect, the developer simply creates multiple sound files with _1, _2, _3 suffixes (e.g., snd_hit_1, snd_hit_2, snd_hit_3) and the system automatically detects and randomly selects between them at runtime. No database configuration or special function calls are required—the existing `play_sfx()` function becomes variant-aware.

### Backward Compatibility

As a developer, I want existing sound effects without variants to continue working normally, so that I don't need to refactor the entire codebase to adopt the new system.

The system will gracefully fall back to playing the base sound file when no variants exist, ensuring all existing `play_sfx(snd_explosion)` calls continue to work exactly as before while new variant-based sounds automatically gain randomization.

## Spec Scope

1. **Variant Detection & Caching** - Scan all sound assets at game start, detect variant patterns (_1, _2, _3), and cache counts in a global lookup struct
2. **Smart play_sfx() Enhancement** - Modify existing `play_sfx()` function to check variant cache and randomly select between available variants
3. **Fallback Mechanism** - Play base sound file if no variants exist, ensuring backward compatibility with existing sound effects
4. **Debug Logging** - Add optional debug output showing variant detection results and runtime selection for testing
5. **Performance Optimization** - Ensure zero runtime performance impact by using cached lookups instead of repeated asset existence checks

## Out of Scope

- Manual configuration database for variant counts (auto-detection only)
- UI for managing sound variants
- Dynamic variant addition after game start
- Variant selection weighting (all variants have equal probability)
- Sequential/round-robin variant selection (random only)

## Expected Deliverable

1. Cached variant detection system running at game start that correctly identifies all sound files with _1, _2, _3+ patterns
2. Enhanced `play_sfx()` function that transparently selects random variants when available and falls back to base sounds otherwise
3. All existing sound effects continue working without modification while new variant-based sounds automatically randomize
