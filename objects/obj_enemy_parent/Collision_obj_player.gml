/// Enemy Collision with Player - Collision Damage System
// Enemies can damage player on contact if configured

// ============================================
// SPECIAL CASE: THROWN AUXILIARY HIT
// ============================================
// Check if this is an auxiliary in "being_thrown" state
if (variable_instance_exists(self, "throw_state") && throw_state == "being_thrown") {
    // Auxiliary hit player during throw attack
    if (variable_instance_exists(self, "chain_boss") && instance_exists(chain_boss)) {
        // Play hit sound
        if (audio_exists(chain_boss.throw_sound_hit)) {
            play_sfx(chain_boss.throw_sound_hit, 1, 8, false);
        }

        // Stop flying sound
        if (audio_exists(chain_boss.throw_sound_flying)) {
            stop_looped_sfx(chain_boss.throw_sound_flying);
        }

        // Start returning to boss
        throw_state = "returning";

        show_debug_message("Thrown auxiliary hit player!");
    }

    // Continue to apply damage normally
}

// Only apply collision damage if:
// 1. Collision damage is enabled for this enemy
// 2. Cooldown timer has expired
// 3. Player is alive
// 4. Player is not invulnerable
if (!collision_damage_enabled) exit;
if (collision_damage_timer > 0) exit;
if (other.hp <= 0 || other.state == PlayerState.dead) exit;
if (variable_instance_exists(other, "invulnerable") && other.invulnerable) exit;

// ============================================
// DAMAGE CALCULATION PIPELINE
// ============================================

var _base_damage = collision_damage_amount;

// Apply status effect damage modifiers from enemy
var damage_modifier = get_status_effect_modifier("damage");
var _status_modified_damage = _base_damage * damage_modifier;

// Apply damage type resistance multiplier using trait system v2.0
var _resistance_multiplier = 1.0;
with (other) {
    _resistance_multiplier = get_damage_modifier_for_type(other.collision_damage_type);
}
var _after_resistance = _status_modified_damage * _resistance_multiplier;

// Apply player melee damage reduction (collision counts as melee)
var _player_dr = 0;
with (other) {
    _player_dr = get_melee_damage_reduction();
}
var _after_defense = _after_resistance - _player_dr;

// Apply chip damage floor only if armor fully blocked the attack
var _chip = 1;
var final_damage;
if (_after_defense <= 0) {
    // Armor blocked everything, apply chip damage
    final_damage = _chip;
} else {
    // Some damage got through
    final_damage = _after_defense;
}

// ============================================
// APPLY DAMAGE AND EFFECTS
// ============================================

// Deal damage to player
other.hp -= final_damage;
companion_on_player_damaged(other, final_damage, collision_damage_type);

// Interrupt player ranged attack windup if taking damage during windup
with (other) {
    if (ranged_windup_active && !ranged_windup_complete) {
        state = PlayerState.idle;
        ranged_windup_active = false;
        ranged_windup_complete = false;
        anim_frame = 0;
        play_sfx(snd_player_interrupted, 0.7, false);
        inventory_add_item(global.item_database.arrows, 1);
    }
}

// Reset combat timer for companion evading behavior
other.combat_timer = 0;

// Spawn damage number
if (_resistance_multiplier <= 0) {
    spawn_immune_text(other.x, other.y - 16, other);
} else {
    spawn_damage_number(other.x, other.y - 16, final_damage, collision_damage_type, other);
}

// Check if player died
if (other.hp <= 0) {
    other.state = PlayerState.dead;
}

// ============================================
// KNOCKBACK EFFECT
// ============================================

// Push player away from enemy
var _kb_force = 3;
var _angle = point_direction(x, y, other.x, other.y);
other.kb_x = lengthdir_x(_kb_force, _angle);
other.kb_y = lengthdir_y(_kb_force, _angle);

// Visual feedback - flash player
other.image_blend = c_red;
other.alarm[0] = 10;  // Reset color after 10 frames

// Play hit sound
if (audio_exists(snd_player_hit)) {
    play_sfx(snd_player_hit, 1, false);
}

// ============================================
// TRIGGER INVULNERABILITY
// ============================================

// Trigger player invulnerability frames
if (variable_instance_exists(other, "trigger_invulnerability")) {
    other.trigger_invulnerability(30);  // 0.5 seconds of invulnerability
}

// ============================================
// SET COOLDOWN
// ============================================

// Start collision damage cooldown
collision_damage_timer = collision_damage_cooldown;

show_debug_message("Enemy collision damage: " + string(final_damage) + " " + string(collision_damage_type));
