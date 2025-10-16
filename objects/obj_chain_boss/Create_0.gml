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
// TRAITS & TAGS
// ============================================
// Fire-based boss with fire immunity
array_push(tags, "fireborne");  // Grants fire_immunity, ice_vulnerability
apply_tag_traits();