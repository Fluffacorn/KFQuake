
// declaring the routines before they are called
void() bot_walk1;						//Squirt
void() bot_jump1;
void() bot_kickflip1;					//trick
void() bot_frontgrab1;					//animations
void() bot_oneeighty1;					//
void() bot_push1;
void() respawn_bot;
void() bot_die;						//Squirt
float() check_stairs;					//
void() th_respawn; 					//use in bot_walk
void() water_die;						//die in water


// Function from FrikBot0.8

void(string h) printy =
{
	WriteByte(MSG_ALL, 8);
	WriteByte(MSG_ALL, 2);
	WriteString(MSG_ALL, h);
};

//----------------------						//Routine by Squirt
float ( entity bot, entity item) item_needed =
//----------------------
{
	local	float	type, value;
	local float	needed;
	needed = TRUE;
//HEALTH
	if (item.classname == "item_health")
		if ( (bot.health >= 100) || (bot.health >= 100 && item.healtype == 2) )
			needed = FALSE;
	

//ARMOR
	type = 1;						//otherwise needed would be set to False when the item is no armor
	value = 200;					//
	if (item.classname == "item_armor1")
	{
		type = 0.3;
		value = 100;
	}
	if (item.classname == "item_armor2")
	{
		type = 0.6;
		value = 150;
	}
	if (item.classname == "item_armorInv")
	{
		type = 0.8;
		value = 200;
	}
	if (bot.armortype*bot.armorvalue >= type*value)
		needed = FALSE;

//AMMO
	if (item.classname == "item_shells" && bot.ammo_shells >= 100)
		needed = FALSE;
	if (item.classname == "item_nails" && bot.ammo_nails >= 200)
		needed = FALSE;
	if (item.classname == "item_rockets" && bot.ammo_rockets >= 100)
		needed = FALSE;
	if (item.classname == "item_cells" && bot.ammo_cells >= 200)
		needed = FALSE;

	return (needed);
};

// ------------------------------------------------
void() bot_search_for_items =
// ------------------------------------------------
{
local entity item;

// he gives up on that item and marks it to avoid it for a while
	if (time > self.search_time && self.goalentity != world)
		{
		if (self.goalentity.classname != "card")				//Squirt - card
			self.goalentity.search_time = time + 30;			//Squirt - 10 : 30
		self.goalentity = world;
		}

	if (self.goalentity != world)
		return;

// checks a radius around him for items
	item = findradius(self.origin, 1500);

	while(item)
		{
		if ( (item.flags & FL_ITEM) && visible(item) && item.model != string_null && time > item.search_time)
			{
			if (item_needed (self, item))
			{
				self.search_time = time + 5;			//Squirt -10 : 30
				self.goalentity = item;
				if (item.classname == "card")		//Don't search for other items
					return;			
			}
			}
		item = item.chain;
		}

};


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void() bot_grab_items =
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{

// sees if he's close enough to pick that item up

	if (self.goalentity == world)
		return;

	if (vlen(self.origin - self.goalentity.origin) <= 30)
		{
		if (self.goalentity.classname != "card")				//Squirt - card
			self.goalentity.search_time = time + 30;
		/*				//Squirt
		self.goalentity.solid = SOLID_NOT;
		self.goalentity.model = string_null;
		self.goalentity.nextthink = time + 20;
		self.goalentity.think = SUB_regen;
		if (self.goalentity.healamount)
			sound (self, CHAN_ITEM, "items/health1.wav", 1, ATTN_NORM);
		else if (self.goalentity.weapon)
			sound (self, CHAN_ITEM, "weapons/pkup.wav", 1, ATTN_NORM);
		else
			sound(self, CHAN_ITEM, "items/armor1.wav", 1, ATTN_NORM);
		*/				//Squirt
		self.goalentity = world;
		self.walkitem = world;
		if (self.talk_subject == 0)
		{
			self.talk_subject = 1;
			self.talk_time = time + 1;
		}
		}
};



// ------------------------------------------------
void() bot_search_for_waypoints =
// ------------------------------------------------
{
local entity wp;
local float shortest;

// he gives up on that waypoint and marks it to avoid it for a while
	if (time > self.search_time && self.goalentity != world)
		{
		self.goalentity.search_time = time + 10;
		self.goalentity = world;
		}

	if (self.goalentity != world)
		return;

// checks a radius around him for waypoints
	wp = findradius(self.origin, 200);
	shortest = 300;

	while(wp)
		{
		if (wp.classname == "waypoint" && visible(wp) && time > wp.search_time)
			{
				if (infront(wp) && (wp.origin_z - self.origin_z < 200) && (vlen(wp.origin - self.origin) < shortest))
				{
					shortest = vlen(wp.origin - self.origin);
					self.search_time = time + 1;			
					self.goalentity = wp;
					self.angles_y = vectoyaw(wp.origin - self.origin);
				}
			}
		wp = wp.chain;
		}
};


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void() bot_grab_waypoints =
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{

// sees if he's close enough to mark that waypoint

	if (self.goalentity == world)
		return;

	if (vlen(self.origin - self.goalentity.origin) <= 30)
		{
		self.goalentity.search_time = time + 10;
		self.goalentity = world;
		self.walkitem = world;
		}
};








// -----------------------------------------
void() jump_forward =
// -----------------------------------------
{
// propels him into the air

	if (!(self.flags & FL_ONGROUND))
		return;
	
		//jumping costs stamina now !
	self.ammo_shells = self.ammo_shells - JUMP_STAMINA_COST;

	
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	makevectors(self.angles);
	self.velocity = (v_forward * 250);				//Squirt - : + self.velocity
	self.velocity_z = self.velocity_z + 280;			//280 : 250
	sound (self, CHAN_BODY, "player/skatejmp.wav", 1, ATTN_NORM);
};


