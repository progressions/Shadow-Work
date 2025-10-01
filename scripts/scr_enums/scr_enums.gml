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
	attacking,
	dead,
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
    ammo
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
    holy,
    unholy
}
