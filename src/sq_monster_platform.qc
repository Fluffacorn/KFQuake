/*
 * Code here gives monster an extra "hitbox" for monsters on top of them.
 * It just detects if the player is standing on top of the mosnter.
 *
 * In sqate, if the player is standing on the monster, it will let the player execute some trick, making the player jump.
 * Idea is to chain tricks with the mosnters
 *
 * In darkplaces engine I already played like this, because the engine lets you walk on the monsters like platforms.
 * Other engines are trying to strick with the original quake quirks, which is where this piece of code comes from.
 * This code doesn't fix the "sliding on top of monsters", just lets the mod know that the player is on the monster
 * */

// check if player is standing on mosnter platform
void() monster_platform_touch =
{
        if (other.classname == "player")
                other.standing_on_monster = TRUE;
};

// platform follow monster
void() monster_platform_think =
{
        if (self.owner && self.owner.health > 0)
        {
                setorigin(self, self.owner.origin);
                self.nextthink = time + 0.01;
        }
        else
                remove(self);
};

// plarform to detect if player is on mosnter
void() monster_create_platform =
{
        local entity platform;
        local vector pmin, pmax;

        platform = spawn();
        platform.owner = self;
        platform.solid = SOLID_BSP;
        platform.movetype = MOVETYPE_NONE;
        platform.classname = "monster_platform";

        pmin_x = self.mins_x * 1;
        pmin_y = self.mins_y * 1;
        pmin_z = self.maxs_z;

        pmax_x = self.maxs_x * 1;
        pmax_y = self.maxs_y * 1;
        pmax_z = self.maxs_z + 1;

        setsize(platform, pmin, pmax);
        setorigin(platform, self.origin);

        platform.touch = monster_platform_touch;
        platform.think = monster_platform_think;
        platform.nextthink = time + 0.01;

        platform.monster_top = TRUE;
};


