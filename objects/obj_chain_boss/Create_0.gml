// Chain Boss - Fire variant
// Inherits from obj_chain_boss_parent

// ============================================
// CHAIN BOSS CONFIGURATION (before event_inherited)
// ============================================
// Must set auxiliary_object BEFORE event_inherited() so parent can spawn correct type
auxiliary_object = obj_fire_imp;

// Now inherit parent (will spawn auxiliaries using obj_fire_imp)
event_inherited();

hp = 100;
hp_total = hp;

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
array_push(tags, "fireborne");  // Grants fire_immunity, ice_vulnerability
apply_tag_traits();