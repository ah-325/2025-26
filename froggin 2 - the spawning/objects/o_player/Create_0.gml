//custom functions for player
function setOnGround(_val = true)
{
	if _val == true
	{
		onGround = true;
		coyoteHangTimer = coyoteHangFrames;
	} else {
		onGround = false;
		myFloorPlat = noone;
		coyoteHangTimer = 0;
	}
}	
//control setup
controlsSetup();

//sprites
idleSpr = s_playerIdle;
walkSpr = s_playerWalk;
jumpSpr = s_playerJump;
fallSpr = s_playerFall;

//moving
face = 1;
moveDir = 0;
moveSpd = 2;
xspd = 0;
yspd = 0;

//jumping - jumpmax = 1 for no double jump
grav = .275;
termVel = 4;
jumpMax = 2;
jumpCount = 0;
jumpHoldTimer = 0;
onGround = true;
//jump values for each successive jump
jumpHoldFrames[0] = 12;
jspd[0] = -3;

jumpHoldFrames[1] = 9;
jspd[1] = -2.2;

//coyote time
//hang time
coyoteHangFrames = 2;
coyoteHangTimer = 0;
//jump buffer time
coyoteJumpFrames = 5;
coyoteJumpTimer = 0;

//moving platforms
myFloorPlat = noone;
moveplatMaxYspd = termVel;

//ensure all deaths should actually happen
deathFrameTimer = 2;

//dash
canDash = false;
dashDistance = 48;
dashTime = 12;
dashEnergy = dashDistance;
hsp = 0;
vsp = 0;


