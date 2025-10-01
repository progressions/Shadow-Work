
// Get the tilemap for collisions
tilemap = layer_tilemap_get_id("Tiles_Col");

hp_total = hp;

// Initialize animation variables - IMPORTANT!
anim_timer = 0;  // Make sure this is here
image_speed = 0;
image_index = 0;

target_x = x;
target_y = y;

alarm[0] = 60;

// Store movement direction for animation
move_dir_x = 0;
move_dir_y = 0;

current_base_frame = 0;
frame_counter = 0;

state = EnemyState.idle;

kb_x = 0;
kb_y = 0;

// Attack system stats
attack_damage = 2; // Base enemy damage
attack_damage_type = DamageType.physical; // Default physical damage
attack_speed = 0.8; // Slower than default player
attack_range = 20; // Melee range
attack_cooldown = 0;
can_attack = true;

// Status effects system
init_status_effects();

// Trait system v2.0 - Stacking traits
permanent_traits = {}; // From tags (applied at creation)
temporary_traits = {};  // From buffs/debuffs (applied during combat)

// Enemy sound configuration
// Child enemies can override specific sounds: enemy_sounds.on_attack = snd_orc_roar;
enemy_sounds = {
    on_attack: undefined,      // Default: snd_enemy_attack_generic
    on_hit: undefined,         // Default: snd_enemy_hit_generic
    on_death: undefined,       // Default: snd_enemy_death
    on_aggro: undefined,       // Default: undefined (no sound)
    on_footstep: undefined,    // Default: undefined (no sound)
    on_status_effect: undefined // Default: snd_status_effect_generic
};