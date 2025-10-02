To implement this pathfinding system in GameMaker Studio 2, you need to set up two main objects: a controller/setup object and an AI/enemy object.

Here's a breakdown of the implementation steps:

1. Setup Object (1:07) This object is responsible for creating and defining the pathfinding grid.

Create the Grid: In the Create Event of your setup object, use mp_grid_create to define the grid's dimensions and cell size (2:57).

Set the top-left corner to (0,0) (3:37).

Calculate horizontal and vertical cells based on room width/height divided by cell size (e.g., room_width/16, room_height/16) (4:02).

Define the cell size (e.g., 16x16) (4:30).

Add Obstacles: Use mp_grid_add_instances to mark areas on the grid as obstacles that the AI should avoid (5:28). You can define an object parent (e.g., "wall_parent") to include all wall instances (5:09).

Draw the Grid (Optional): In the Draw Event, you can use mp_grid_draw to visualize the grid (6:42). Green cells indicate walkable areas, and red cells are obstacles (7:12). It's recommended to set the alpha to a lower value (e.g., 0.3) for transparency (7:56).

2. AI/Enemy Object (8:05) This object will use the grid created by the setup object to find paths.

Define a Target: In the Create Event, define a variable for the target (e.g., target_x, target_y), which could be your player's position (8:35).

Initialize Path: Create a path variable, e.g., path_s = path_add() (8:59).

Update Path (Alarm Event): It's recommended to update the path periodically using an Alarm Event rather than every step to save resources (9:28).

Set an alarm to loop (e.g., every 2 seconds) (10:01).

Inside the alarm, first, delete the previous path with path_delete(path_s) (10:19).

Then, link the AI's path to the grid using mp_grid_path (10:52). You'll need to reference the grid created by your setup object, your current X and Y position, your target X and Y position, and whether to allow diagonal movement (11:31).

Start the path movement using path_start (12:55). You'll specify the path, speed, and what to do at the end of the path (12:59).

Draw Path (Optional): In the Draw Event, you can use draw_path to visualize the path the AI is taking (13:20).

This system allows your AI to navigate complex environments, avoiding obstacles and finding optimal routes (0:23).