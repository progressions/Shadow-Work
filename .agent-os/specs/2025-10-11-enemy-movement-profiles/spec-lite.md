# Enemy Movement Profiles - Lite Summary

Implement a generalized movement profile system for enemies, starting with a "kiting swoop attacker" profile for bat enemies. Bats will maintain distance from the player using erratic pathfinding, perform fast dash attacks, and return to their anchor position. The system should be reusable via a global database similar to the trait system.

## Key Points
- Create global movement profile database with reusable configurations
- Implement kiting behavior that maintains distance with erratic movements
- Add swoop attack dash with return-to-anchor mechanics
- Integrate profiles into existing enemy state machine without breaking pathfinding
- Respect stun/stagger CC effects during movement profile execution
