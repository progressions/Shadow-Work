// Clean up any lingering target indicators
if (variable_instance_exists(self, "target_indicator") && instance_exists(target_indicator)) {
    instance_destroy(target_indicator);
    target_indicator = noone;
}
