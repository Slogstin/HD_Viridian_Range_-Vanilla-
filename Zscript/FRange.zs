//Normal punch dummy, that doesn't jump when hit.	-Slogstin
class SpaghettiPunchDummy:HDActor replaces PunchDummy{
	default{
		//$Category "Misc/Hideous Destructor/"
		//$Title "Punching Dummy"
		//$Sprite "BEXPB0"

		+noblood +shootable +ghost
		height 54;radius 12;health TELEFRAG_DAMAGE;
		xscale 1.22;
		yscale 1.69;
		translation "0:255=%[0,0,0]:[1.7,1.3,0.4]";
	}
	override int damagemobj(
		actor inflictor,actor source,int damage,
		name mod,int flags,double angle
	){
		if(!inflictor||!source)return 0;
		if(
			inflictor is "HDFistPuncher"
			||(inflictor.player && inflictor.player.readyweapon is "HDFist")
		){
//			vel.z+=damage*0.1;
			string d="u";
			if(damage>100){
				d="x";
				A_StartSound("misc/p_pkup",CHAN_WEAPON,attenuation:0.6);
			}else if(damage>60)d="y";
			else if(damage>30)d="g";
			if(!hd_debug&&source)source.A_Log(
				string.format(StringTable.Localize("$RANGE_BARDMG1"),d,damage)
			,true);
			A_StartSound("misc/punch",CHAN_AUTO);
		}
		return 0; //indestructible
	}
	states{
	spawn:
	pain:
		BEXP B -1;
	}
}


//A combination of the Firing Range ammo boxes and the Weapon Crates.
//Basically acts as an infinite Weapon crate.	-Slogstin
class HDWeaponBox:switchabledecoration{
	default{
		+usespecial
		height 20;radius 15;gravity 0.8;
		activation THINGSPEC_Switch|THINGSPEC_ThingTargets;
	}
	states{
	active:
	inactive:
		WPBX A 5{
			A_StartSound("misc/chat2",CHAN_AUTO);
			busespecial=false;
		}
		WPBX B 18{
				Array<class<HDWeapon> > WeaponsToDrop;
				for (int i = 0; i < AllActorClasses.Size(); ++i)
				{
					let CurrWeapon =  HDWeapon(GetDefaultByType(AllActorClasses[i]));
					if (CurrWeapon && !CurrWeapon.bWIMPY_WEAPON && !CurrWeapon.bCHEATNOTWEAPON && !CurrWeapon.bDONTNULL && CurrWeapon.WeaponBulk() > 0 && !CurrWeapon.bINVBAR && CurrWeapon.Refid != "")
					{
						WeaponsToDrop.Push(CurrWeapon.GetClass());
					}
				}

				if (WeaponsToDrop.Size() > 0)
				{
					class<HDWeapon> PickedWeapon = WeaponsToDrop[random(0, WeaponsToDrop.Size() - 1)];
					A_SpawnItemEx(PickedWeapon, 0, 0, 0, frandom(0.5, 1.0), 0, frandom(3.0, 6.0), random(0, 359), SXF_NOCHECKPOSITION);
				}
			}
	spawn:
		WPBX A -1{
			busespecial=true;
		}
	}
}


//	Just a stripped down Frag Grenade. Kinda.	-Slogstin
class FR2_Football:HDactor{ 

	default{
		+missile 
		+bounceonactors 
		+usebouncestate
		bouncetype "Hexen";
		bouncesound "Ball/Bounce";
		radius 5;
		+forcexybillboard;
		+solid;
		height 10;
		damagetype "none";
		scale 0.7;
		obituary "How did %o die to a football!!?";
		radiusdamagefactor 0.04;
		pushfactor 1.4;
		maxstepheight 2;
		mass 20;
		gravity HDCONST_GRAVITY;
	}
	
