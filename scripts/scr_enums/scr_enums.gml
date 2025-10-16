// ============================================
// ENUMS - Game-wide enumeration definitions
// ============================================

enum PlayerState {
	idle,
	walking,
	dashing,
	attacking,
	shielding,
	on_grid,
	dead,
}

enum EnemyState {
	idle,
	targeting,
	attacking,
	ranged_attacking,
	hazard_spawning,
	dead = 5,
	wander,
}

enum CompanionState {
	waiting,    // Not recruited, standing at spawn position
	following,  // Recruited, following player
	casting,    // Performing trigger animation
	evading     // Evading from combat, maintaining distance from player and enemies
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

enum PartyState {
    protecting,   // Guard a location, limited pursuit radius
    aggressive,   // Chase and attack player
    cautious,     // Maintain formation, engage when approached
    desperate,    // Few members remaining, high flee weights
    emboldened,   // Player is weak, high attack weights
    retreating,   // Flee as a group
    patrolling    // Follow a defined path, engage when player detected
}

enum BreakableState {
    idle,
    breaking,
    broken
}
