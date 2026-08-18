//-------------------
void() comp_start =
//-------------------
{
        comp_started = TRUE;
        comp_timelimit = time + 30; // 2 minutes (will add a cvar for this later)

        bprint("Freestyle Competition has started!\n");
};


//--------------------
void() comp_check_time =
//--------------------
{
        local entity plr, best;
        local float num;

        if (comp_started == FALSE) return;

        // competition is over
        if (comp_timelimit < time)
        {
                best = world;
                plr = nextent(world);

                while (plr)
                {
                        if (plr.classname == "player" && plr.frags > best.frags)
                        {
                                best = plr;
                                num = num + 1;
                        }

                        plr = nextent(plr);
                }

                bprint(best.netname);
                bprint(" is the winner!\n");
                execute_changelevel();
                comp_started = FALSE;
        }
};
