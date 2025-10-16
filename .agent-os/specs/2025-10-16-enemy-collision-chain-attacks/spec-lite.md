# Enemy Collision Chain Attacks - Lite Summary

Implement configurable collision damage for all enemies with damage types and invulnerability frames, add advanced chain boss attacks (throw auxiliary as projectile, spin with orbiting auxiliaries), and implement auxiliary-based damage reduction where chain boss gains bonus DR for each living auxiliary (2 DR per auxiliary). Collision damage system allows any enemy to deal damage on player contact with proper DR calculations, while chain manipulation attacks make boss fights more dynamic and strategic.

## Key Points
- Universal collision damage system with configurable damage, types, and invulnerability frames per enemy
- Chain boss gains 2 DR per living auxiliary (scales dynamically as auxiliaries die)
- New boss attacks: throw auxiliary as projectile (deals collision damage + auxiliary death), spin attack with orbiting auxiliaries (multi-hit potential)
