// ============================================
// SPAWNER PARENT - Collision with obj_attack
// Handle damage from player attacks
// ============================================

// Only take damage if damageable and not already destroyed
if (is_damageable && !is_destroyed) {
    // Get damage from the attack object
    var damage_amount = other.damage;

    // Apply damage using helper function
    spawner_take_damage(id, damage_amount);

    // Destroy the attack object (it has hit something)
    instance_destroy(other);
}