//states
stateFree = function()
{
	image_blend = c_white
	//get out of moveplats that have positioned themselves inside of the player in begin step
#region
	var _rightWall = noone;
	var _leftWall = noone;
	var _bottomWall = noone;
	var _topWall = noone;
	var _list = ds_list_create();
	var _listSize = instance_place_list(x,y,o_moveplatp, _list, false)

	//loop through all colliding moveplats
	for(var i = 0; i < _listSize; i++)
	{
		var _listInst = _list[| i];
		
		//find the closest walls in each direction
		//if there are walls to the right of me get the closest one
		if _listInst.bbox_left - _listInst.xspd >= bbox_right-1
		{
			if !instance_exists(_rightWall) || _listInst.bbox_left < _rightWall.bbox_left
			{
				_rightWall=_listInst;
			}
		}
		//left walls
		if _listInst.bbox_right - _listInst.xspd <= bbox_left+1
		{
			if !instance_exists(_leftWall) || _listInst.bbox_right > _leftWall.bbox_right
			{
				_leftWall = _listInst;
			}
		}
		//bottom walls
		if _listInst.bbox_top - _listInst.yspd >= bbox_bottom-1
		{
			if !_bottomWall || _listInst.bbox_top < _bottomWall.bbox_top
			{
				_bottomWall = _listInst;
			}
		}
		//top walls
		if _listInst.bbox_bottom - _listInst.yspd <= bbox_top +1
		{
			if !_topWall || _listInst.bbox_bottom > _topWall.bbox_bottom
			{
				_topWall = _listInst;
			}
		}
	}
	
	//destroy the ds list to free memory
	ds_list_destroy(_list);
	
	//get out of the walls
	//right wall
		if instance_exists(_rightWall)
		{
			var _rightDist = bbox_right - x;
			x= _rightWall.bbox_left - _rightDist;
		}
	//left wall
	if instance_exists(_leftWall)
	{
		var _leftDist = x - bbox_left;
		x = _leftWall.bbox_right + _leftDist;
	}
	//bottom wall
	if instance_exists(_bottomWall)
	{
		var _bottomDist = bbox_bottom - y;
		y =  _bottomWall.bbox_top - _bottomDist;
	}
	//top wall(includes collisions for polish and crouching features)
	if instance_exists(_topWall)
	{
		var _upDist = y - bbox_top;
		var _targetY = _topWall.bbox_bottom + _upDist;
		//check if there isnt a wall in thr way
		if !place_meeting( x,_targetY, o_wallp )
		{
			y = _targetY;
		}
	}
#endregion

//x movement
	//direction
	moveDir = rightKey - leftKey;
	
	//get face direction
	if moveDir != 0 { face = moveDir; };

	//get xspd
	xspd = moveDir * moveSpd;
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
		canDash = true;
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
		yspd = jspd[max(jumpCount - 1, 0)];
		//count down the timer
		jumpHoldTimer--;
	}
	
	// dash input
	if (canDash && dashKeyPressed && !onGround) {
	    // disable further dashes until reset
	    canDash = false;
	    jumpCount ++;

	    // get input directions
	    var dirX = rightKey - leftKey;
	    var dirY = downKey - upKey;

	    // prevent zero-length dash
	    if (dirX == 0 && dirY == 0) {
	        // default to facing direction if no input
	        dirX = face;
	        dirY = 0;
	    }

	    // calculate dash angle in degrees
	    dashDirection = point_direction(0, 0, dirX, dirY);

	    // calculate dash speed for consistent distance over dashTime frames
	    dashSpd = dashDistance / dashTime;
	    dashEnergy = dashDistance;

	    // switch to dash state
	    state = stateDash;
	}

	
	
	//y collision and movement
	

		//cap falling speed
		if yspd > termVel { yspd = termVel; };
		//y collision
		var _subPixel = .5;
		//upwards y collision with ceiling slopes too
		if yspd < 0 && place_meeting( x, y + yspd,o_wallp)
		{
			// jump into sloped ceilings
			var _slopeSlide = false;
			//slide upleft slope
			if !place_meeting(x - abs(yspd)-1, y+yspd, o_wallp)
			{
				while place_meeting( x, y+yspd, o_wallp) { x -= 1; };
				var _slopeSlide = true;
			}
			//slide upright slope
			if !place_meeting(x + abs(yspd)+1, y+yspd, o_wallp)
			{
				while place_meeting(x,y+yspd, o_wallp) {x += 1; };
				var _slopeSlide = true;
			}
			//normal y collision
			if !_slopeSlide
				{
					//scoot up to the wall precisely
					var _pixelCheck = _subPixel * sign(yspd);
					while !place_meeting(x,y + _pixelCheck, o_wallp )
					{ 
						y += _pixelCheck;
					}
					//bonk code. if you run out of yspd (hit ceiling) you cant keep holding to jump higher
					//if yspd < 0
					//{
					//	jumpHoldTimer = 0;
		
					//set yspd to 0 to collide
					yspd = 0;
					
		}
		
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
		y+=yspd;
		
//final moving platform collisions
	//snap y to myfloorplat
	if instance_exists(myFloorPlat) 
	&& (myFloorPlat.yspd != 0
	||myFloorPlat.object_index == o_moveplatp
	||object_is_ancestor(myFloorPlat.object_index,o_moveplatp)
	|| myFloorPlat.object_index == o_ssmovingp
	|| object_is_ancestor(myFloorPlat.object_index,o_ssmovingp))
	{
		if !place_meeting( x, myFloorPlat.bbox_top, o_wallp )
		&& myFloorPlat.bbox_top >= bbox_bottom-moveplatMaxYspd
		{
			y = myFloorPlat.bbox_top;
		}
	}
	//playerdeath if we are inside of a wall
if place_meeting(x,y,o_wallp)
	{
	deathFrameTimer -= 1;
	if deathFrameTimer == 0
		{playerDeath();}
	}
}










