// Inherit the parent event
event_inherited();

attack_damage = 1;
attack_damage_type = DamageType.fire; // Fire imp deals fire damage
attack_speed = 0.8;
attack_range = 32;
hp = 12;
hp_total = hp;
move_speed = 0.75;

// Apply fireborne tag (grants fire_immunity + ice_vulnerability)
apply_tag_traits("fireborne");

// Fire imp attacks cause burning
attack_status_effects = [
    {effect: StatusEffectType.burning, chance: 0.5} // 50% chance to burn on hit
];