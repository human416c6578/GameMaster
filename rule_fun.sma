#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <fun>
#include <gm>

#pragma reqlib "deathrun"
native tempRespawn_disable();

const TASK_BURN = 1000
#define ID_BURN (taskid - TASK_BURN)
#define BURN_DURATION args[0]


new g_msgDamage, g_msgScreenFade;

new g_flameSpr, g_smokeSpr;

new const sprite_grenade_fire[] = "sprites/flame.spr"
new const sprite_grenade_smoke[] = "sprites/black_smoke3.spr"

new g_players[MAX_PLAYERS];

public plugin_init()
{
	register_rule("Remove Respawn", "respawn_remove_enable", "", "rule_fun", 1000, 1);

	register_rule("Blind all players for 2 seconds", "blind_enable", "", "rule_fun", 300, 1);

	register_rule("25% chance to kill one random player", "randPlayer_kill", "", "rule_fun", 50, 2);

	register_rule("Kill a player you choose", "player_kill", "", "rule_fun", 1000, 1, 1);

	register_rule("Return all players to ct base", "players_return", "", "rule_fun", 3000, 1);

	register_rule("Slap a random player", "player_slap", "", "rule_fun", 20, 3)

	register_rule("Slap all players", "players_slap", "", "rule_fun", 150, 3);
	
	register_rule("Burn all players for 10 seconds", "players_burn", "", "rule_fun", 3000, 1);

	register_rule("Strip all players' weapons", "players_strip", "", "rule_fun", 1500, 1);

	g_msgScreenFade = get_user_msgid("ScreenFade") 
	g_msgDamage = get_user_msgid("Damage")

}

public plugin_precache(){
	g_flameSpr = engfunc(EngFunc_PrecacheModel, sprite_grenade_fire)
	g_smokeSpr = engfunc(EngFunc_PrecacheModel, sprite_grenade_smoke)
}

public respawn_remove_enable(){
	tempRespawn_disable();
}

public blind_enable(id){
	new players[MAX_PLAYERS], iNum;
	get_players(players, iNum, "ae", "CT");
	for (new i=0;i<iNum;i++) { 
	   Flash(players[i])
	}
}

public randPlayer_kill(id){
	new players[MAX_PLAYERS], iNum;
	get_players(players, iNum, "ae", "CT");
	new rand = random_num(0, iNum);

	if(random_num(0, 100)>60){
		user_kill(players[rand], 1);
	}
}

public player_kill(id){
	new menu = menu_create( "\rKill Menu!:", "menu_handler" );

	new iNum;
	get_players(g_players, iNum, "ae", "CT");

	for(new i;i<iNum;i++)
	{
		new item[128], szName[128];
		get_user_name(g_players[i], szName, sizeof(szName));
		format(item, sizeof(item), "\w%s \rKILL", szName);
		menu_additem(menu, item, "");
	}
	
	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
	
	menu_display( id, menu, 0 );

	return PLUGIN_HANDLED;
}

public menu_handler(id, menu, item){
	if(!is_user_connected(id))
		return PLUGIN_CONTINUE;

	user_kill(g_players[item]);

	menu_destroy( menu );
	return PLUGIN_HANDLED;
}

public players_return(id){
	new players[MAX_PLAYERS], iNum;
	get_players(players, iNum, "ae", "CT");
	for(new i;i<iNum;i++){
		ExecuteHamB(Ham_CS_RoundRespawn, players[i]);
	}
}

public player_slap(id){
	new players[MAX_PLAYERS], iNum;
	get_players(players, iNum, "ae", "CT");
	new rand = random_num(0, iNum);

	user_slap(players[rand], 0);
}

public players_slap(id){
	new players[MAX_PLAYERS], iNum;
	get_players(players, iNum, "ae", "CT");
	for(new i;i<iNum;i++){
		user_slap(players[i], 0);
	}
}

public players_burn(id){
	new players[MAX_PLAYERS], iNum;
	get_players(players, iNum, "ae", "CT");
	for(new i;i<iNum;i++){
		Burn(players[i]);
	}
}