// ------------------------------------------------
void() check_for_water =
// ------------------------------------------------
{
local float p;
local float h;		//Squirt - head
local float m;
local float swimming;

// bots don't see water like players do, so we check for it
	makevectors(self.angles);
	p = pointcontents(self.origin + v_forward*16 - '0 0 16');			//Squirt - 16 units down
	h = pointcontents(self.origin + v_forward*16 + '0 0 16');			//Squirt - 16 units up (head)
	m = pointcontents(self.origin + v_forward*16);			//Squirt - (middle)

	if (m == CONTENT_WATER || m == CONTENT_SLIME || m == CONTENT_LAVA)
	{
		if (self.velocity_z < -100)	//going down
		{
			self.velocity_z = self.velocity_z + 20;
		}
	}

	if (h != CONTENT_WATER)
	{
		self.air_finished = time + 12;
	}
	
	if (p != CONTENT_WATER && p != CONTENT_SLIME && p != CONTENT_LAVA)
		return;
	
	if (h == CONTENT_WATER && time > self.pain_finished && time > self.air_finished)
		{
		T_Damage (self, world, world, 13);
		self.pain_finished = time + 1;
		sound (self, CHAN_VOICE, "player/gasp2.wav", 1, ATTN_NORM);
		}
	if (p == CONTENT_SLIME && time > self.pain_finished)
		{
		T_Damage (self, world, world, 10);
		self.pain_finished = time + 1;
		sound (self, CHAN_VOICE, "player/lburn2.wav", 1, ATTN_NORM);
		}
	if (p == CONTENT_LAVA && time > self.pain_finished)
		{
		T_Damage (self, world, world, 20);
		self.pain_finished = time + 0.2;
		sound (self, CHAN_VOICE, "player/lburn1.wav", 1, ATTN_NORM);
		}

// he'll try to swim upward here
	swimming = FALSE;
	if (m == CONTENT_WATER)
		swimming = TRUE;
	if (p == CONTENT_LAVA || p == CONTENT_SLIME)
		swimming = TRUE;

	if (random() < 0.3 && swimming == TRUE)					//Change angle randomly
		self.angles_y = random() * 360;	
	
	if (swimming == TRUE)
	{
		makevectors(self.angles);
		self.velocity = (v_forward * 370);
	}	

	if (time > self.air_finished - 4)
	{
			self.last_dive = time;
	}

	if (time > self.air_finished - 4 || time < self.last_dive + 10)				//drowning in 4 seconds
	{
		self.velocity_z = 150;
		if (h != CONTENT_WATER)
			self.velocity_z = 50;

		if (self.flags & FL_ONGROUND)
			self.flags = self.flags - (self.flags & FL_ONGROUND);
		//debugging	bprint("swimming up !!!!!\n");
	}
	
	if ((random() < 0.3 && swimming == TRUE) && h != CONTENT_WATER)		//swim upward when in water
	{
		self.velocity_z = 370;		//280:320
		if (self.flags & FL_ONGROUND)
			self.flags = self.flags - (self.flags & FL_ONGROUND);
	}
	
	if (self.health <= 0)								//Squirt
		bot_die();								//
};

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void() check_for_ledge =
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{	
	local   float   contents;
	local   vector spot;
	local   vector  start, end;
	local	  float	random_trick;

	if (random() < 0.1)					//Don't stuck
		return;		

	makevectors (self.angles);
	if (!(self.flags & FL_ONGROUND))		
		return;

	if (self.ammo_shells <= JUMP_STAMINA_COST)		//jumping costs stamina now !
		return;					//don't jump

	if (random() < 0.1)					//Squirt
	{								//just jump for fun :-)
		bot_jump1();					//hurray !!
		return;
	}	
	if (random() < 0.5)					//Squirt, bust a trick !
	{
		random_trick = random();

		if (random_trick < 0.3)
			bot_kickflip1();	
		else if (random_trick < 0.6)
			bot_frontgrab1();
		else
			bot_oneeighty1();

		return;
	}	


	spot = self.origin + (v_forward * 50) - '0 0 45';		//Don't jump when there's no ledge !
	traceline (self.origin, spot, TRUE, self);
	if (trace_fraction != 1.0 || pointcontents(trace_endpos) != CONTENT_EMPTY)
		return;	

	
	// Where the bot's feet are now
	start = self.origin - '0 0 24';
	end = start + v_forward * 140;			//Squirt - (number) : 96
	traceline (start, end, TRUE, self);
	
	start = end;	
	if (trace_fraction != 1.0)		// jump to wall
		start = start - (v_forward * 20);
	
	end = start - '0 0 100';	//x units down 
	traceline (start, end, TRUE, self);			//check for a ledge that's good for tricks
	contents = pointcontents (trace_endpos);		//(less than 256)
	if (trace_fraction == 1.0)
	{
		bot_kickflip1();			//BIG ledge ! Bust a trick !
		return;
	}


	end = start - '0 0 256';	//256 units down 
	traceline (start, end, TRUE, self);
	contents = pointcontents (trace_endpos);

	if ( (trace_fraction == 1.0) || (contents == CONTENT_LAVA) || (contents == CONTENT_SLIME) || (contents == CONTENT_WATER))
	{
		return;		//Don't jump into lava
	}
	else	
	{		
		bot_jump1();
		return;		// JUMP	
	}
};




// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	This function sets velocity to 0 to avoid Lava or Sewer
void() check_for_lava =
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{	
	local   float   contents;
	local   vector spot;
	local   vector  start, end;

		//makevectors (self.angles);
		//spot = self.origin + (v_forward * 50) - '0 0 45';		//check for a ledge
	
	spot = self.origin + (self.velocity * 0.15) - '0 0 45';		//check for a ledge

	traceline (self.origin, spot, TRUE, self);
	if (pointcontents(trace_endpos) == CONTENT_SOLID)		//safe and solid ground
		return;			//Go !
	
	if (trace_fraction != 1.0)		// no ledge
	{
		contents = pointcontents (trace_endpos);
		if ( (contents == CONTENT_LAVA) || (contents == CONTENT_SLIME))
		{
			self.velocity = '0 0 0';
			return;				//Stop !
		}
	}
	else					//ledge (trace_fraction == 1)
	{
		start = spot;			
		end = spot - '0 0 256';
		traceline (start, end, TRUE, self);		//check downward
		contents = pointcontents (trace_endpos);
		      //endless ledge !                                    lava                                             slime
		if ( (trace_fraction == 1.0) || (contents == CONTENT_LAVA) || (contents == CONTENT_SLIME))
		{
			self.velocity = '0 0 0';
			return;				//Stop !
		}
	}		
};



// ----------------------
void() bot_face =
// ----------------------
{
// this turns him directly toward his enemy

	//self.angles_y = vectoyaw(self.enemy.origin - self.origin);
	self.ideal_yaw = vectoyaw(self.enemy.origin - self.origin);
	ChangeYaw();
};


// ----------------------
void() bot_stand =
// ----------------------
{

// his standing thoughts, pretty simple

	check_for_water();

	if (time > self.pausetime)
	{
		self.th_walk();
		return;
	}
	
// do a cute little turn
	if (random() < 0.1)
		self.angles_y = self.angles_y - 15;
	else if (random() > 0.9)
		self.angles_y = self.angles_y + 15;
};

void() vel_move =
{
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	makevectors(self.angles);
	self.velocity = 420 * v_forward;				//400 : 370 : 270 : 250 : 220
	check_for_lava();
};
void(float r_or_l) vel_strafe =
{
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	makevectors(self.angles);			
	self.velocity = 200 * v_right * r_or_l;			//120 : 170 : 200 : 250  (don't strafe so fast)
	
	self.angles_z = r_or_l * 8;					//strafe like real players

	check_for_lava();
};

