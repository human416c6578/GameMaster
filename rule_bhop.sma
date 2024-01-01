#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <engine>
#include <hamsandwich>
#include <gm>

new bool:g_bForceJump;
new bool:g_bSlowDown;

public plugin_init()
{
	register_rule("Remove bunnyhop", "bunnyhop_remove_enable", "bunnyhop_remove_disable", "rule_bhop", 7000, 1);
	register_rule("NoSpeed bunnyhop", "bunnyhop_nospeed_enable", "bunnyhop_nospeed_disable", "rule_bhop", 5000, 1);
	register_rule("Force 100 AirAccelerate", "force_aa_100_enable", "force_aa_100_disable", "rule_bhop", 5000, 1);

	register_rule("Players can't stop jumping", "force_jumping_enable", "force_jumping_disable", "rule_bhop", 1500, 1);
}

public client_PreThink(id) {
	if(!g_bForceJump || !is_user_alive(id) || cs_get_user_team(id) == CS_TEAM_T)
		return PLUGIN_CONTINUE;
	// Code from CBasePlayer::Jump (player.cpp)		Make a player jump automatically
	new flags = entity_get_int(id, EV_INT_flags)

	if (flags & FL_WATERJUMP)
		return PLUGIN_CONTINUE
	if ( entity_get_int(id, EV_INT_waterlevel) >= 2 )
		return PLUGIN_CONTINUE
	if ( !(flags & FL_ONGROUND) )
		return PLUGIN_CONTINUE

	new Float:velocity[3]
	entity_get_vector(id, EV_VEC_velocity, velocity)
	velocity[2] = 250.0
	entity_set_vector(id, EV_VEC_velocity, velocity)

	if (g_bSlowDown){
		limit_user_velocity(id, 300);
	}

	entity_set_int(id, EV_INT_gaitsequence, 6)	// Play the Jump Animation
	
	return PLUGIN_HANDLED
}

public force_aa_100_enable(id){
	server_cmd("sv_airaccelerate 10");
}

public force_aa_100_disable(){
	server_cmd("sv_airaccelerate 9999999");
}

public bunnyhop_remove_enable(id){
	server_cmd("bh_enabled 0");
}

public bunnyhop_remove_disable(){
	server_cmd("bh_enabled 1");
}

public bunnyhop_nospeed_enable(id){
	g_bSlowDown = true;
}

public bunnyhop_nospeed_disable(){
	g_bSlowDown = false;
}

public force_jumping_enable(id){
	g_bForceJump = true;
}

public force_jumping_disable(){
	g_bForceJump = false;
}

public limit_user_velocity(id, value){
	new Float:velocity[3], Float:x, Float:y;
	get_user_velocity(id, velocity);
	new Float:speed = floatpower(floatpower(velocity[0],2.0) + floatpower(velocity[1],2.0),0.5);
	if(speed > value){
		x = velocity[0]/speed;
		y = velocity[1]/speed;
		velocity[0] = x * value;
		velocity[1] = y * value;
	}
	set_user_velocity(id, velocity);
	return PLUGIN_CONTINUE;
}