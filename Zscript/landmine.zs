//------------------------------------------------------------------------------
// Landmines intended for mapping. Super simple and copied from Matt's barrels & IEDs, but i guess it works.
// 'HDNeutralLandmine' scans for both players and enemies, 'HDHostileLandmine' only for players		-Slogstin
//------------------------------------------------------------------------------

class HDNeutralLandmine : HDMobBase{

	default{
		-solid +shootable
		+dontgib
		+hdmobbase.doesntbleed
		+hdmobbase.headless
		+noblood
		-countkill
		-ismonster
		+hdmobbase.noshootablecorpse
		radius 12;height 4;
		health 200;mass 10000;gibhealth 10000;
		painchance 0;
		pushfactor 0.1;
		meleerange 50;

		obituary "%o appears to have trodden on a mine.";
		hitobituary "%o appears to have trodden on a mine.";
		attacksound "MineTrigger";

		tag "Landmine";
	}
	
	
	void A_MineScan(){
		blockthingsiterator itt=blockthingsiterator.create(self,meleerange);
		while(itt.Next()){
			actor hitactor=itt.thing;
			if(
				hitactor
				&&hitactor.bshootable
				&&!hitactor.bdormant
				&&!hitactor.bnotarget
				&&!hitactor.bnevertarget
				&&(hitactor.bismonster||hitactor.player)
				&&(!hitactor.player||!(hitactor.player.cheats&CF_NOTARGET))
				&&hitactor.health>0
				&&checksight(hitactor)
				&& Distance3D(hitactor) <= meleerange
				)
				{
				tracer=hitactor;
				setstatelabel("melee");
				return;
			}
		}
	}
	
	
	//Just the Frag Grenade Explosion, nothing fancy.	-Slogstin
	static void FragBlast(HDActor caller){
		distantnoise.make(caller,"world/rocketfar");
		DistantQuaker.Quake(caller,4,35,512,10);
		caller.A_StartSound("world/explode",CHAN_BODY,CHANF_OVERLAP);
		caller.A_AlertMonsters();
		caller.A_SpawnChunksFrags();
		caller.A_HDBlast(
			pushradius:256,pushamount:128,fullpushradius:96,
			fragradius:HDCONST_ONEMETRE*12
		);
	}

	states {
    spawn:
        LNDM AB 10 A_MineScan;
        loop;
    death:
        LNDM C 0 A_NoBlocking();
        ---- C 0 A_SetSize(-1, default.height);
    melee:
		LNDM A 0 {
            HDMobAI.Frighten(self, 90);
        }
        LNDM C 0 A_Vocalize(attacksound);
        ---- C 15;
        LNDM C 0 {
            A_NoBlocking();
            A_SetSize(-1, deathheight);
            bsolid = false;
            HDNeutralLandmine.FragBlast(self);
            actor xpl = spawn("WallChunker", self.pos - (0, 0, 1), ALLOW_REPLACE);
            xpl.target = self.target;
            xpl.master = self.master;
            xpl.stamina = self.stamina;
            xpl = spawn("HDExplosion", self.pos - (0, 0, 1), ALLOW_REPLACE);
            xpl.target = self.target;
            xpl.master = self.master;
            xpl.stamina = self.stamina;
        } stop;
    }
}



class HDHostileLandmine : HDNeutralLandmine{
	
	void A_HostileMineScan(){
		blockthingsiterator itt=blockthingsiterator.create(self,meleerange);
		while(itt.Next()){
			actor hitactor=itt.thing;
			if(
				hitactor
				&&hitactor.bshootable
				&&!hitactor.bdormant
				&&!hitactor.bnotarget
				&&!hitactor.bnevertarget
				&&hitactor.player
				&&(!hitactor.player||!(hitactor.player.cheats&CF_NOTARGET))
				&&hitactor.health>0
				&&checksight(hitactor)
				&& Distance3D(hitactor) <= meleerange
				)
				{
				tracer=hitactor;
				setstatelabel("melee");
				return;
			}
		}
	}
	
	states {
    spawn:
        LNDM AB 10 A_HostileMineScan;
        loop;
	}
}