// ******************************		squirt_move() is like coffee_move() but the bot won't look at the wall all the time
void() squirt_move =
// ******************************
{
	if (random() < 0.8)
		self.angles_y = self.angles_y - (self.button1 / 4);
	if (walkmove (self.angles_y, 10) == TRUE)
	{
		vel_move();
	}
	else
	{	
		self.angles_y = self.angles_y + (self.button1 / 4);
		if (walkmove (self.angles_y, 10) == TRUE)
		{
			vel_move();
		}
		else
		{
			self.angles_y = self.angles_y + (self.button1 / 4);
			if (walkmove (self.angles_y, 10) == TRUE)
			{
				vel_move();
			}
			else
			{
				self.angles_y = self.angles_y + (self.button1 / 4);
			}
		}
	}
	// every so often, he'll change his wall-hugging direction

	if (random() <= 0.02)
	       if (random() <= 0.5)						
		if (self.button1 == 90)
			self.button1 = -90;
			else self.button1 = 90;

};

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void() bot_talk =
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{
local float	talk;
	
	if (bot_talk_tries < bot_num || random() < 0.5)
	{
		self.talk_subject = 0;
		self.talk_time = time + 60;
		bot_talk_tries = bot_talk_tries + 1;
		return;
	}
	bot_talk_tries = 0;

	talk = floor (random() * 6);
		//bprint(" ");
		//bprint (self.netname);
	printy(self.netname);			// Print in yellow !	

	if (self.talk_subject == 0) 		//bored
	{ 
		  if (talk == 0) printy(": Where can i find a good place to grind?");
     		  else if (talk == 1) printy(": I feel like wallriding, but I dunno how..."); 
      	  else if (talk == 2) printy(": this pizza is good!"); 
      	  else if (talk == 3) printy(": i'm bored"); 
      	  else if (talk == 4) printy(": i want to whack something with my board"); 
      	  else printy(": Squirt Bot rocks to the end of this earth!"); 
	} 
	if (self.talk_subject == 1) 		//got item
	{ 
		if (talk == 0) printy(": i like this map"); 
		else if (talk == 1) printy(": :-)"); 
		else if (talk == 2) printy(": hehehe...");
		else if (talk == 3) printy(": hehe"); 
		else if (talk == 4) printy(": i'm ready"); 
		else printy(": nice item"); 
	} 
	if (self.talk_subject == 2) 		//got fragged
	{
	if(random() < 0.3)				//don't use long sentences so often
	{
		if (talk == 0) printy(": i hate gettin fragged from "); 
		else if (talk == 1) printy(": i'll get you for that "); 
		else if (talk == 2) printy(": payback time, "); 
		else if (talk == 3) printy(": i'll take my revenge soon, "); 
		else if (talk == 4) printy(": don't do that again "); 
		else printy(": next time please don't kill me "); 
	
		printy(self.talk_name);
	}
	else
	{
		if (talk == 0) printy(": :-("); 
		else if (talk == 1) printy(": oh no!"); 
		else if (talk == 2) printy(": damn !"); 
		else if (talk == 3) printy(": arrgh"); 
		else if (talk == 4) printy(": aarrrrghh !!"); 
		else printy(": hmm :-["); 
	}
	}
	if (self.talk_subject == 3)		//logged in
	{ 
		if (talk == 0) printy(": whoa this server is fast!"); 
		else if (talk == 1) printy(": hey everybody"); 
		else if (talk == 2) printy(": step aside, i'm here"); 
		else if (talk == 3) printy(": it's time to frag!"); 
		else if (talk == 4) printy(": dying time is here"); 
		else printy(": greetings everyone"); 
	} 
	if (self.talk_subject == 4)		//killed an enemy
	{
	if(random() < 0.3)				//don't use long sentences so often
	{

		if (talk == 0) printy(": take this, "); 
		else if (talk == 1) printy(": you are so easy to frag "); 
		else if (talk == 2) printy(": eat my bullets, "); 
		else if (talk == 3) printy(": haha ! that was too easy "); 
		else if (talk == 4) printy(": why are you so slow "); 
		else printy(": why don't you shoot at me "); 

		printy(self.talk_name);
	}
	else
	{
		if (talk == 0) printy(": :-)"); 
		else if (talk == 1) printy(": har har"); 
		else if (talk == 2) printy(": hehe"); 
		else if (talk == 3) printy(": muhahahaha"); 
		else if (talk == 4) printy(": lol"); 
		else printy(": *g*"); 
	}
	}
	if (self.talk_subject == 6)		//will follow somebody
	{
		if (talk == 0) printy(": i'll follow you, "); 
		else if (talk == 1) printy(": ok "); 
		else if (talk == 2) printy(": after you, "); 
		else if (talk == 3) printy(": i'll do everything you want, "); 
		else if (talk == 4) printy(": you are the leader, "); 
		else printy(": let's go, "); 

		printy(self.talk_name);
	}

		//bprint(" ‘‘‘\n");
	printy("\n");

	sound(self, CHAN_VOICE, "misc/talk.wav", 1, ATTN_NONE); 
	self.talk_subject = 0; 
	self.talk_time = time + 60;
};

void() invisible_support =
{
	if (time < self.invisible_finished)
	{
		setmodel (self, "progs/eyes.mdl");
		setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
	}
	else if (time < self.invisible_finished + 1)
	{
		setmodel (self, "progs/skater.mdl");
		setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
	}
};

// --------------------------------
void() bot_run_slide =
// --------------------------------
{
	local float	ofs;
	
// this is a cool strafing routine

	if (self.lefty)
		ofs = 90;
	else
		ofs = -90;

	if (walkmove (self.angles_y + ofs, 5))			//Squirt - 20 : 10 : 5
	{
		vel_strafe(ofs / 90 * -1);
		return;
	}
	self.lefty = 1 - self.lefty;
	
	walkmove (self.angles_y - ofs, 5);				//Squirt - 20 : 10 : 5
	vel_strafe(ofs / 90);
};




// --------------------------------						//Squirt
void() bot_follow_enemy =
// --------------------------------
{
	movetogoal(5);
	if (walkmove(self.angles_y, 10) == TRUE)
		vel_move();
	else
		bot_run_slide();
};



void() bot_walk_think =
{
	self.slowthink = time + 0.5;				//Every half second

	bot_search_for_items();
	bot_search_for_waypoints();

	if (time > self.talk_time)
		bot_talk();
	
	invisible_support();

	water_die();
};

