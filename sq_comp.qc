//-------------------
void() comp_start =
//-------------------
{
local entity	bot;

	comp_started = TRUE;
	comp_timelimit = time + 30;		//2 minutes

//reset frags to 0!!!
	bot = find(world, classname, "bot");
	while(bot)
	{
		bot.frags = 0;
		msgUpdateFragsToAll (bot.fClientNo, bot.frags);
		bot = find(bot, classname, "bot");
	}

	bot = find(world, classname, "player");
	while(bot)
	{
		bot.frags = 0;
		msgUpdateFragsToAll (bot.fClientNo, bot.frags);
		bot = find(bot, classname, "player");
	}
//all frags reset

	bprint("Freestyle Competition has started!\n");
};


//--------------------
void() comp_check_time =
//--------------------
{
local entity plr, best;
local float num; 

	if(comp_started == FALSE)
		return;

	if(comp_timelimit < time)	//time is over
	{
	best = world; 

	plr = nextent(world); 
	while(plr) 
	{ 
		if ((plr.classname == "player" || plr.classname == "bot") && plr.frags > best.frags) 
			{ 
			best = plr; 
			num = num + 1;
			} 
		if (plr.classname == "bot") 
			remove(plr); 

		plr = nextent(plr);
	} 
	
		bprint("\n\n");
		bprint(best.netname); 
		bprint(" is the winner!\n"); 
		execute_changelevel();
		comp_started = FALSE;
	}
};