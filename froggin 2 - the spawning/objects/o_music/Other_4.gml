 if (room==r_w1s1 && !audio_is_playing(mp3_world1))
	{
	audio_play_sound(mp3_world1,1,1);
	}
 
 if (room==r_w2s1 && !audio_is_playing(mp3_world2))
	{
	audio_pause_sound(mp3_world1);
	audio_play_sound(mp3_world2,1,1);
	}
 
  if (room==r_w3s1 && !audio_is_playing(mp3_world3))
	{
	audio_pause_sound(mp3_world2);
	audio_play_sound(mp3_world3,1,1);
	}