//----------------
float() bot_jump_stairs =
//----------------
{
local vector	spot;	
local float		wall_ahead;
local float		stairs_ahead;

	if (self.ammo_shells <= JUMP_STAMINA_COST)		//jumping costs stamina now !
		return(FALSE);					//don't jump


	stairs_ahead = check_stairs();		//function from sq_skate.qc
	if(!(stairs_ahead))
		return(FALSE);
	
	wall_ahead = FALSE;

	makevectors(self.angles);
	//check infront right of the bot
	spot = self.origin + (v_forward * 26) + (v_right * 16);
	traceline (self.origin, spot, TRUE, self);
	if (trace_fraction != 1.0 || pointcontents(trace_endpos) != CONTENT_EMPTY)
		wall_ahead = TRUE;	//wall
	
	//check infront left of the bot
	spot = self.origin + (v_forward * 26) - (v_right * 16);
	traceline (self.origin, spot, TRUE, self);
	if (trace_fraction != 1.0 || pointcontents(trace_endpos) != CONTENT_EMPTY)
		wall_ahead = TRUE;	//wall


	if (wall_ahead == FALSE)		//there is really a curb or stairs
	{
		bot_jump1();					//jump up the stairs !
		return(TRUE);
	}
	else
	{
		return(FALSE);	//return FALSE because bot won't jump
	}
};


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void() bot_walk =
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{
local entity	temp_goal;

	self.nextthink = time + 0.1;					//Squirt - walk faster

// this is his main AI routine, where he will look for items and enemies
	if (self.enemy != world)						//bug fixed ?
		self.enemy = world;					//

	self.angles_z = 0;						//strafe like real players: reset angles_z to 0
	check_for_water();
	
	if (time > self.slowthink)
		bot_walk_think();

	check_for_ledge();

	if (self.goalentity.classname == "waypoint")
		bot_grab_waypoints();
	else
		bot_grab_items();

	Regenerate_Health();					//Squirt
	Regenerate_Stamina();					//Squirt

	if ((self.busting == TRUE) && (self.flags & FL_ONGROUND))	//Squirt- land before finishing
	{										//the trick
		T_Damage (self, world, world, 15); 
		sound (self, CHAN_VOICE, "player/land2.wav", 1, ATTN_NORM);
		self.deathtype = "falling";
		self.busting = FALSE;
		bot_walk1();
		if (self.health <= 0)		//bot_walk1 can make a jumping gib, haha
		{
			self.deadflag = DEAD_DEAD;
			self.think = th_respawn;
			self.nextthink = time + 1;
		}
		return;
	}

	if (!(self.flags & FL_ONGROUND))					//Squirt- look for enemys while jumping		
	{
		makevectors(self.angles);
		self.velocity = self.velocity + (v_forward * 5);	//add to self.velocity to master
		return;								//curbs and stairs
	}

	if (self.pausetime > time)						//Don't move, only stand and attack
		return;

	
	if (self.push_time + 2 < time)
	{
		sound (self, CHAN_BODY, "player/skaterol.wav", 1, ATTN_NORM);
		self.push_time = time;
		bot_push1();
	}

// of course movetogoal() is id's C function, it moves randomly
// toward what his self.goalentity is; don't let it worry you,
// this function takes a long time to get where its going
// the coffee_move is his cool running function

//-----------------------------------------	teamplay------------------------------
	if (teamplay && self.bot_follow != world)
	{
		if (visible(self.bot_follow))
			self.bot_follow_time = time + 5;
		
		if (self.bot_follow_time < time)
		{
			if (self.bot_follow.classname == "player")
			{
				sprint(self.bot_follow, " - ");
				sprint(self.bot_follow, self.netname);
				sprint(self.bot_follow, " will continue roaming \n");
			}
			
			self.bot_follow = world;
			return;
		}

		if (!visible(self.bot_follow))
		{
			temp_goal = self.goalentity;
			self.goalentity = self.bot_follow;
				bot_follow_enemy();
			self.goalentity = temp_goal;			
			return;
		}

		if (vlen(self.origin - self.bot_follow.origin) > 100)
		{
			temp_goal = self.goalentity;
			self.goalentity = self.bot_follow;
			
				self.angles_y = vectoyaw(self.goalentity.origin - self.origin);
				if (walkmove(self.angles_y, 10) == TRUE)
					vel_move();
				else
					movetogoal(5);		//Only use if something is in the way

			
			self.goalentity = temp_goal;			
			return;
		}

		if (vlen(self.origin - self.bot_follow.origin) > 80 && time > self.pausetime + 1)	//80 - 100
		{
			self.pausetime = time + 0.5;
			self.th_stand();
			return;
		}

	}
//---------------------------------------------------------------------------------------------

	if (bot_jump_stairs())				//If there are stairs jump them up !
		return;

	if (self.goalentity != world)
	{
		if (self.goalentity.classname == "waypoint")
		{
			self.angles_y = vectoyaw(self.goalentity.origin - self.origin);
			if (walkmove(self.angles_y, 10) == TRUE)
				vel_move();
			else
				movetogoal(5);		//Only use if something is in the way
		}
		else
		{
			bot_follow_enemy();		
		}
	}	
	else 
	{
		squirt_move();
	}
};



/*
==========================================================================
==========================================================================
==========================================================================

	Section 2: Weapons

	This section is the simplest, basically dull stuff. It checks for
	his best weapon and sets the relevant ammo. It gives him a free
	weapon. And it does the actual firing of the weapons. The key
	difference between a player weapon routine and a bot weapon 
	routine is the aiming. In player routines, you'll see a line
	like this:

		dir = aim (self, 100000);

	If you want a bot to share that subroutine, basically all you need
	to do is change it to this:

		if (self.classname == "player")
			dir = aim (self, 100000);
			else dir = normalize(self.enemy.origin - self.origin);
			
	This allows the bot to aim directly at his enemy.


==========================================================================
==========================================================================
==========================================================================
*/


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void() bot_drop_pack =
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{
		DropBackpack();
};



/*
==========================================================================
==========================================================================
==========================================================================

	Section 3: Animation

	This is a bunch of ugly stuff, and you don't really need to
	understand all of it. It merely defines his animation frames and
	sequences. After that you have his pain, death, and attack routines.
	Lastly, we have his spawn/respawn subroutine.

==========================================================================
==========================================================================
==========================================================================
*/



// Frame macros

$cd /raid/quake/id1/models/player_4
$origin 0 -6 24
$base base		
$skin skin

$frame axrun1 axrun2 axrun3 axrun4 axrun5 axrun6

$frame rockrun1 rockrun2 rockrun3 rockrun4 rockrun5 rockrun6

//
// standing
//
$frame stand1 stand2 stand3 stand4 stand5

$frame axstnd1 axstnd2 axstnd3 axstnd4 axstnd5 axstnd6
$frame axstnd7 axstnd8 axstnd9 axstnd10 axstnd11 axstnd12


//
// pain
//
$frame axpain1 axpain2 axpain3 axpain4 axpain5 axpain6

$frame pain1 pain2 pain3 pain4 pain5 pain6


//
// death
//

$frame axdeth1 axdeth2 axdeth3 axdeth4 axdeth5 axdeth6
$frame axdeth7 axdeth8 axdeth9

$frame deatha1 deatha2 deatha3 deatha4 deatha5 deatha6 deatha7 deatha8
$frame deatha9 deatha10 deatha11

$frame deathb1 deathb2 deathb3 deathb4 deathb5 deathb6 deathb7 deathb8
$frame deathb9

$frame deathc1 deathc2 deathc3 deathc4 deathc5 deathc6 deathc7 deathc8
$frame deathc9 deathc10 deathc11 deathc12 deathc13 deathc14 deathc15

