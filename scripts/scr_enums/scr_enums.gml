// ============================================
// ENUMS - Game-wide enumeration definitions
// ============================================

enum PlayerState {
	idle,
	walking,
	dashing,
	attacking,
	on_grid,
	dead,
}

enum EnemyState {
	idle,
	targeting,
	attacking,
	ranged_attacking,
	dead = 4,
	wander,
}

enum CompanionState {
	not_recruited,
	idle,
	following,
	recruited
}

enum StatusEffectType {
	burning,
	wet,
	empowered,
	weakened,
	swift,
	slowed,
}

enum Direction {
	down,
	right,
	left,
	up
}

enum ButtonType {
	resume,
	settings,
	quit
}

enum ItemType {
    weapon,
    armor,
    consumable,
    tool,
    ammo,
    quest_item
}

enum InventoryContextAction {
    none,
    equip,
    use
}

enum EquipSlot {
    none = -1,
    right_hand,
    left_hand,
    helmet,
    armor,
    boots,
    either_hand
}

enum WeaponHandedness {
    one_handed,
    two_handed,
    versatile
}

enum DamageType {
    physical,
    magical,
    fire,
    ice,
    lightning,
    poison,
    disease,
    holy,
    unholy
}

enum ResistanceLevel {
    immune,
    resistant,
    normal,
    vulnerable
}

enum SpawnerMode {
    finite,      // Spawn up to spawn_limit then stop
    continuous   // Spawn indefinitely until destroyed/deactivated
}
