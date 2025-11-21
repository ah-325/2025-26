function controlsSetup()
{
	bufferTime = 3.5;
	
	jumpKeyBuffered = 0;
	jumpKeyBufferTimer = 0;
}

function semisolidPlatformCheck(_x, _y)
{
		//create a return variable
		var _rtrn = noone;
		//we mustnt be moving upwards, and then check for a normal collision
		if yspd >= 0 && place_meeting(_x,_y, o_semisolidp)
		{
			//create a ds list to store all colliding instances of o_semisolidp
			var _list = ds_list_create();
			var _listSize = instance_place_list(_x,_y, o_semisolidp, _list, false);
			
			//loop through the colliding instance and only return one if its top is below the player
			for (var i = 0; i < _listSize; i++ )
			{
				var _listInst = _list[| i];
				if floor(bbox_bottom) <= ceil( _listInst.bbox_top - _listInst.yspd)
				{
					//return the id of a semisolid platform
					_rtrn = _listInst;
					//exit the loop early
					i = _listSize;
				}
			}
			//destroy the list to free memory
			ds_list_destroy(_list);
		}
		//return our variable
		return _rtrn;
}
	
function getControls()
{
	//directional inputs
	rightKey = keyboard_check(ord("D")) + keyboard_check(vk_right);
		rightKey = clamp( rightKey,0,1);
	
	leftKey = keyboard_check(ord("A")) + keyboard_check(vk_left);
		leftKey = clamp( leftKey,0,1);
	//action inputs
	jumpKeyPressed = keyboard_check_pressed(vk_space) + keyboard_check_pressed(vk_up) + keyboard_check_pressed(ord("W"));
		jumpKeyPressed = clamp( jumpKeyPressed,0,1);
	
	jumpKey = keyboard_check(vk_space) + keyboard_check(vk_up) + keyboard_check(ord("W"));
		jumpKey = clamp( jumpKey,0,1);
	//jump key buffering
	if jumpKeyPressed
	{
		jumpKeyBufferTimer = bufferTime;
	}
	if jumpKeyBufferTimer > 0
	{
		jumpKeyBuffered = 1;
		jumpKeyBufferTimer--;
	} else {
		jumpKeyBuffered = 0;
	}
}

function playerDeath()
{
	global.playerDeathCount += 1;
	room_restart()
}
	
function playerSpriteControl()
{
	//run
	if abs(xspd) > 0 {sprite_index=walkSpr;};
	//not moving
	if xspd == 0 {sprite_index=idleSpr};
	//jumping
	if !onGround {sprite_index=jumpSpr};
	//falling
	if yspd > 0 
	//&& !place_meeting(x,y+myFloorPlat.yspd,o_ssmovingp)
	&& !instance_exists(myFloorPlat)
	{sprite_index=fallSpr};
	
		//set the collision mask
	mask_index = idleSpr;
}