$frame deathd1 deathd2 deathd3 deathd4 deathd5 deathd6 deathd7
$frame deathd8 deathd9

$frame deathe1 deathe2 deathe3 deathe4 deathe5 deathe6 deathe7
$frame deathe8 deathe9

//
// attacks
//
$frame nailatt1 nailatt2

$frame light1 light2

$frame rockatt1 rockatt2 rockatt3 rockatt4 rockatt5 rockatt6

$frame shotatt1 shotatt2 shotatt3 shotatt4 shotatt5 shotatt6

$frame axatt1 axatt2 axatt3 axatt4 axatt5 axatt6

$frame axattb1 axattb2 axattb3 axattb4 axattb5 axattb6

$frame axattc1 axattc2 axattc3 axattc4 axattc5 axattc6

$frame axattd1 axattd2 axattd3 axattd4 axattd5 axattd6


// movement animation ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

void() bot_stand1		=[	1,	bot_stand2	] {bot_stand();};
void() bot_stand2		=[	2,	bot_stand3	] {bot_stand();};
void() bot_stand3		=[	3,	bot_stand4	] {bot_stand();};
void() bot_stand4		=[	4,	bot_stand5	] {bot_stand();};
void() bot_stand5		=[	5,	bot_stand6	] {bot_stand();};
void() bot_stand6		=[	6,	bot_stand7	] {bot_stand();};
void() bot_stand7		=[	7,	bot_stand8	] {bot_stand();};
void() bot_stand8		=[	8,	bot_stand9	] {bot_stand();};
void() bot_stand9		=[	9,	bot_stand10	] {bot_stand();};
void() bot_stand10	=[	10,	bot_stand11	] {bot_stand();};
void() bot_stand11	=[	11,	bot_stand12	] {bot_stand();};
void() bot_stand12	=[	12,	bot_stand1	] {bot_stand();};
	
void() bot_walk1		=[	1,	bot_walk2	] {bot_walk();};
void() bot_walk2		=[	2,	bot_walk3	] {bot_walk();};
void() bot_walk3		=[	3,	bot_walk4	] {bot_walk();};
void() bot_walk4		=[	4,	bot_walk5	] {bot_walk();};
void() bot_walk5		=[	5,	bot_walk6	] {bot_walk();};
void() bot_walk6		=[	6,	bot_walk7	] {bot_walk();};
void() bot_walk7		=[	7,	bot_walk8	] {bot_walk();};
void() bot_walk8		=[	8,	bot_walk9	] {bot_walk();};
void() bot_walk9		=[	9,	bot_walk10	] {bot_walk();};
void() bot_walk10		=[	10,	bot_walk11	] {bot_walk();};
void() bot_walk11		=[	11,	bot_walk12	] {bot_walk();};
void() bot_walk12		=[	12,	bot_walk1	] {bot_walk();};

void()  bot_jump1		=[	13,	bot_jump2	] {jump_forward();bot_walk();};
void()  bot_jump2		=[	14,	bot_jump3	] {bot_walk();};
void()  bot_jump3		=[	15,	bot_jump4	] {bot_walk();};
void()  bot_jump4		=[	16,	bot_jump5	] {bot_walk();};
void()  bot_jump5 	=[	17,	bot_jump6	] {bot_walk();};
void()  bot_jump6		=[	18,	bot_jump7	] {bot_walk();};
void()  bot_jump7		=[	19,	bot_walk1	] {bot_walk();};

void()  bot_push1		=[	20,	bot_push2	] {bot_walk();};
void()  bot_push2		=[	21,	bot_push3	] {bot_walk();};
void()  bot_push3		=[	22,	bot_push4	] {bot_walk();};
void()  bot_push4		=[	23,	bot_push5	] {bot_walk();};
void()  bot_push5 	=[	24,	bot_push6	] {bot_walk();};
void()  bot_push6		=[	25,	bot_push7	] {bot_walk();};
void()  bot_push7		=[	26,	bot_walk1	] {bot_walk();};

//--------------------------------
//		bot_kickflip1
//--------------------------------

void()  bot_kickflip1		=[	27,	bot_kickflip2	] 
{
	self.busting = TRUE;
	jump_forward();
	bot_walk();
};
void()  bot_kickflip2		=[	28,	bot_kickflip3	] {bot_walk();};
void()  bot_kickflip3		=[	29,	bot_kickflip4	] {bot_walk();};
void()  bot_kickflip4		=[	30,	bot_kickflip5	] {bot_walk();};
void()  bot_kickflip5		=[	31,	bot_kickflip6	] 
{
	self.busting = FALSE;
	self.frags = self.frags + 1;						//get points for Kickflip
	msgUpdateFragsToAll (self.fClientNo, self.frags);
	bot_walk();
};
void()  bot_kickflip6		=[	32,	bot_walk1	] {bot_walk();};


//--------------------------------
//		bot_frontgrab1
//--------------------------------

void()  bot_frontgrab1		=[	37,	bot_frontgrab2	] 
{
	self.busting = TRUE;
	jump_forward();
	bot_walk();
};
void()  bot_frontgrab2		=[	38,	bot_frontgrab3	] {bot_walk();};
void()  bot_frontgrab3		=[	39,	bot_frontgrab4	] {bot_walk();};
void()  bot_frontgrab4		=[	40,	bot_frontgrab5	] {bot_walk();};
void()  bot_frontgrab5 		=[	41,	bot_frontgrab6	] {bot_walk();};
void()  bot_frontgrab6		=[	42,	bot_frontgrab7	] 
{
	self.busting = FALSE;
	self.frags = self.frags + 1;						//get points for frontgrab
	msgUpdateFragsToAll (self.fClientNo, self.frags);
	bot_walk();
};
void()  bot_frontgrab7		=[	43,	bot_walk1	] {bot_walk();};

//--------------------------------
//		bot_oneeighty1
//--------------------------------

void()  bot_oneeighty1		=[	44,	bot_oneeighty2	] 
{
	self.busting = TRUE;
	jump_forward();
	bot_walk();
};
void()  bot_oneeighty2		=[	45,	bot_oneeighty3	] {bot_walk();};
void()  bot_oneeighty3		=[	46,	bot_oneeighty4	] {bot_walk();};
void()  bot_oneeighty4		=[	47,	bot_oneeighty5	] {bot_walk();};
void()  bot_oneeighty5 		=[	48,	bot_oneeighty6	] {bot_walk();};
void()  bot_oneeighty6		=[	49,	bot_oneeighty7	] 
{
	self.busting = FALSE;
	self.frags = self.frags + 1;						//get points for oneeighty
	msgUpdateFragsToAll (self.fClientNo, self.frags);
	bot_walk();
};
void()  bot_oneeighty7		=[	50,	bot_walk1	] {bot_walk();};


void() th_respawn =
{
	self.think = respawn_bot;
	self.nextthink = time + 1;
};

