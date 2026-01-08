if isActive {
    other.jumpCount = 0;
    other.canDash = true;
    audio_play_sound(mp3_jumpreset, 1, false);

    isActive = false;
    alarm[0] = room_speed * 4;
}