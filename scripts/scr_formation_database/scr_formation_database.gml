
// Initialize formation database for party controller system
global.formation_database = {
    line_3: {
        max_members: 3,
        roles: ["frontline", "frontline", "frontline"],
        offsets: [
            {x: 0, y: 0},      // Leader/center
            {x: -48, y: 0},    // Left
            {x: 48, y: 0}      // Right
        ]
    },

    wedge_5: {
        max_members: 5,
        roles: ["frontline", "frontline", "frontline", "backline", "backline"],
        offsets: [
            {x: 0, y: 0},      // Point
            {x: -32, y: 32},   // Left front
            {x: 32, y: 32},    // Right front
            {x: -48, y: 64},   // Left back
            {x: 48, y: 64}     // Right back
        ]
    },

    circle_4: {
        max_members: 4,
        roles: ["defender", "defender", "defender", "defender"],
        offsets: [
            {x: 0, y: -48},    // North
            {x: 48, y: 0},     // East
            {x: 0, y: 48},     // South
            {x: -48, y: 0}     // West
        ]
    },

    protective_3: {
        max_members: 3,
        roles: ["frontline", "backline", "backline"],
        offsets: [
            {x: 0, y: 0},      // Tank front
            {x: -32, y: 48},   // Ranged left
            {x: 32, y: 48}     // Ranged right
        ]
    }
};