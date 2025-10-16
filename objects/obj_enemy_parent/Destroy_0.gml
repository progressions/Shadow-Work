/// Enemy Parent - Destroy Event
// Handle cleanup and chain boss notification

// ============================================
// CHAIN BOSS AUXILIARY DEATH NOTIFICATION
// ============================================

// If this enemy is a chain auxiliary, notify the boss
if (variable_instance_exists(self, "chain_boss") && instance_exists(chain_boss)) {
    // Decrement boss's alive counter
    chain_boss.auxiliaries_alive--;

    // Remove this auxiliary from boss's tracking arrays
    for (var i = 0; i < array_length(chain_boss.auxiliaries); i++) {
        if (chain_boss.auxiliaries[i] == self) {
            array_delete(chain_boss.auxiliaries, i, 1);
            array_delete(chain_boss.chain_data, i, 1);

            show_debug_message("Auxiliary died! Boss has " + string(chain_boss.auxiliaries_alive) + " auxiliaries remaining.");
            break;
        }
    }
}
