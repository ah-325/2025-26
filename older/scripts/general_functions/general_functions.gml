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