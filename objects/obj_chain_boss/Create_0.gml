// Chain Boss - Fire variant
// Inherits from obj_chain_boss_parent

// ============================================
// CHAIN BOSS CONFIGURATION (before event_inherited)
// ============================================
// Must set auxiliary_object BEFORE event_inherited() so parent can spawn correct type
auxiliary_object = obj_fire_imp;

// IMPORTANT: Set HP BEFORE event_inherited() so parent uses correct hp_total value
hp = 100;

// Now inherit parent (will spawn auxiliaries using obj_fire_imp)
event_inherited();

// Ensure hp_total is set correctly (redundant but safe)
hp_total = hp;

// Debug: Verify HP initialization
show_debug_message("CHAIN BOSS CREATED:");
show_debug_message("  hp: " + string(hp));
show_debug_message("  hp_total: " + string(hp_total));
show_debug_message("  auxiliaries_alive: " + string(auxiliaries_alive));

// ============================================
// ENABLE ADVANCED ATTACKS
// ============================================

// Enable throw attack
enable_throw_attack = true;
throw_damage = 4;
throw_damage_type = DamageType.fire;
// Override sounds if you have custom fire boss sounds:
// throw_sound_start = snd_fire_boss_throw_start;
// throw_sound_flying = snd_fire_whoosh;
// throw_sound_hit = snd_fire_impact;

// Enable spin attack
enable_spin_attack = true;
spin_damage = 5;
spin_damage_type = DamageType.fire;
spin_rotation_speed = 8; // Faster spin for dramatic effect
// Override sounds if you have custom fire boss sounds:
// spin_sound_start = snd_fire_boss_spin_start;
// spin_sound_spinning = snd_fire_spin_loop;
// spin_sound_end = snd_fire_boss_spin_end;

// ============================================
// TRAITS & TAGS
// ============================================
// Fire-based boss with fire immunity
if (!variable_instance_exists(self, "tags")) tags = [];
array_push(tags, "fireborne");  // Grants fire_immunity, ice_vulnerability
apply_tag_traits();

  enable_auxiliary_respawn = true;