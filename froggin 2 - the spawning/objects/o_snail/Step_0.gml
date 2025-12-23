if place_meeting( x + xspd, y , o_wallp)
{
	xspd *= -1
}

x += xspd

if xspd < 0
	{
	image_xscale = -1;
	}
if xspd > 0
	{
	image_xscale = 1;
	}
		