	override bool used(actor user){
		angle = user.angle;
		A_StartSound(bouncesound);
		bmissile = true;
		bsolid = true;
		if(hdplayerpawn(user) && hdplayerpawn(user).incapacitated) {
			A_ChangeVelocity(5,0,2,CVF_RELATIVE);
		} else {
			A_ChangeVelocity(9,0,4.5,CVF_RELATIVE);
		}
		return true;
	}
	
	states{
		spawn:
			FTBL AB 4 nodelay;
			wait;
		bounce:
			---- A 0
				{
				bmissile = true;
				vel *= 0.9;
				if (abs(vel.x) < 0.1 && abs(vel.y) < 0.1)
				{
                vel = (0, 0, 0);
                setstatelabel("rest");
				}
			}
        ---- A 1;
        goto spawn;
		
		rest:
        ---- A -1;
        wait;

		death:
			---- A 1;
			goto rest;
	}
}

class FR2_Plant1:HDActor{
	default {
	height 15;
	radius 7;
	mass 300;
	scale 0.5;
	+solid;
	}
	
	states{
	spawn:
		VAS1 A -1;
	}
}

class FR2_Plant2:FR2_Plant1{
states{
	spawn:
		VAS2 A -1;
	}
}

class FR2_Plant3:FR2_Plant1{
	default {
	height 30;
	}
	
	states{
	spawn:
		VAS3 A -1;
	}
}

class FR2_MessDecPot:FR2_Plant1{
	default {
	-solid;
	mass 3000;
	scale 1;
	}
	
	states{
	spawn:
		VRDC A -1;
	}
}

class FR2_MessDecMug:FR2_Plant1{
	default {
	-solid;
	mass 3000;
	scale 1;
	}
	
	states{
	spawn:
		VRDC B -1;
	}
}

class FR2_Box:HDActor{
	default {
	height 15;
	radius 7;
	mass 50;
//	scale 0.5;
//	+solid;
	}
	
	states{
	spawn:
		UBOX A -1;
	}
}


class FR2_Chair:HDActor{
	default {
	height 15;
	radius 7;
	mass 150;
//	scale 0.5;
	+solid;
	}
	
	states{
	spawn:
		EXC1 A -1;
	}
}


class FR2_Trashcan:HDActor{
	default {
	height 30;
	radius 10;
	mass 300;
//	scale 0.5;
	+solid;
	}
	
	states{
	spawn:
		TRSH B -1;
	}
}


class FR2_Extinguisher:HDActor{
	default {
	height 20;
	radius 10;
	mass 300;
	scale 0.4;
	+solid;
	}
	
	states{
	spawn:
		FRXT A -1;
	}
}


class MrGunBot:ScriptedMarine
{
	default{
	mass 5000;
	translation "GunBot";
	+Invulnerable;
	-SHOOTABLE}
}

class Jenny:ScriptedMarine
{
	default{
	mass 5000;
	translation "Jenny";
	+Invulnerable;
	-SHOOTABLE}
}

class WarHog:ScriptedMarine
{
	default{
	mass 5000;
	translation "WarHog";
	+Invulnerable;
	-SHOOTABLE}
}

class HailStorm:ScriptedMarine
{
	default{
	mass 5000;
	translation "HailStorm";
	+Invulnerable;
	-SHOOTABLE}
}


class FR2_Plush1:HDActor{
	default {
	height 15;
	radius 7;
	mass 50;
//	scale 0.5;
//	+solid;
	}
	
	states{
	spawn:
		OCPL B -1;
	}
}

class FR2_Plush2:HDActor{
	default {
	height 15;
	radius 7;
	mass 50;
//	scale 0.5;
//	+solid;
	}
	
	states{
	spawn:
		OCPL A -1;
	}
}

class FR2_Plush3:HDActor{
	default {
	height 15;
	radius 7;
	mass 50;
//	scale 0.5;
//	+solid;
	}
	
	states{
	spawn:
		OCPL C -1;
	}
}

class FR2_Plush4:HDActor{
	default {
	height 15;
	radius 7;
	mass 50;
//	scale 0.5;
//	+solid;
	}
	
	states{
	spawn:
		OCPL D -1;
	}
}