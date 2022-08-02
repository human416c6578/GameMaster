#include <amxmodx>
#include <cstrike>
#include <fun>
#include <gm>


#define GRAVITY_TASK 5485

new bool:forceGravity;
new Float:gravity;

public plugin_init()
{
	register_rule("Force gravity 800", "force_gravity_800_enable", "force_gravity_800_disable", "rule_gravity", 800, 1);
	register_rule("Force gravity 400", "force_gravity_400_enable", "force_gravity_400_disable", "rule_gravity", 400, 1);

	register_rule("2000 gravity for 2 seconds", "force_gravity_2000_enable", "force_gravity_2000_disable", "rule_gravity", 300, 1);
	register_rule("Disable gravity for 2 seconds", "disable_gravity_enable", "disable_gravity_disable", "rule_gravity", 300, 1);

	register_rule("Enable FallDamage", "falldamage_enable", "falldamage_disable", "rule_gravity", 750, 1);
}

public task_gravity(){
	if(!forceGravity)
		remove_task(GRAVITY_TASK);
	new players[MAX_PLAYERS];
	new num;
	get_players(players, num, "ae", "CT");
	for(new i;i<num;i++)
		if(get_user_gravity(players[i]) != gravity)
			set_user_gravity(players[i], gravity);
}


public force_gravity_800_enable(id){
	forceGravity = true;
	gravity=1.0;
	set_task(0.1, "task_gravity", GRAVITY_TASK,_, _, "b");
}

public force_gravity_800_disable(){
	forceGravity = false;
	remove_task(GRAVITY_TASK);
}

public force_gravity_400_enable(id){
	forceGravity = true;
	gravity=0.5;

	set_task(0.1, "task_gravity", GRAVITY_TASK,_, _, "b");
}

public force_gravity_400_disable(){
	forceGravity = false;
	remove_task(GRAVITY_TASK);
}

public force_gravity_2000_enable(id){
	server_cmd("sv_gravity 2000");
	set_task(2.0, "force_gravity_2000_disable");
}

public force_gravity_2000_disable(){
	server_cmd("sv_gravity 800");
}

public disable_gravity_enable(id){
	server_cmd("sv_gravity 0");
	set_task(2.0, "disable_gravity_disable");
}

public disable_gravity_disable(){
	server_cmd("sv_gravity 800");
}

public falldamage_enable(){
	server_cmd("mp_falldamage 1");
}

public falldamage_disable(){
	server_cmd("mp_falldamage 0");
}