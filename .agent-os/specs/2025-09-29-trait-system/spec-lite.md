# Spec Summary (Lite)

Implement a modular trait system where characters have a `traits = []` array of lowercase identifiers. Each trait (fireborne, arboreal, aquatic, etc.) grants data-driven effects from `global.trait_database` including damage modifiers, movement bonuses, and immunities. Integrate trait-based damage multipliers into the existing collision-based combat system.