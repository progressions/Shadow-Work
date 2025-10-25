// Helper function to create sprite-based icon data
// Makes it easier to define icons that use sprites instead of strings
//
// @param {Asset.GMSprite} sprite - The sprite asset to use
// @param {Real} frame - The frame index of the sprite
// @return {Struct} Icon data struct with sprite and frame

function input_icon_sprite(_sprite, _frame) {
    return {
        sprite: _sprite,
        frame: _frame
    };
}
