global function GamemodeBgInit

void function GamemodeBgInit()
{
	AddOnRodeoEndedCallback(OnRodeoBattery)
	AddCallback_GameStateEnter(eGameState.Playing, SetUpPlayers)
	AddCallback_OnClientConnected(SetPlayerMilitia)
	AddCallback_OnPlayerRespawned(SendPlayerAnnouncement)
	AddCallback_OnPilotBecomesTitan(SendTitanAnnouncement)
    AddCallback_OnPlayerGetsNewPilotLoadout(RemoveAntiTitanWeapon)
    Riff_ForceTitanAvailability(eTitanAvailability.Never)
}

void function OnEntityDamage( entity ent, var damageInfo) 
{
	if (ent.IsTitan() && ent.GetTeam() == TEAM_IMC)
	{
		ent.SetHealth(ent.GetMaxHealth())
	}
}

void function RemoveAntiTitanWeapon( entity player, PilotLoadoutDef loadout )
{

}

//player finishes rodeoing
void function OnRodeoBattery( entity player, entity titan )
{
	titan.SetHealth(titan.GetMaxHealth())

	//take away their battery, then add points to their teams score
	AddTeamScore( player.GetTeam() , 3 )
	Rodeo_RemoveAllBatteriesOffPlayer( player )
}

void function SendTitanAnnouncement(entity player, entity titan)
{
	SendPlayerAnnouncement(player)

	AddEntityCallback_OnDamaged(player, OnEntityDamage)
}

void function OnPlayerDeath(entity player, var damageInfo)
{
	if (player.GetTeam() == TEAM_MILITIA)
	{
		//death already counts as one point, so we just add one more
		AddTeamScore(TEAM_IMC, 1)
	}
}

void function SetUpPlayers()
{
    array<entity> players = GetPlayerArray()

	int playerIndex = RandomInt(players.len())
	SpawnPlayerIMCAsTitan(players[playerIndex]);

	for (int i = 0; i < players.len(); i++)
	{
		SendPlayerAnnouncement(players[i])
	}
}

void function SpawnPlayerIMCAsTitan(entity player) 
{
	SetTeam(player, TEAM_IMC)

	player.Die();
	RespawnAsTitan(player, false)
}

void function SendPlayerAnnouncement(entity player)
{
	if (player.GetTeam() == TEAM_IMC)
	{
		SendAnnouncement(player, "Battery Gremlins", "Defend your titan from the gremlins, kill them for points.")
	}
	else
	{
		SendAnnouncement(player, "Battery Gremlins", "Steal the titans batteries for points")
	}
}

void function SetPlayerMilitia(entity player) 
{	
	SetTeam(player, TEAM_MILITIA)
}

void function SendAnnouncement( entity player, string text, string subText = "", float duration = 7.0 )
{
	// Build the message on the client
	string sendMessage
	for ( int textType = 0 ; textType < 2 ; textType++ )
	{
		sendMessage = textType == 0 ? text : subText

		for ( int i = 0; i < sendMessage.len(); i++ )
		{
			Remote_CallFunction_NonReplay( player, "Dev_BuildClientMessage", textType, sendMessage[i] )
		}
	}
	Remote_CallFunction_NonReplay( player, "Dev_PrintClientMessage", duration )
}