public players_strip(id){
	new players[MAX_PLAYERS], iNum;
	get_players(players, iNum, "ae", "CT");
	for(new i;i<iNum;i++){
		fm_strip_user_weapons(players[i]);
		fm_give_item(players[i], "weapon_knife");
	}
}

public Flash(id) {
	message_begin(MSG_ONE,g_msgScreenFade,{0,0,0},id) 
	write_short( 1<<15 ) 
	write_short( 1<<10 )
	write_short( 1<<12 )
	write_byte( 255 ) 
	write_byte( 255 ) 
	write_byte( 255 ) 
	write_byte( 255 ) 
	message_end()
	emit_sound(id,CHAN_BODY, "weapons/flashbang-2.wav", 1.0, ATTN_NORM, 0, PITCH_HIGH)
}

public Burn(id){
	// Heat icon
	message_begin(MSG_ONE_UNRELIABLE, g_msgDamage, _, id)
	write_byte(0) // damage save
	write_byte(0) // damage take
	write_long(DMG_BURN) // damage type
	write_coord(0) // x
	write_coord(0) // y
	write_coord(0) // z
	message_end()
	
	// Our task params
	static params[1]
	params[0] = 20 // duration
	
	// Set burning task on victim
	set_task(0.1, "burning_flame", id+TASK_BURN, params, sizeof params)
}

public burning_flame(args[1], taskid)
{
	// Player died/disconnected
	if (!is_user_alive(ID_BURN))
		return;
	
	// Get player origin and flags
	static Float:originF[3], flags
	pev(ID_BURN, pev_origin, originF)
	flags = pev(ID_BURN, pev_flags)
	
	// In water or burning stopped
	if ((flags & FL_INWATER) || BURN_DURATION < 1)
	{
		// Smoke sprite
		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
		write_byte(TE_SMOKE) // TE id
		engfunc(EngFunc_WriteCoord, originF[0]) // x
		engfunc(EngFunc_WriteCoord, originF[1]) // y
		engfunc(EngFunc_WriteCoord, originF[2]-50.0) // z
		write_short(g_smokeSpr) // sprite
		write_byte(random_num(15, 20)) // scale
		write_byte(random_num(10, 20)) // framerate
		message_end()
		
		return;
	}
	
	// Fire slow down
	static Float:velocity[3]
	pev(ID_BURN, pev_velocity, velocity)
	xs_vec_mul_scalar(velocity, 0.5, velocity)
	set_pev(ID_BURN, pev_velocity, velocity)
	
	// Get victim's health
	static health
	health = pev(ID_BURN, pev_health)
	
	// Take damage from the fire
	if (health - 2 > 0)
		set_pev(ID_BURN, pev_health, float(health - 2))
	else
	{
		// Kill victim
		user_kill(ID_BURN);
		
		// Smoke sprite
		engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
		write_byte(TE_SMOKE) // TE id
		engfunc(EngFunc_WriteCoord, originF[0]) // x
		engfunc(EngFunc_WriteCoord, originF[1]) // y
		engfunc(EngFunc_WriteCoord, originF[2]-50.0) // z
		write_short(g_smokeSpr) // sprite
		write_byte(random_num(15, 20)) // scale
		write_byte(random_num(10, 20)) // framerate
		message_end()
		
		return;
	}
	
	// Flame sprite
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_SPRITE) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]+random_float(-5.0, 5.0)) // x
	engfunc(EngFunc_WriteCoord, originF[1]+random_float(-5.0, 5.0)) // y
	engfunc(EngFunc_WriteCoord, originF[2]+random_float(-10.0, 10.0)) // z
	write_short(g_flameSpr) // sprite
	write_byte(random_num(5, 10)) // scale
	write_byte(200) // brightness
	message_end()
	
	// Decrease task cycle count
	BURN_DURATION -= 1;
	
	// Keep sending flame messages
	set_task(0.5, "burning_flame", taskid, args, sizeof args)
}