void()  bot_die1		=[	$deatha1,	bot_die2	] {};
void()  bot_die2		=[	$deatha2,	bot_die3	] {};
void()  bot_die3		=[	$deatha3,	bot_die4	] {self.solid = SOLID_NOT; bot_drop_pack(); };
void()  bot_die4		=[	$deatha4,	bot_die5	] {};
void()  bot_die5		=[	$deatha5,	bot_die6	] {};
void()  bot_die6		=[	$deatha6,	bot_die7	] {};
void()  bot_die7		=[	$deatha7,	bot_die8	] {};
void()  bot_die8		=[	$deatha8,	bot_die9	] {};
void()  bot_die9		=[	$deatha9,	bot_die10	] {};
void()  bot_die10		=[	$deatha10,	bot_die11	] {};
void()  bot_die11		=[	$deatha11,	th_respawn	] {};

void()  bot_dieb1		=[	$deathb1,	bot_dieb2	 ] {};
void()  bot_dieb2		=[	$deathb2,	bot_dieb3	 ] {};
void()  bot_dieb3		=[	$deathb3,	bot_dieb4	 ] {self.solid = SOLID_NOT; bot_drop_pack(); };
void()  bot_dieb4		=[	$deathb4,	bot_dieb5	 ] {};
void()  bot_dieb5		=[	$deathb5,	bot_dieb6	 ] {};
void()  bot_dieb6		=[	$deathb6,	bot_dieb7	 ] {};
void()  bot_dieb7		=[	$deathb7,	bot_dieb8	 ] {};
void()  bot_dieb8		=[	$deathb8,	bot_dieb9	 ] {};
void()  bot_dieb9		=[	$deathb9,	th_respawn	 ] {};

void()  bot_diec1		=[	$deathc1,	bot_diec2	 ] {};
void()  bot_diec2		=[	$deathc2,	bot_diec3	 ] {};
void()  bot_diec3		=[	$deathc3,	bot_diec4	 ] {self.solid = SOLID_NOT; bot_drop_pack(); };
void()  bot_diec4		=[	$deathc4,	bot_diec5	 ] {};
void()  bot_diec5		=[	$deathc5,	bot_diec6	 ] {};
void()  bot_diec6		=[	$deathc6,	bot_diec7	 ] {};
void()  bot_diec7		=[	$deathc7,	bot_diec8	 ] {};
void()  bot_diec8		=[	$deathc8,	bot_diec9	 ] {};
void()  bot_diec9		=[	$deathc9,	bot_diec10	 ] {};
void()  bot_diec10	=[	$deathc10,	bot_diec11	 ] {};
void()  bot_diec11	=[	$deathc11,	bot_diec12	 ] {};
void()  bot_diec12	=[	$deathc12,	bot_diec13	 ] {};
void()  bot_diec13	=[	$deathc13,	bot_diec14	 ] {};
void()  bot_diec14	=[	$deathc14,	bot_diec15	 ] {};
void()  bot_diec15	=[	$deathc15,	th_respawn	 ] {};

void()  bot_died1		=[	$deathd1,	bot_died2	 ] {};
void()  bot_died2		=[	$deathd2,	bot_died3	 ] {};
void()  bot_died3		=[	$deathd3,	bot_died4	 ] {self.solid = SOLID_NOT; bot_drop_pack(); };
void()  bot_died4		=[	$deathd4,	bot_died5	 ] {};
void()  bot_died5		=[	$deathd5,	bot_died6	 ] {};
void()  bot_died6		=[	$deathd6,	bot_died7	 ] {};
void()  bot_died7		=[	$deathd7,	bot_died8	 ] {};
void()  bot_died8		=[	$deathd8,	bot_died9	 ] {};
void()  bot_died9		=[	$deathd9,	th_respawn	 ] {};

void()  bot_diee1		=[	$deathe1,	bot_diee2	 ] {};
void()  bot_diee2		=[	$deathe2,	bot_diee3	 ] {};
void()  bot_diee3		=[	$deathe3,	bot_diee4	 ] {self.solid = SOLID_NOT; bot_drop_pack(); };
void()  bot_diee4		=[	$deathe4,	bot_diee5	 ] {};
void()  bot_diee5		=[	$deathe5,	bot_diee6	 ] {};
void()  bot_diee6		=[	$deathe6,	bot_diee7	 ] {};
void()  bot_diee7		=[	$deathe7,	bot_diee8	 ] {};
void()  bot_diee8		=[	$deathe8,	bot_diee9	 ] {};
void()  bot_diee9		=[	$deathe9,	th_respawn	 ] {};

void() bot_painsound =
{
local float		rs;

	if (self.health < 0)
		return;

	if (damage_attacker.classname == "teledeath")
	{
		sound (self, CHAN_VOICE, "player/teledth1.wav", 1, ATTN_NONE);
		return;
	}

// water pain sounds
	if (self.watertype == CONTENT_WATER && self.waterlevel == 3)
	{
		DeathBubbles(1);
		if (random() > 0.5)
		{
				sound (self, CHAN_VOICE, "player/drown1.wav", 1, ATTN_NORM);
		}
		else
		{
				sound (self, CHAN_VOICE, "player/drown2.wav", 1, ATTN_NORM);
		}
		return;
	}

	if (self.watertype == CONTENT_SLIME || self.watertype == CONTENT_LAVA)
	{
		if (random() > 0.5)
		{
				sound (self, CHAN_VOICE, "player/lburn1.wav", 1, ATTN_NORM);
		}
		else
		{
				sound (self, CHAN_VOICE, "player/lburn2.wav", 1, ATTN_NORM);
		}
		return;
	}

	if (self.pain_finished > time)
	{
		self.axhitme = 0;
		return;
	}
	self.pain_finished = time + 0.5;

// don't make multiple pain sounds right after each other

// ax pain sound
	if (self.axhitme == 1)
	{
		self.axhitme = 0;
		sound (self, CHAN_VOICE, "player/axhit1.wav", 1, ATTN_NORM);
		return;
	}
	

	rs = rint((random() * 5) + 1);

	self.noise = "";
	
	
	if (rs == 1)
		self.noise = "player/pain1.wav";
	else if (rs == 2)
		self.noise = "player/pain2.wav";
	else if (rs == 3)
		self.noise = "player/pain3.wav";
	else if (rs == 4)
		self.noise = "player/pain4.wav";
	else if (rs == 5)
		self.noise = "player/pain5.wav";
	else
		self.noise = "player/pain6.wav";

	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	return;
};

void() bot_deathsound =
{
local float		rs;

	// water death sounds
	if (self.waterlevel == 3)
	{
		DeathBubbles(20);
		sound (self, CHAN_VOICE, "player/h2odeath.wav", 1, ATTN_NONE);
		return;
	}
	
	rs = rint ((random() * 4) + 1);
	
	
	if (rs == 1)
		self.noise = "player/death1.wav";
	if (rs == 2)
		self.noise = "player/death2.wav";
	if (rs == 3)
		self.noise = "player/death3.wav";
	if (rs == 4)
		self.noise = "player/death4.wav";
	if (rs == 5)
		self.noise = "player/death5.wav";

	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NONE);
	return;
};



// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void(entity attacker, float damage)	bot_pain =
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{
	if (self.pain_finished > time)
		return;

	if (random() < 0.25)
		return;
	
	//PainSound();
	bot_painsound();

	if (random() > 0.75)
		return;
	
	self.pain_finished = time + 1;
};



// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void() gib_bot =
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{
		ThrowGib ("progs/h_player.mdl", self.health);

	//ThrowGib ("progs/h_player.mdl", self.health);
	

	ThrowGib ("progs/gib1.mdl", self.health);
	ThrowGib ("progs/gib2.mdl", self.health);
	setmodel (self, "progs/gib3.mdl");
	setsize (self, '0 0 0', '0 0 0');

	self.deadflag = DEAD_DEAD;
	self.think = th_respawn;
	self.nextthink = time + 1;

	if (damage_attacker.classname == "teledeath")
	{
		sound (self, CHAN_VOICE, "player/teledth1.wav", 1, ATTN_NONE);
		return;
	}

	if (damage_attacker.classname == "teledeath2")
	{
		sound (self, CHAN_VOICE, "player/teledth1.wav", 1, ATTN_NONE);
		return;
	}
		
	if (random() < 0.5)
		sound (self, CHAN_VOICE, "player/gib.wav", 1, ATTN_NONE);
	else
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NONE);

};




// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void() bot_die =
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{
local float i;

// we're turning the bot off here and playing his death scene

	self.deadflag = DEAD_DYING;
	self.solid = SOLID_NOT;
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	self.movetype = MOVETYPE_TOSS;
	if (self.velocity_z < 10)
		self.velocity_z = self.velocity_z + random()*300;

	//if (self.health < -40)
	//	{						Squirt outcommented
	gib_bot();	
	return;
	//	}
	
	//DeathSound();
	bot_deathsound();

	//setmodel(self, "progs/player.mdl");
	//setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);

	i = floor(random() * 5);

	if (i == 0)
		bot_die1();
	else if (i == 1)
		bot_dieb1();
	else if (i == 2)
		bot_diec1();
	else if (i == 3)
		bot_died1();
	else
		bot_diee1();
	
};






// ------------------------------------------------
string() bot_name =
// ------------------------------------------------
{
	local float	r;
	r = floor(random() * 16) + 1;	//1 - 16

	if (r == 1)return "Jarvis";			//Jarvis
	else if (r == 2) return "Malignus";		//Malignus
	else if (r == 3) return "Juggernaut";		//Juggernaut
	else if (r == 4) return "Loki";			//Loki
	else if (r == 5) return "Hades";		//Hades
	else if (r == 6) return "Aby";		//Aby
	else if (r == 7) return "Xian";		//Xian
	else if (r == 8) return "R66";			//R66
	else if (r == 9) return "Garan";		//Garan
	else if (r == 10) return "Tola";		//Tola
	else if (r == 11) return "Jath";		//Jath
	else if (r == 12) return "Crow";		//Crow
	else if (r == 13) return "Sensei";		//Sensei
	else if (r == 14) return "Borok";		//Borok
	else if (r == 15) return "Nihilus";		//Nihilus
	else return "Breath";			//Breath
};

//-------------------------------------------
void(entity bot) give_name =
//-------------------------------------------
{
	local entity	a_bot;
	local float	name_ok;
	local string	new_name;

	name_ok = FALSE;

	while(name_ok == FALSE)
	{
		a_bot = world;
		name_ok = TRUE;
		new_name = bot_name();
		a_bot = find(world, netname, new_name);
		if (a_bot != world && a_bot.netname == new_name)
			name_ok = FALSE;
	}
	bot.netname = new_name;
};

// ------------------------------------------------
void() respawn_bot =
// ------------------------------------------------
{

local entity spot;


	CopyToBodyQue (self);				//Squirt - make a visible body
// putting him back in game
	spot = SelectSpawnPoint();
	self.origin = spot.origin + '0 0 1';
	self.angles = spot.angles;
	self.fixangle = TRUE;	
	spawn_tfog (self.origin);
	spawn_tdeath (self.origin, self);
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	makevectors(self.angles);
	self.velocity = self.velocity + v_forward*20;

// making him normal again
	setmodel(self, "progs/skater.mdl");
	setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
	
	self.deadflag = DEAD_NO;
	self.takedamage = DAMAGE_AIM;
	self.ideal_yaw = self.angles * '0 1 0';
	self.yaw_speed = 20;
	self.view_ofs = '0 0 22';
	self.frame = $stand1;
	self.button1 = 90;

// finishing his characteristics
	self.items = IT_SHOTGUN;
	self.currentammo = self.ammo_shells = self.ammo_shells + 100;//Squirt - stamina
	self.weapon = IT_SHOTGUN;
	self.health = 100;
	self.classname = "bot";

	self.enemy = world;
	self.goalentity = world;
	self.search_time = 0;

// making him stand for a bit
	self.pausetime = time + random();				//Squirt - random() : 5
	self.nextthink = time + 0.1 + random();
	self.think = self.th_stand;

	self.talk_subject = 2;
	self.talk_time = time + 3;
};

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
void(entity bot) put_bot_in_server =
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
{
local float clientno; 
local entity plr;

	clientno = clientNextAvailable(); 
	if (clientno == -1) 
		{ 
		bprint( "game not started correctly\nset 'maxplayers' to 16 and restart\n" ); 
		return; 
		} 

	clientSetUsed( clientno ); 
	bot.fClientNo = clientno; 

	if (teamplay)
		{
		plr = find(world, classname, "player");
		plr.team = 1;
		plr.fPants = 3;
		plr.fShirt = 4;
		plr.colormap = plr.fClientNo;
		msgUpdateColorsToAll( plr.fClientNo, plr.fShirt, plr.fPants );
 
		if (bot.team == plr.team)			//player team
			{	
			bot.fPants = plr.fPants;
			bot.fShirt = plr.fShirt;
			}
		else					//enemy team
			{
			bot.fPants = 13;
			bot.fShirt = 12;
			}
		}
	else						//normal deathmatch
		{
		bot.fPants = floor(random() * 14); 
		bot.fShirt = floor(random() * 14); 
		}

	bot.colormap = clientno + 1; 
	msgUpdateNameToAll( bot.fClientNo, bot.netname ); 
	msgUpdateColorsToAll( bot.fClientNo, bot.fShirt, bot.fPants ); 
	msgUpdateFragsToAll( bot.fClientNo, bot.frags ); 
	bprint(bot.netname); 
	bprint(" joins the game\n");
};


