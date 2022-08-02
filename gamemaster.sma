
#include <amxmodx>
#include <cstrike>
#include <hamsandwich>
#include <cromchat>
#include <credits>

#pragma reqlib "vip"

native isPlayerVip(id);

#define PLUGIN "T GameMaster"
#define VERSION "0.1"
#define AUTHOR "MrShark45"

#define MAX_RULES 100

enum _: eRule
{
	eName[128],
	eFunctionEnable[128],
	eFunctionDisable[128],
	ePlugin[128],
	eCost,
	ePerRound,
	eReturn
}

new Array: g_aRules;

new g_iRulesCredits;

new g_iRules_perRound[MAX_RULES];

new g_iCTDeaths;

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_clcmd("say /gm", "gm_menu");
	
	RegisterHam(Ham_Killed, "player", "player_killed");

	//Terro WIN
	register_logevent("terrorist_won" , 6, "3=Terrorists_Win", "3=Target_Bombed") 

	register_event("HLTV", "event_newRound", "a", "1=0", "2=0") 

	g_aRules = ArrayCreate( eRule );

	CC_SetPrefix("&x04[LLG]") 

}

public plugin_natives(){
	register_library("gm")

	register_native("register_rule", "register_rule_native");
}

public event_newRound(){
	g_iRulesCredits = 0;
	g_iCTDeaths = 0;
	for(new i;i<ArraySize(g_aRules);i++){
		new rule[eRule];
		ArrayGetArray(g_aRules, i, rule);
		if(rule[eFunctionDisable]){
			callfunc_begin(rule[eFunctionDisable], rule[ePlugin]);
			callfunc_end();
		}

		g_iRules_perRound[i] = 0;
		
	}
}

public terrorist_won(){
	new terrorists[32],iNum, terro;
	get_players(terrorists, iNum, "ae", "TERRORIST");
	terro = terrorists[0];
	new gain = isPlayerVip(terro)? 100 : 50;
	new credits = (g_iRulesCredits/2) + gain;
	
	set_user_credits(terro,  get_user_credits(terro) + credits);
	CC_SendMessage(terro, "&x01Ai primit &x04%d &x01credite pentru ca ai &x04castigat &x01runda!", credits);
	CC_SendMessage(terro, "&x01Ai primit &x04%d &x01credite pentru ca au murit &x04%d &x06CT!", g_iCTDeaths*2, g_iCTDeaths);
	CC_SendMessage(terro, "&x01Credite curente: &x04%d&x01!", get_user_credits(terro));
}

public player_killed(victim, attacker){
	new terrorists[MAX_PLAYERS], iNum, terro;
	get_players(terrorists, iNum, "ae", "TERRORIST");
	terro = terrorists[0];

	if(attacker != victim && is_user_alive(attacker)){
		if(cs_get_user_team(attacker) == CS_TEAM_T){
			new gain = isPlayerVip(attacker)? 10 : 5;
			new credits = get_user_credits(attacker);
			set_user_credits(attacker, get_user_credits(attacker) + gain);
			CC_SendMessage(attacker, "&x01Ai primit &x04%d &x01credite pentru ca ai &x07ucis &x01un &x06CT&x01!", gain);
			CC_SendMessage(attacker, "&x01Credite curente: &x04%d&x01!", credits+gain);
		}
		else{
			new gain = isPlayerVip(attacker)? 40 : 20;
			new credits = get_user_credits(attacker);
			CC_SendMessage(attacker, "&x01Ai primit &x04%d &x01credite pentru ca ai &x07ucis teroristul&x01!", gain);
			set_user_credits(attacker, get_user_credits(attacker) + (g_iRulesCredits/4) + gain);
			CC_SendMessage(attacker, "&x01Credite curente: &x04%d&x01!", credits+gain);
		}
	}
	if(is_user_alive(terro) && !is_user_alive(attacker)){
		new gain = isPlayerVip(terro)? 4 : 2;
		new credits = get_user_credits(terro);
		set_user_credits(terro, credits + gain);
		g_iCTDeaths++;
	}
}

