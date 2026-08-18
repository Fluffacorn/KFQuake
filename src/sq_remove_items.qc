void(entity item) remove_kind =
{
        /*
         * This function removes specific items types based on a bitwise sum defined in `sq_remove_items`
         *
         * Items are represented like this:
         *  - weapons:  1
         *  - armors:   2
         *  - runes:    4
         *  - suit:     8
         *  - health:   16
         *  - ammo:     32
         *
         * So when we want to remove something, we just set `sq_remove_items` to it.
         * If we want to remove weapons, we set it to 1, or if we want to remove the runes, we set it 4.
         *
         * If we want to remove multiple kinds of items, we just set the variable to a sum of items.
         * So if we want to remove weapons (1) and runes (4), we set the sum of those two (1 + 4 = 5).
         * If we want to remove weapons (1), runes (4) and health (16), we set the sum (1 + 4 + 16 = 21).
         * To remove everything, we sum all of those up (which is 63).
         *
         * We use this function inside PlaceItem function (items.qc)
         */

        local float sq_remove_items = cvar("sq_remove_items");
        local float itr[6]; // here we store items that we'll remove

        if (sq_remove_items >= RM_AMMO)
        {
                itr[5] = RM_AMMO;
                sq_remove_items -= RM_AMMO;
        }
        if (sq_remove_items >= RM_HP)
        {
                itr[4] = RM_HP;
                sq_remove_items -= RM_HP;
        }
        if (sq_remove_items >= RM_SUIT)
        {
                itr[3] = RM_SUIT;
                sq_remove_items -= RM_SUIT;
        }
        if (sq_remove_items >= RM_RUNE)
        {
                itr[2] = RM_RUNE;
                sq_remove_items -= RM_RUNE;
        }
        if (sq_remove_items >= RM_ARMOR)
        {
                itr[1] = RM_ARMOR;
                sq_remove_items -= RM_ARMOR;
        }
        if (sq_remove_items >= RM_WPN)
        {
                itr[0] = RM_WPN;
                sq_remove_items -= RM_WPN;
        }

        // finally, we remove the items
        if (    // weapons
                (itr[0] && (item.classname == "weapon_nailgun" ||
                            item.classname == "weapon_supernailgun" ||
                            item.classname == "weapon_supershotgun" ||
                            item.classname == "weapon_rocketlauncher" ||
                            item.classname == "weapon_grenadelauncher" ||
                            item.classname == "weapon_lightning")) ||

                // armors
                (itr[1] && (item.classname == "item_armor1" ||
                            item.classname == "item_armor2" ||
                            item.classname == "item_armorInv")) ||

                // runes
                (itr[2] && (item.classname == "item_artifact_invisibility" ||
                            item.classname == "item_artifact_invulnerability" ||
                            item.classname == "item_artifact_super_damage")) ||

                // suit
                (itr[3] && (item.classname == "item_artifact_envirosuit")) ||

                // health
                (itr[4] && (item.classname == "item_health")) ||

                // ammo
                (itr[5] && (item.classname == "item_spikes" ||
                            item.classname == "item_rockets" ||
                            item.classname == "item_cells")) ||

                // shells won't be removed if we're using stamina
                (itr[5] && !sq_stamina && item.classname == "item_shells")
        )
                remove(item);
}
