if (state != BreakableState.idle) exit;

if (!instance_exists(other)) exit;
if (!variable_instance_exists(other, "attack_category")) exit;
if (other.attack_category != AttackCategory.melee) exit;

// Track collisions so each melee swing only damages once
if (!variable_instance_exists(other, "hit_breakables") || !ds_exists(other.hit_breakables, ds_type_list)) {
	other.hit_breakables = ds_list_create();
}

if (ds_list_find_index(other.hit_breakables, id) != -1) exit;
ds_list_add(other.hit_breakables, id);

var _incoming_damage = 1;
if (variable_instance_exists(other, "damage")) {
	_incoming_damage = max(1, other.damage);
}

hp -= _incoming_damage;

if (hp <= 0) {
	begin_break(other);
}
