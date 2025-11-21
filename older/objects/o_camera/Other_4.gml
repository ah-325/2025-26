//exit if theres no player
if !instance_exists(o_player) exit;

//get camera size
var _camWidth = camera_get_view_width(view_camera[0]);
var _camHeight = camera_get_view_height(view_camera[0]);

//set camera coords at start of room
var _camX = o_player.x - _camWidth/2;
var _camY = o_player.y - _camHeight/2;

//constrain to room borders
_camX = clamp(_camX, 0, room_width - _camWidth);
_camY = clamp(_camY, 0, room_height - _camHeight);

//set camera coords at start of room
finalCamX = _camX;
finalCamY = _camY;