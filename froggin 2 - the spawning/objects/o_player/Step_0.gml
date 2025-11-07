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
	if place_meeting(x + xspd, y, o_wallp)
	{
		//check if there is a slope to go up first
		if !place_meeting( x + xspd, y - abs(xspd)-1,  o_wallp )
		{
			while place_meeting( x + xspd, y, o_wallp ) { y -= _subPixel; };
		}
		//check for ceiling slopes. if none, regular collision
		else
		{
			//ceiling slopes
			if !place_meeting(x + xspd, y + abs(xspd)+1, o_wallp )
			{
				while place_meeting(x + xspd, y, o_wallp) {y += _subPixel; };
			}
			else
			{
			//normal collision
		//scoot up to wall precisely
		var _pixelCheck = _subPixel * sign(xspd);
		while !place_meeting( x + _pixelCheck, y, o_wallp ) {x += _pixelCheck;};

		//set xspd to 0 to collide
		xspd = 0;
		}
	}
	}
	//go down slopes
	if yspd >= 0 && !place_meeting( x + xspd, y + 1, o_wallp) && place_meeting( x + xspd, y + abs(xspd)+1, o_wallp )
	{
		while !place_meeting( x + xspd, y + _subPixel, o_wallp ) {y += _subPixel; };
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
		if place_meeting(x,y + yspd, o_wallp )
		{
			//scoot up to the wall precisely
			var _pixelCheck = _subPixel * sign(yspd);
			while !place_meeting(x,y + _pixelCheck, o_wallp )
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
		
		
		
		//floor y collision
		
		//check for solid and semisolid platforms under me
		var _clampYspd = max( 0 , yspd );
		var _list = ds_list_create(); //create a ds list to store all the objects we run into
		var _array = array_create(0);
		array_push(_array, o_wallp, o_semisolidp);
		

		//do the actual check and add objects to list
		var _listSize = 0;
		_listSize += instance_place_list(x, y + 1 + _clampYspd + termVel, o_wallp, _list, false);
		if (yspd >= 0) {
	    _listSize += instance_place_list(x, y + 1 + _clampYspd + termVel, o_semisolidp, _list, false);
		}
		
		//loop through the colliding instances and only return 1 if it's top is below the player
		for (var i = 0; i < _listSize; i++ )
		{
			//get an instance of wall or moving platform from the list
			var _listInst = _list[| i];
			
			//avoid magnestism
			if ( _listInst.yspd <= yspd || instance_exists(myFloorPlat) )
			&& ( _listInst.yspd > 0 || place_meeting(x, y+1 + _clampYspd, _listInst ) )
			{
				//return a solid wall or semisolid that are below the player
				if _listInst.object_index == o_wallp
				|| object_is_ancestor(_listInst.object_index, o_wallp)
				||floor(bbox_bottom) <= ceil(_listInst.bbox_top -_listInst.yspd )
				{
					//return the "highest" wall object
					if !instance_exists(myFloorPlat)
					|| _listInst.bbox_top + _listInst.yspd <= myFloorPlat.bbox_top + myFloorPlat.yspd
					|| _listInst.bbox_top + _listInst.yspd <= bbox_bottom
					{
						myFloorPlat = _listInst
					}
				}
			}
		
		}
		//destroy the DS list to avoid a memory leak
		ds_list_destroy(_list);
		
		//one last check to ensure the floor platform is actually below us
		if instance_exists(myFloorPlat) && !place_meeting( x, y + moveplatMaxYspd, myFloorPlat)
		{
			myFloorPlat = noone;
		}
		//land on the ground platform if there is one
		if instance_exists(myFloorPlat)
		{
			//scoot up to our wall precisely
			var _subPixel = .5;
			while !place_meeting( x, y+ _subPixel, myFloorPlat ) && !place_meeting(x,y,o_wallp) {y+= _subPixel;};
			//make sure we dont end up below the top of a semisolid
			if myFloorPlat.object_index == o_semisolidp ||object_is_ancestor(myFloorPlat.object_index, o_semisolidp)
			{
				while place_meeting(x,y,myFloorPlat) {y -= _subPixel; };
			}
			//floor the y variable
			y = floor(y);
			
			//colllide with the ground
			yspd = 0;
			setOnGround(true)
		}
		
		
		
			//move
		y += yspd;
		
		
//final moving platform collisions
	//snap y to myfloorplat
	if instance_exists(myFloorPlat) 
	&& (myFloorPlat.yspd != 0
	|| myFloorPlat.object_index == o_ssmovingp
	|| object_is_ancestor(myFloorPlat.object_index,o_ssmovingp))
	{
		if !place_meeting( x, myFloorPlat.bbox_top, o_wallp )
		&& myFloorPlat.bbox_top >= bbox_bottom-moveplatMaxYspd
		{
			y = myFloorPlat.bbox_top;
		}
	}


playerSpriteControl()

	



	
	
	
	
	
	
		
		
		
		
		
		
		
		
	
	
	
	
	
	
	
	