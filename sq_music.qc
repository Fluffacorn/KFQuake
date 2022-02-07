
//====================================================================
//				sq_music.qc by Squirt: plays background music
//====================================================================

//-------------------
void() music_repeat =
//-------------------
{
	//damn ambientsound doesn't work !
	//ambientsound (self.origin, "track1.wav", 1, ATTN_IDLE);
	
	if (cvar("temp1") && TEMP1_NOMUSIC)	//music is disabled, return
		return;

	current_track = current_track + 1;	
	if (current_track > 2)
		current_track = 1;

	if (current_track == 1)			//Track: Undead's smooth drum'n bass track
	{
		sound (self, CHAN_BODY, "track1.wav", 1, ATTN_NONE);
		self.nextthink = time + 29.99;		//that's the length of the track
	}
	else if (current_track == 2)		//Track: hit the road jack
	{
		sound (self, CHAN_BODY, "track2.wav", 1, ATTN_NONE);
		self.nextthink = time + 30;		//that's the length of the track
	}
	
	self.think = music_repeat;
};

//-------------------
void() create_music =
//-------------------
{
local entity	music;

	current_track = floor(random() * 2);

	music = spawn();
	music.origin = '0 0 0';
	music.movetype = MOVETYPE_NONE;
	music.solid = SOLID_NOT;
	music.classname = "music";
	music.think = music_repeat;
	music.nextthink = time + 1;			//start music in 1 second
};