public register_rule_native(numParams){
	new rule_name[128], rule_function_enable[128], rule_function_disable[128], rule_plugin[128];
	get_string(1, rule_name, sizeof(rule_name));
	get_string(2, rule_function_enable, sizeof(rule_function_enable));
	get_string(3, rule_function_disable, sizeof(rule_function_disable));
	get_string(4, rule_plugin, sizeof(rule_plugin));
	new rule_cost = get_param(5);
	new rule_perRound = get_param(6);
	new rule_return = get_param(7);
	new rule[eRule];
	copy( rule[ eName ], charsmax( rule_name ), rule_name );
	copy( rule[ eFunctionEnable ], charsmax( rule_function_enable ), rule_function_enable );
	copy( rule[ eFunctionDisable ], charsmax( rule_function_disable ), rule_function_disable );
	copy( rule[ ePlugin ], charsmax( rule_plugin ), rule_plugin );
	rule[eCost] = rule_cost;
	rule[ePerRound] = rule_perRound;
	rule[eReturn] = rule_return;
	ArrayPushArray(g_aRules, rule);
}

public gm_menu(id, page){
	if(cs_get_user_team(id) != CS_TEAM_T)
		return PLUGIN_CONTINUE;
	new title[128];
	new credits = get_user_credits(id);
	format(title, sizeof(title), "\y%d credits \w- \rGameMaster Menu!:", credits);
	new menu = menu_create( title, "menu_handler" );

	for(new i;i<ArraySize(g_aRules);i++)
	{
		new rule[eRule], item[128];
		ArrayGetArray(g_aRules, i, rule);
		if(credits >= rule[eCost])
			format(item, sizeof(item), "\w%s \y%d", rule[eName], rule[eCost]);
		else
			format(item, sizeof(item), "\w%s \r%d", rule[eName], rule[eCost]);
		menu_additem(menu, item, "");
	}
	
	menu_setprop( menu, MPROP_EXIT, MEXIT_ALL );
	
	menu_display( id, menu, page );

	return PLUGIN_CONTINUE;
}

public menu_handler(id, menu, item){
	if(!is_user_connected(id))
		return PLUGIN_CONTINUE;
	if(cs_get_user_team(id) != CS_TEAM_T)
		return PLUGIN_CONTINUE;
	
	if(item < 0){
		menu_destroy( menu );
		return PLUGIN_CONTINUE;
	}
		
	
	new rule[eRule];
	ArrayGetArray(g_aRules, item, rule);
	new credits = get_user_credits(id);

	if(credits < rule[eCost]){
		CC_SendMessage(id, "&x01Nu ai suficente credite pentru aceasta regula!");
		return PLUGIN_CONTINUE;
	}

	if(g_iRules_perRound[item] >= rule[ePerRound] && rule[ePerRound]){
		CC_SendMessage(id, "&x01Ai depasit limita de utilizari pe runda!");
		return PLUGIN_CONTINUE;
	}

	new call = callfunc_begin(rule[eFunctionEnable], rule[ePlugin])
	if(call > 0) {
		callfunc_push_int(id);
		CC_SendMessage(0, "&x01Regula &x04%s &x01a fost activata!", rule[eName]);
		g_iRulesCredits += rule[eCost];
		new ret = callfunc_end();
		new newCredits = credits-rule[eCost];
		set_user_credits(id, newCredits);

		g_iRules_perRound[item]++;

		if(rule[eReturn]){
			menu_destroy( menu );
			return PLUGIN_HANDLED;
		}
			
			
	}
	/*switch(call){
		case -1: client_print(id, print_chat, "Function not found");
		case -2: client_print(id, print_chat, "Plugin not found");
		case 0: client_print(id, print_chat, "Runtime error");
		case 1: client_print(id, print_chat, "Success");
	}*/

	gm_menu(id, item/7);
	menu_destroy( menu );
	return PLUGIN_HANDLED;
}