// ------------------------------------------------
void(float teem) create_bot =
// ------------------------------------------------
{
local entity bot, spot, plr,temps;

	bot_num = bot_num + 1;
	if (bot_num > 15)
	{
		bprint( "Can't spawn bot : too many clients\n" ); 
		return;
	}

// initializing the entity
	bot = spawn();
	spot = SelectSpawnPoint();
	bot.origin = spot.origin + '0 0 1';
	bot.angles = spot.angles;
	bot.fixangle = TRUE;	
	spawn_tfog (bot.origin);
	spawn_tdeath (bot.origin, bot);
	bot.solid = SOLID_SLIDEBOX;
	bot.movetype = MOVETYPE_STEP;

// defining his animation
	setmodel(bot, "progs/skater.mdl");
	bot.frame = 1;
	bot.th_stand = bot_stand1;
	bot.th_walk = bot_walk1;
	bot.th_pain = bot_pain;
	bot.th_die = bot_die;

// arming and naming him
	bot.items = bot.items | IT_SHOTGUN;
	bot.currentammo = bot.ammo_shells = bot.ammo_shells + 100;	//Squirt- stamina
	bot.weapon = IT_SHOTGUN;
	//give_random_weapon(bot);					Squirt
	bot.health = 100;
	bot.max_health = 100;						//Squirt
	bot.classname = "bot";
// polishing him up
	
	setsize (bot, VEC_HULL_MIN, VEC_HULL_MAX);
	bot.ideal_yaw = bot.angles * '0 1 0';
	bot.yaw_speed = 20;
	bot.view_ofs = '0 0 22';
	bot.takedamage = DAMAGE_AIM;
	bot.attack_state = 0;
	bot.button1 = 90;
	bot.nextthink = time + 0.1 + random();
	bot.think = bot.th_walk;

	//bot.netname = bot_name();
	give_name(bot);

	if (teamplay)
		bot.team = teem;

	put_bot_in_server(bot); 

	if (!bot.fClientNo) 
		remove(bot);
	
	bot.talk_subject = 3;
	bot.talk_time = time + 3;

	bot.bot_skill = skill;
	bot.flags = bot.flags + FL_PARTIALGROUND;
};

//++++++++++++++++++++	WAYPOINT	++++++++++++++++++++++++++++++

//void() wp_think =
//{
//	self.nextthink = time + 0.1;
//	if (self.search_time > time)
//		setmodel (self, "progs/s_explod.spr");
//	else
//		setmodel (self, "progs/s_bubble.spr");
//};


void( vector org) create_wp =
{
	local entity	wp;
	wp = spawn();
	wp.origin = org;
	wp.movetype = MOVETYPE_NONE;
	wp.solid = SOLID_TRIGGER;
	wp.classname = "waypoint";
	
	wp_num = wp_num + 1;

	//setmodel (wp, "progs/Null.spr");
	//setmodel (wp, "progs/s_bubble.spr");
	
	//wp.think = wp_think;
	//wp.nextthink = time + 0.1;
};

void() check_create_wp =
{
	local entity	wp;
	local entity	player;	

	self.nextthink = time + 0.1;
	if (wp_num > 120)					//Waypoint limit
		return;

	player = find(world, classname, "player");
	wp = findradius(player.origin, 100);
	while(wp)
	{
		if (wp.classname == "waypoint")
			return;
		wp = wp.chain;
	}
	if ((player.flags & FL_ONGROUND))
		create_wp(player.origin);
};


void() create_wpc =
{
	local entity	wpc;

	wpc = spawn();
	wpc.origin = '0 0 0';
	wpc.movetype = MOVETYPE_NONE;
	wpc.solid = SOLID_NOT;
	wpc.classname = "waypoint_creator";
	
	wpc.think = check_create_wp;
	wpc.nextthink = time + 0.1;
};


//+++++++++++++++++++++++++++++++++		TEAMPLAY	++++++++++++++++++++++++++++++++

//called by player
void() command_follow =
{
	local entity	bot;
	
	if (!teamplay)
		return;

	bot = findradius(self.origin, 1500);
	while(bot)
	{
		if (bot.classname == "bot" && bot.team == self.team && visible(bot))
		{
			bot.bot_follow = self;
			
			bot.talk_subject = 6;	
			bot.talk_time = time + 1;
			bot.talk_name = self.netname;

			sprint(self, " - ");
			sprint(self, bot.netname);
			sprint(self, " will follow you \n");
		}
		bot = bot.chain;
	}	
};

void() command_roam =
{
	local entity	bot;
	
	if (!teamplay)
		return;

	bot = find(world, classname, "bot");
	while(bot)
	{
		if (bot.team == self.team && bot.bot_follow == self)
		{
			bot.bot_follow = world;

			sprint(self, " - ");
			sprint(self, bot.netname);
			sprint(self, " will continue roaming \n");
		}
		bot = find(bot, classname, "bot");
	}	
};



//-----------------------------------	Skill	--------------------------------------
void() update_skill =
{
	local entity	bot;

	if (b_skill > 3)
		b_skill = 3;
	if (b_skill < 0)
		b_skill = 0;
	
	bot = find(world, classname, "bot");
	while(bot)
	{
		bot.bot_skill = b_skill;
		bot = find(bot, classname, "bot");
	}

	//bprint(" - skill has changed to ");
	//bprint(ftos(b_skill));
	//bprint("\n");
};

void() check_change_skill =
{
	local entity	bot;
	local entity	player;
	local float	better_bots;

	self.nextthink = time + 10;

	if (!change_skill)
		return;	

	better_bots = 0;
	player = find(world, classname, "player");
	
	bot = find(world, classname, "bot");
	while(bot)
	{
		if (bot.frags > player.frags)
			better_bots = better_bots + 1;
		bot = find(bot, classname, "bot");
	}

	if (better_bots == 0)
		b_skill = b_skill + 0.2;
	else if (better_bots < (bot_num * 0.3))
		b_skill = b_skill + 0.1;
	else if (better_bots < (bot_num * 0.4))
		b_skill = b_skill - 0.1;
	else if (better_bots < (bot_num * 0.5))
		b_skill = b_skill - 0.2;
	else if (better_bots < (bot_num * 0.6))
		b_skill = b_skill - 0.3;
	else
		b_skill = b_skill - 0.4;

	update_skill();
};


void() create_skill_changer =
{
	local entity	sc;

	sc = spawn();
	sc.origin = '0 0 0';
	sc.movetype = MOVETYPE_NONE;
	sc.solid = SOLID_NOT;
	sc.classname = "skill_changer";
	
	sc.think = check_change_skill;
	sc.nextthink = time + 10;
};



void() switch_change_skill =
{
local entity	bot;

	if (change_skill == FALSE)
	{
		b_skill = skill;
		update_skill();
		change_skill = TRUE;
		bprint(" - skill of every bot changed to normal skill (default 1)\n");
		bprint(" - auto-adjusting skill : ON\n");
	}
	else if (change_skill == TRUE)
	{
		b_skill = skill;
		update_skill();
		change_skill = FALSE;
		bprint(" - skill of every bot changed to normal skill (default 1)\n");
		bprint(" - auto-adjusting skill : OFF\n");
	}
};

