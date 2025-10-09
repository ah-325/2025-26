//get inputs - pressed checks only once when pressed (not hold)
getControls();

//x movement
	//direction
	moveDir = rightKey - leftKey;
	
	//get face direction
	if moveDir != 0 { face = moveDir; };

	//get xspd
	xspd = moveDir * moveSpd;

	//x collision
	var _subPixel = .5;
	if place_meeting(x + xspd, y, o_wall)
	{
		//scoot up to wall precisely
		var _pixelCheck = _subPixel * sign(xspd);
		while !place_meeting( x + _pixelCheck, y, o_wall )
		{
			x += _pixelCheck;
		}	
		//set xspd to 0 to collide
		xspd = 0;
	}

	// move
	x += xspd; 
	
//y movement
	//gravity
	if coyoteHangTimer > 0
	{
		//count the timer down
		coyoteHangTimer --;
	} else {
		//apply gravity to player
		yspd += grav;
		//were no longer on the ground
		setOnGround(false);
		coyoteJumpTimer = 0;
	}
	//reset/prepare jumping variable
	if onGround
	{
		jumpCount = 0;
		coyoteJumpTimer = coyoteJumpFrames
	} else {
		//if the player is in the air, cant do more jumps
		coyoteJumpTimer--;
		if jumpCount == 0 && coyoteJumpTimer <= 0 {jumpCount = 1;};
	}
	
	
	//initiate the jump
	if jumpKeyBuffered && jumpCount < jumpMax
	{
		//reset the buffer
		jumpKeyBuffered = false;
		jumpKeyBufferTimer = 0;
		
		//increase number of performed jumps
		jumpCount++;
		
		//set trhe jump hold timeer
		jumpHoldTimer = jumpHoldFrames[jumpCount-1];
		//tell ourselves were no lolnger on the ground
		setOnGround(false);
	}
	//cut off the jump by releasing jump button
	if !jumpKey
	{
		jumpHoldTimer = 0;
	}
	
	//jump based on timer/holding button
	if jumpHoldTimer > 0
	{
		//constantly set the yspd to be jumping speed
		yspd = jspd[jumpCount-1];
		//count down the timer
		jumpHoldTimer--;
	}
	
	//y collision and movement
		//cap falling speed
		if yspd > termVel { yspd = termVel; };
		//y movement
		var _subPixel = .5;
		if place_meeting(x,y + yspd, o_wall )
		{
			//scoot up to the wall precisely
			var _pixelCheck = _subPixel * sign(yspd);
			while !place_meeting(x,y + _pixelCheck, o_wall )
			{ 
				y += _pixelCheck;
			}
			//bonk code. if you run out of yspd (hit ceiling) you cant keep holding to jump higher
			if yspd < 0
			{
				jumpHoldTimer = 0;
			}
		
			//set yspd to 0 to collide
			yspd = 0;
		}
		//set if on the ground
		if yspd >= 0 && place_meeting(x,y+1, o_wall)
		{
			setOnGround(true);
		} 
		
		//move
		y += yspd;
		
		
//sprite control
	//run
	if abs(xspd) > 0 {sprite_index=walkSpr;};
	//not moving
	if xspd == 0 {sprite_index=idleSpr};
	//jumping
	if !onGround {sprite_index=jumpSpr};
	//falling
	if yspd > 0 {sprite_index=fallSpr};
	
	//set the collision mask
	mask_index = idleSpr;
	
	
	
	
	
	
	
	
	
		
		
		
		
		
		
		
		
	
	
	
	
	
	
	
	