stateDash = function()
{	

	xspd = hsp;
	yspd = vsp;
	
	image_blend = c_silver;
	image_blend = c_silver;
	image_blend = c_silver;
	//trail effect
	with(instance_create_depth(x,y,depth+1,o_trail))
	{
		sprite_index = other.sprite_index;
		image_blend = c_silver;
		image_alpha = 0.7;
		
		    // orientation based on your face variable
    image_xscale  = other.face; 
	}
	//get out of moveplats that have positioned themselves inside of the player in begin step
#region
	var _rightWall = noone;
	var _leftWall = noone;
	var _bottomWall = noone;
	var _topWall = noone;
	var _list = ds_list_create();
	var _listSize = instance_place_list(x,y,o_moveplatp, _list, false)

	//loop through all colliding moveplats
	for(var i = 0; i < _listSize; i++)
	{
		var _listInst = _list[| i];
		
		//find the closest walls in each direction
		//if there are walls to the right of me get the closest one
		if _listInst.bbox_left - _listInst.xspd >= bbox_right-1
		{
			if !instance_exists(_rightWall) || _listInst.bbox_left < _rightWall.bbox_left
			{
				_rightWall=_listInst;
			}
		}
		//left walls
		if _listInst.bbox_right - _listInst.xspd <= bbox_left+1
		{
			if !instance_exists(_leftWall) || _listInst.bbox_right > _leftWall.bbox_right
			{
				_leftWall = _listInst;
			}
		}
		//bottom walls
		if _listInst.bbox_top - _listInst.yspd >= bbox_bottom-1
		{
			if !_bottomWall || _listInst.bbox_top < _bottomWall.bbox_top
			{
				_bottomWall = _listInst;
			}
		}
		//top walls
		if _listInst.bbox_bottom - _listInst.yspd <= bbox_top +1
		{
			if !_topWall || _listInst.bbox_bottom > _topWall.bbox_bottom
			{
				_topWall = _listInst;
			}
		}
	}
	
	//destroy the ds list to free memory
	ds_list_destroy(_list);
	
	//get out of the walls
	//right wall
		if instance_exists(_rightWall)
		{
			var _rightDist = bbox_right - x;
			x= _rightWall.bbox_left - _rightDist;
		}
	//left wall
	if instance_exists(_leftWall)
	{
		var _leftDist = x - bbox_left;
		x = _leftWall.bbox_right + _leftDist;
	}
	//bottom wall
	if instance_exists(_bottomWall)
	{
		var _bottomDist = bbox_bottom - y;
		y =  _bottomWall.bbox_top - _bottomDist;
	}
	//top wall(includes collisions for polish and crouching features)
	if instance_exists(_topWall)
	{
		var _upDist = y - bbox_top;
		var _targetY = _topWall.bbox_bottom + _upDist;
		//check if there isnt a wall in thr way
		if !place_meeting( x,_targetY, o_wallp )
		{
			y = _targetY;
		}
	}
#endregion

//x movement

	hsp = lengthdir_x(dashSpd,dashDirection);
	vsp = lengthdir_y(dashSpd,dashDirection);
	
	//direction
	moveDir = rightKey - leftKey;
	
	//get face direction
	if moveDir != 0 { face = moveDir; };

	//get xspd
	xspd = moveDir * moveSpd;
	var _subPixel = .5;
	if place_meeting(x + hsp, y, o_wallp)
	{
		//check if there is a slope to go up first
		if !place_meeting( x + hsp, y - abs(hsp)-1,  o_wallp )
		{
			while place_meeting( x + hsp, y, o_wallp ) { y -= _subPixel; };
		}
		//check for ceiling slopes. if none, regular collision
		else
		{
			//ceiling slopes
			if !place_meeting(x + hsp, y + abs(hsp)+1, o_wallp )
			{
				while place_meeting(x + hsp, y, o_wallp) {y += _subPixel; };
			}
			else
			{
			//normal collision
		//scoot up to wall precisely
		var _pixelCheck = _subPixel * sign(hsp);
		while !place_meeting( x + _pixelCheck, y, o_wallp ) {x += _pixelCheck;};

		//set xspd to 0 to collide
		hsp = 0;
		}
	}
	}
	//go down slopes
	if vsp >= 0 && !place_meeting( x + hsp, y + 1, o_wallp) && place_meeting( x + hsp, y + abs(hsp)+1, o_wallp )
	{
		while !place_meeting( x + hsp, y + _subPixel, o_wallp ) {y += _subPixel; };
	}

	// move
	x += hsp; 
	
	
//y movement
	//gravity
	if coyoteHangTimer > 0
	{
		//count the timer down
		coyoteHangTimer --;
	} else {
		//apply gravity to player
		vsp += grav;
		//were no longer on the ground
		setOnGround(false);
		coyoteJumpTimer = 0;
	}
	//reset/prepare jumping variable
	if onGround
	{
		canDash = true;
		jumpCount = 0;
		coyoteJumpTimer = coyoteJumpFrames
	} else {
		//if the player is in the air, cant do more jumps
		coyoteJumpTimer--;
		if jumpCount == 0 && coyoteJumpTimer <= 0 {jumpCount = 1;};
	}
	
	
	////initiate the jump
	//if jumpKeyBuffered && jumpCount < jumpMax
	//{
	//	//reset the buffer
	//	jumpKeyBuffered = false;
	//	jumpKeyBufferTimer = 0;
		
	//	//increase number of performed jumps
	//	jumpCount++;
		
	//	//set trhe jump hold timeer
	//	jumpHoldTimer = jumpHoldFrames[jumpCount-1];
	//	//tell ourselves were no lolnger on the ground
	//	setOnGround(false);
	//}
	//cut off the jump by releasing jump button
	if !jumpKey
	{
		jumpHoldTimer = 0;
	}
	
	//jump based on timer/holding button
	if jumpHoldTimer > 0
	{
		//constantly set the yspd to be jumping speed
		yspd = jspd[max(jumpCount - 1, 0)];
		//count down the timer
		jumpHoldTimer--;
	}
	

	
	
	//y collision and movement
	

		//cap falling speed
		if vsp > termVel { vsp = termVel; };
		//y collision
		var _subPixel = .5;
		//upwards y collision with ceiling slopes too
		if vsp < 0 && place_meeting( x, y + vsp,o_wallp)
		{
			// jump into sloped ceilings
			var _slopeSlide = false;
			//slide upleft slope
			if !place_meeting(x - abs(vsp)-1, y+vsp, o_wallp)
			{
				while place_meeting( x, y+vsp, o_wallp) { x -= 1; };
				var _slopeSlide = true;
			}
			//slide upright slope
			if !place_meeting(x + abs(vsp)+1, y+vsp, o_wallp)
			{
				while place_meeting(x,y+vsp, o_wallp) {x += 1; };
				var _slopeSlide = true;
			}
			//normal y collision
			if !_slopeSlide
				{
					//scoot up to the wall precisely
					var _pixelCheck = _subPixel * sign(vsp);
					while !place_meeting(x,y + _pixelCheck, o_wallp )
					{ 
						y += _pixelCheck;
					}
					//bonk code. if you run out of yspd (hit ceiling) you cant keep holding to jump higher
					//if yspd < 0
					//{
					//	jumpHoldTimer = 0;
		
					//set yspd to 0 to collide
					vsp = 0;
					
		}
		
		}		
		
		
		//floor y collision
		
		//check for solid and semisolid platforms under me
		var _clampYspd = max( 0 , vsp );
		var _list = ds_list_create(); //create a ds list to store all the objects we run into
		var _array = array_create(0);
		array_push(_array, o_wallp, o_semisolidp);
		

		//do the actual check and add objects to list
		var _listSize = 0;
		_listSize += instance_place_list(x, y + 1 + _clampYspd + termVel, o_wallp, _list, false);
		if (vsp >= 0) {
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
					|| _listInst.bbox_top + _listInst.yspd <= myFloorPlat.bbox_top + myFloorPlat.vsp
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
			vsp = 0;
			setOnGround(true)
		}
		
		
		
			//move
		 y+=vsp;
		
//final moving platform collisions
	//snap y to myfloorplat
	if instance_exists(myFloorPlat) 
	&& (myFloorPlat.yspd != 0
	||myFloorPlat.object_index == o_moveplatp
	||object_is_ancestor(myFloorPlat.object_index,o_moveplatp)
	|| myFloorPlat.object_index == o_ssmovingp
	|| object_is_ancestor(myFloorPlat.object_index,o_ssmovingp))
	{
		if !place_meeting( x, myFloorPlat.bbox_top, o_wallp )
		&& myFloorPlat.bbox_top >= bbox_bottom-moveplatMaxYspd
		{
			y = myFloorPlat.bbox_top;
		}
	}
	//playerdeath if we are inside of a wall
//if place_meeting(x,y,o_wallp)
//	{
//	deathFrameTimer -= 1;
//	if deathFrameTimer == 0
//		{playerDeath();}
//	}

	
	//end dash
	if state == stateDash
	{
		dashEnergy -= dashSpd;
		if (dashEnergy <= 0)
		{
			vsp = 0;
			hsp = 0;
			state = stateFree;
		
		}

	}
}

state = stateFree;



