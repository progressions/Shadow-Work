# Sound System - Technical Documentation

This document provides comprehensive technical documentation for the sound system in Shadow Work, including variant randomization, enemy sound configuration, and playback functions.

---

## Table of Contents

1. [Sound Variant Randomization](#sound-variant-randomization)
2. [Enemy Sound Configuration](#enemy-sound-configuration)
3. [Sound Functions](#sound-functions)

---

## Sound Variant Randomization

The sound system supports automatic variant selection to add variety and prevent repetition.

**Location:** `/scripts/scr_sfx_functions/scr_sfx_functions.gml`

### Variant Naming Convention

Sound variants follow a specific naming pattern:
- **Base sound:** `snd_sword_hit`
- **Variant 1:** `snd_sword_hit_1`
- **Variant 2:** `snd_sword_hit_2`
- **Variant 3:** `snd_sword_hit_3`
- etc.

### Variant Cache Lookup

The system pre-caches variant counts for performance:

```gml
// In obj_sfx_controller Create event
global.sound_variant_lookup = {};

// Example entries
global.sound_variant_lookup[$ "snd_sword_hit"] = 3;      // 3 variants
global.sound_variant_lookup[$ "snd_footstep"] = 5;       // 5 variants
global.sound_variant_lookup[$ "snd_enemy_hit"] = 2;      // 2 variants
global.sound_variant_lookup[$ "snd_bow_attack"] = 1;     // No variants
```

**Location:** `/objects/obj_sfx_controller/Create_0.gml`

### Automatic Variant Selection

```gml
function play_sfx(sound, volume = 1.0, priority = 50, loop = false, fade_in = 0, fade_out = 0) {
    // Get sound name as string
    var sound_name = audio_get_name(sound);

    // Check if variants exist in lookup
    var variant_count = global.sound_variant_lookup[$ sound_name];

    if (variant_count != undefined && variant_count > 1) {
        // Has variants, pick random one
        var variant_index = irandom_range(1, variant_count);
        var variant_name = sound_name + "_" + string(variant_index);

        // Get variant sound asset
        var variant_sound = asset_get_index(variant_name);

        if (variant_sound != -1) {
            sound = variant_sound;

            // Debug logging
            if (global.debug_sound_variants) {
                show_debug_message("Playing variant: " + variant_name);
            }
        }
    }

    // Play the sound (original or variant)
    var sound_instance = audio_play_sound(sound, priority, loop);
    audio_sound_gain(sound_instance, volume, 0);

    // Apply fade effects if specified
    if (fade_in > 0) {
        audio_sound_gain(sound_instance, 0, 0);
        audio_sound_gain(sound_instance, volume, fade_in);
    }

    return sound_instance;
}
```

**Key Features:**
- Transparent to caller - just call `play_sfx(snd_sword_hit)`
- Automatically selects random variant if available
- Falls back to base sound if no variants found
- Returns sound instance for control (stop, modify, etc.)

### Adding New Variants

To add sound variants to the game:

**Step 1: Import Variant Sounds**

Import sound files with proper naming:
- `snd_footstep_1.wav`
- `snd_footstep_2.wav`
- `snd_footstep_3.wav`
- `snd_footstep_4.wav`
- `snd_footstep_5.wav`

**Step 2: Create Sound Assets**

In GameMaker IDE:
1. Create sound assets with names matching pattern
2. Name them: `snd_footstep_1`, `snd_footstep_2`, etc.

**Step 3: Update Variant Lookup**

```gml
// In obj_sfx_controller Create event
global.sound_variant_lookup[$ "snd_footstep"] = 5;  // 5 variants
```

**Step 4: Use in Code**

```gml
// Automatically picks random variant
play_sfx(snd_footstep, 0.6);
```

### Debug Mode

Enable debug logging to see which variants are playing:

```gml
// In obj_sfx_controller Create event
global.debug_sound_variants = true;  // Enable debug mode

// Output:
// Playing variant: snd_footstep_3
// Playing variant: snd_sword_hit_1
// Playing variant: snd_footstep_5
```

---

## Enemy Sound Configuration

Enemies have separate sound events for different combat actions.

**Location:** `/objects/obj_enemy_parent/Create_0.gml`

### Sound Event Structure

```gml
enemy_sounds = {
    on_melee_attack: undefined,    // Melee attack sound
    on_ranged_attack: undefined,   // Ranged attack sound
    on_hit: undefined,             // When enemy takes damage
    on_death: undefined,           // Death sound
    on_aggro: undefined,           // When enemy aggros to player (optional)
    on_footstep: undefined,        // Footstep sound (optional)
    on_status_effect: undefined,   // Status effect applied (optional)
    on_hazard_vocalize: undefined, // Boss hazard spawn vocalization (optional)
    on_hazard_windup: undefined,   // Boss hazard spawn windup (optional)
    on_enrage: undefined           // Chain boss enrage (optional)
};
```

### Default Fallback Sounds

If no custom sound is specified, the system uses generic fallbacks:

```gml
// Fallback sound mapping
var default_sounds = {
    on_melee_attack: snd_enemy_attack_generic,
    on_ranged_attack: snd_bow_attack,
    on_hit: snd_enemy_hit_generic,
    on_death: snd_enemy_death,
    on_status_effect: snd_status_effect_generic
};
```

**Location:** `/scripts/scr_sfx_functions/scr_sfx_functions.gml`

### Playing Enemy Sounds

```gml
function play_enemy_sfx(event_name) {
    // Check if custom sound defined
    var custom_sound = enemy_sounds[$ event_name];

    if (custom_sound != undefined) {
        // Play custom sound
        play_sfx(custom_sound, 1.0);
        return;
    }

    // Fall back to default sound
    var default_sound = get_default_enemy_sound(event_name);
    if (default_sound != undefined) {
        play_sfx(default_sound, 1.0);
    }
}
```

**Location:** `/scripts/scr_sfx_functions/scr_sfx_functions.gml`

### Overriding Enemy Sounds

Override sounds in child enemy Create events:

```gml
// obj_orc Create event
event_inherited();

// Override with orc-specific sounds
enemy_sounds.on_melee_attack = snd_orc_attack;
enemy_sounds.on_hit = snd_orc_grunt;
enemy_sounds.on_death = snd_orc_death;
enemy_sounds.on_aggro = snd_orc_roar;
```

### Example: Fire Boss Sounds

```gml
// obj_fire_boss Create event
event_inherited();

// Boss-specific sounds
enemy_sounds.on_melee_attack = snd_fire_boss_melee;
enemy_sounds.on_ranged_attack = snd_fire_boss_fireball;
enemy_sounds.on_hit = snd_fire_boss_hit;
enemy_sounds.on_death = snd_fire_boss_death;
enemy_sounds.on_aggro = snd_fire_boss_aggro;
enemy_sounds.on_hazard_vocalize = snd_fire_boss_roar;
enemy_sounds.on_hazard_windup = snd_fire_boss_cast;
enemy_sounds.on_enrage = snd_fire_boss_enrage;
```

### Using Enemy Sounds in Combat

**Melee Attack:**
```gml
// In scr_enemy_state_attacking.gml
if (attack_animation_frame == 0) {
    play_enemy_sfx("on_melee_attack");
}
```

**Ranged Attack:**
```gml
// In scr_enemy_state_ranged_attacking.gml
if (attack_animation_frame == 0) {
    play_enemy_sfx("on_ranged_attack");
}
```

**Taking Damage:**
```gml
// In obj_enemy_parent Collision_obj_attack
play_enemy_sfx("on_hit");
```

**Death:**
```gml
// In scr_enemy_state_dead.gml
if (death_animation_frame == 0) {
    play_enemy_sfx("on_death");
}
```

### Separate Melee vs Ranged Attack Sounds

Dual-mode enemies can have different sounds for each attack type:

```gml
// Orc Raider (dual-mode)
event_inherited();

enemy_sounds.on_melee_attack = snd_sword_swing;
enemy_sounds.on_ranged_attack = snd_bow_attack;

// Combat system automatically calls correct sound:
if (state == EnemyState.attacking) {
    play_enemy_sfx("on_melee_attack");
} else if (state == EnemyState.ranged_attacking) {
    play_enemy_sfx("on_ranged_attack");
}
```

---

## Sound Functions

Core sound playback and management functions.

**Location:** `/scripts/scr_sfx_functions/scr_sfx_functions.gml`

### play_sfx()

Main sound playback function with variant support.

```gml
function play_sfx(
    sound,            // Sound asset to play
    volume = 1.0,     // Volume (0.0 to 1.0)
    priority = 50,    // Priority (0-100, higher = more important)
    loop = false,     // Loop the sound?
    fade_in = 0,      // Fade in duration (milliseconds)
    fade_out = 0      // Fade out duration (milliseconds)
) {
    // ... variant selection logic ...

    var sound_instance = audio_play_sound(sound, priority, loop);
    audio_sound_gain(sound_instance, volume, 0);

    // Apply fade effects
    if (fade_in > 0) {
        audio_sound_gain(sound_instance, 0, 0);
        audio_sound_gain(sound_instance, volume, fade_in);
    }

    // Store looping sounds for later stop
    if (loop) {
        array_push(global.looping_sounds, {
            instance: sound_instance,
            sound: sound
        });
    }

    return sound_instance;
}
```

**Parameters:**
- **sound**: The sound asset (e.g., `snd_sword_hit`)
- **volume**: 0.0 (silent) to 1.0 (full volume)
- **priority**: 0-100, determines which sounds play when many playing
- **loop**: `true` for continuous looping
- **fade_in**: Milliseconds to fade in from silence
- **fade_out**: Milliseconds to fade out to silence

**Returns:** Sound instance ID for control

**Examples:**
```gml
// Basic sound
play_sfx(snd_sword_hit);

// Quiet sound
play_sfx(snd_footstep, 0.3);

// High priority sound
play_sfx(snd_boss_roar, 1.0, 90);

// Looping sound
var ambient_id = play_sfx(snd_wind_ambient, 0.5, 50, true);

// Fade in sound
play_sfx(snd_music_theme, 0.8, 60, true, 2000);  // 2 second fade in
```

### stop_looped_sfx()

Stops a specific looping sound.

```gml
function stop_looped_sfx(sound) {
    for (var i = 0; i < array_length(global.looping_sounds); i++) {
        var entry = global.looping_sounds[i];

        if (entry.sound == sound) {
            audio_stop_sound(entry.instance);
            array_delete(global.looping_sounds, i, 1);
            return;
        }
    }
}
```

**Example:**
```gml
// Start looping sound
play_sfx(snd_spinning, 1.0, 50, true);

// Later, stop it
stop_looped_sfx(snd_spinning);
```

### play_enemy_sfx()

Plays enemy-specific sound with fallback support.

```gml
function play_enemy_sfx(event_name) {
    // Check for custom sound
    var custom_sound = enemy_sounds[$ event_name];

    if (custom_sound != undefined) {
        play_sfx(custom_sound, 1.0);
        return;
    }

    // Use default sound
    var default_sound = get_default_enemy_sound(event_name);
    if (default_sound != undefined) {
        play_sfx(default_sound, 1.0);
    }
}
```

**Example:**
```gml
// In enemy attack code
play_enemy_sfx("on_melee_attack");

// Automatically uses:
// 1. enemy_sounds.on_melee_attack if defined
// 2. snd_enemy_attack_generic if not defined
```

### Audio Control Functions

**Stop Sound:**
```gml
audio_stop_sound(sound_instance);
```

**Adjust Volume:**
```gml
audio_sound_gain(sound_instance, new_volume, fade_time);
```

**Check if Playing:**
```gml
if (audio_is_playing(sound_instance)) {
    // Sound is currently playing
}
```

**Pause/Resume:**
```gml
audio_pause_sound(sound_instance);
audio_resume_sound(sound_instance);
```

---

## Sound Categories

### Combat Sounds

**Player Attacks:**
- `snd_sword_swing` (variants: 1-3)
- `snd_dagger_stab` (variants: 1-2)
- `snd_bow_attack` (variants: 1-2)
- `snd_dash_attack`

**Enemy Attacks:**
- `snd_enemy_attack_generic` (fallback)
- `snd_orc_attack`
- `snd_burglar_attack`
- `snd_fire_boss_melee`

**Hit Sounds:**
- `snd_enemy_hit_generic` (variants: 1-3)
- `snd_player_hit` (variants: 1-2)
- `snd_crit_hit`

### Movement Sounds

**Player:**
- `snd_footstep` (variants: 1-5)
- `snd_dash`
- `snd_jump` (if implemented)

**Enemies:**
- Enemy-specific footstep sounds
- Boss movement sounds

### UI Sounds

**Menus:**
- `snd_menu_select`
- `snd_menu_back`
- `snd_menu_error`

**Inventory:**
- `snd_item_pickup`
- `snd_item_equip`
- `snd_item_drop`

### Ability Sounds

**Companion Triggers:**
- `snd_canopy_heal`
- `snd_yorna_fury`
- `snd_hola_wind`

**Boss Abilities:**
- `snd_throw_start`
- `snd_throwing` (looping)
- `snd_spin_start`
- `snd_spinning` (looping)
- `snd_hazard_cast`

---

## Key Files Reference

| File | Purpose | Key Lines |
|------|---------|-----------|
| `/scripts/scr_sfx_functions/scr_sfx_functions.gml` | Sound playback functions | Full file |
| `/objects/obj_sfx_controller/Create_0.gml` | Sound controller initialization | Full file |
| `/objects/obj_enemy_parent/Create_0.gml` | Enemy sound configuration | Lines 85-97 |

---

*Last Updated: 2025-10-17*
