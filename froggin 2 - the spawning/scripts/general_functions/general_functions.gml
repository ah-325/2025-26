function controlsSetup()
{
	bufferTime = 3.5;
	
	jumpKeyBuffered = 0;
	jumpKeyBufferTimer = 0;
}


	
function getControls()
{
	//directional inputs
	rightKey = keyboard_check(ord("D")) + keyboard_check(vk_right);
		rightKey = clamp( rightKey,0,1);
	
	leftKey = keyboard_check(ord("A")) + keyboard_check(vk_left);
		leftKey = clamp( leftKey,0,1);
		
			downKey = keyboard_check(ord("S")) + keyboard_check(vk_down);
		downKey = clamp( downKey,0,1);
		
	//action inputs
	jumpKeyPressed = keyboard_check_pressed(vk_space) + keyboard_check_pressed(ord("C"));
		jumpKeyPressed = clamp( jumpKeyPressed,0,1);
	
	jumpKey = keyboard_check(vk_space) + keyboard_check(ord("C"));
		jumpKey = clamp( jumpKey,0,1);
		
	upKey = keyboard_check(ord("W")) + keyboard_check(vk_up);
		upKey = clamp( upKey,0,1);
	
	dashKeyPressed = keyboard_check_pressed(ord("X"));
	
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