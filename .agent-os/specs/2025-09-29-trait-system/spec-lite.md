# Trait System - Lite Summary (v2.0)

Implement an Age of Wonders-inspired tag/trait system where **tags** are thematic descriptors (fireborne, venomous, arboreal) that grant bundles of **traits** (fire_immunity, fire_resistance, fire_vulnerability). Traits stack up to 5 times with multiplicative mechanics. Opposite traits cancel stack-by-stack (resistance vs vulnerability). Characters have `permanent_traits` and `temporary_traits` structs storing trait stacks from tags, equipment, buffs, and companions. Equipment integration replaces direct `damage_resistances` modification with trait grants/removals.

## Key Points
- **Tag/Trait Separation**: Tags grant permanent trait bundles; equipment/buffs grant temporary traits
- **Stacking Mechanics**: Max 5 stacks per trait, multiplicative effects (2 fire_resistance = 0.75² = 0.5625x damage)
- **Opposite Cancellation**: Resistance/vulnerability pairs cancel stack-by-stack before calculating final modifier
- **Immunity Behavior**: 1+ immunity stacks = complete immunity (unless cancelled by vulnerability stacks)
- **Equipment Integration**: `apply_wielder_effects()` adds temporary traits; trait system is single source of truth for resistances
