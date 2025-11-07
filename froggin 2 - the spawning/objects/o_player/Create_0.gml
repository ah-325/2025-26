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
movePlatXspd = 0;
moveplatMaxYspd = termVel;