function __InputConfigVerbs()
{
    enum INPUT_VERB
    {
        //Add your own verbs here!
        UP,
        DOWN,
        LEFT,
        RIGHT,
        ACCEPT,
        CANCEL,
        ACTION,
        SPECIAL,
        PAUSE,
		SHIELD,
		ATTACK,
		DASH,
		INTERACT,
		UI_CANCEL,  // Context-aware: Close menus in UI (Circle)
		COMPANION_MENU,  // Open companion talk menu (C + Circle)
		INVENTORY,  // For opening inventory (I + Triangle)
		SWAP_LOADOUT,  // Swap between melee and ranged loadouts (Q + L1)
		DROP,  // Drop items from inventory (Square button)
    }
    
    enum INPUT_CLUSTER
    {
        //Add your own clusters here!
        //Clusters are used for two-dimensional checkers (InputDirection() etc.)
        NAVIGATION,
    }
    
    if (not INPUT_ON_SWITCH)
    {
        InputDefineVerb(INPUT_VERB.UP,      "up",         [vk_up,    "W"],    [-gp_axislv, gp_padu]);
        InputDefineVerb(INPUT_VERB.DOWN,    "down",       [vk_down,  "S"],    [ gp_axislv, gp_padd]);
        InputDefineVerb(INPUT_VERB.LEFT,    "left",       [vk_left,  "A"],    [-gp_axislh, gp_padl]);
        InputDefineVerb(INPUT_VERB.RIGHT,   "right",      [vk_right, "D"],    [ gp_axislh, gp_padr]);
        InputDefineVerb(INPUT_VERB.ACCEPT,  "accept",      vk_space,            gp_shoulderl);
        InputDefineVerb(INPUT_VERB.CANCEL,  "cancel",      vk_backspace,        gp_shoulderr);
        InputDefineVerb(INPUT_VERB.ACTION,  "action",      vk_enter,            gp_start);
        InputDefineVerb(INPUT_VERB.SPECIAL, "special",     vk_shift,            gp_select);
        InputDefineVerb(INPUT_VERB.PAUSE,   "pause",       vk_escape,           gp_start);
		InputDefineVerb(INPUT_VERB.SHIELD,  "shield",      "O",                 gp_shoulderr);
		InputDefineVerb(INPUT_VERB.ATTACK,  "attack",      "J",                 gp_face3);
		InputDefineVerb(INPUT_VERB.DASH,    "dash",        vk_shift,            undefined);
		InputDefineVerb(INPUT_VERB.INTERACT, "interact",   ["E", vk_space, vk_enter], gp_face1);
		InputDefineVerb(INPUT_VERB.UI_CANCEL, "ui_cancel", undefined,           gp_face2);
		InputDefineVerb(INPUT_VERB.COMPANION_MENU, "companion_menu", "C",       gp_face2);
		InputDefineVerb(INPUT_VERB.INVENTORY, "inventory", "I",                 gp_face4);
		InputDefineVerb(INPUT_VERB.SWAP_LOADOUT, "swap_loadout", "Q",          gp_shoulderl);
		InputDefineVerb(INPUT_VERB.DROP, "drop", undefined,                     gp_face3);
    }
    else //Flip A/B over on Switch
    {
        InputDefineVerb(INPUT_VERB.UP,      "up",      undefined, [-gp_axislv, gp_padu]);
        InputDefineVerb(INPUT_VERB.DOWN,    "down",    undefined, [ gp_axislv, gp_padd]);
        InputDefineVerb(INPUT_VERB.LEFT,    "left",    undefined, [-gp_axislh, gp_padl]);
        InputDefineVerb(INPUT_VERB.RIGHT,   "right",   undefined, [ gp_axislh, gp_padr]);
        InputDefineVerb(INPUT_VERB.ACCEPT,  "accept",  undefined,   gp_shoulderl);
        InputDefineVerb(INPUT_VERB.CANCEL,  "cancel",  undefined,   gp_shoulderr);
        InputDefineVerb(INPUT_VERB.ACTION,  "action",  undefined,   gp_start);
        InputDefineVerb(INPUT_VERB.SPECIAL, "special", undefined,   gp_select);
        InputDefineVerb(INPUT_VERB.PAUSE,   "pause",   undefined,   gp_start);
		InputDefineVerb(INPUT_VERB.SHIELD,  "shield",      "O",                 gp_shoulderr);
		InputDefineVerb(INPUT_VERB.ATTACK,  "attack",      "J",                 gp_face3);
		InputDefineVerb(INPUT_VERB.DASH,    "dash",        vk_shift,            undefined); // Gamepad dash via double-tap only
		InputDefineVerb(INPUT_VERB.INTERACT, "interact",   ["E", vk_space, vk_enter], gp_face2); // Switch A/B flipped
		InputDefineVerb(INPUT_VERB.UI_CANCEL, "ui_cancel", undefined,           gp_face1); // Switch A/B flipped
		InputDefineVerb(INPUT_VERB.COMPANION_MENU, "companion_menu", "C",       gp_face1); // Switch A/B flipped
		InputDefineVerb(INPUT_VERB.INVENTORY, "inventory", "I",                 gp_face4);
		InputDefineVerb(INPUT_VERB.SWAP_LOADOUT, "swap_loadout", "Q",          gp_shoulderl);
		InputDefineVerb(INPUT_VERB.DROP, "drop", undefined,                     gp_face3);
    }
    
    //Define a cluster of verbs for moving around
    InputDefineCluster(INPUT_CLUSTER.NAVIGATION, INPUT_VERB.UP, INPUT_VERB.RIGHT, INPUT_VERB.DOWN, INPUT_VERB.LEFT);
}
