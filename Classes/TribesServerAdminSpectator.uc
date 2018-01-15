class TribesServerAdminSpectator extends Engine.MessagingSpectator
	config;

struct PlayerMessage
{
	var PlayerReplicationInfo   PRI;
	var String					Text;
	var Name					Type;
	var PlayerMessage 			Next;	// pointer to next message
};

var array<string>	Messages;

var byte NextMsg, LastMsg;
var config byte ReceivedMsgMax;

var config bool bClientMessages;
var config bool bTeamMessages;
var config bool bVoiceMessages;
var config bool bLocalizedMessages;
var TribesServerAdmin Server;

event Destroyed()
{
	// HACK: Seems like the TribesServerAdmin Pointer becomes corrupted
	Server.Spectator = None;
	Super.Destroyed();
}

event PreBeginPlay()
{
	Super.PreBeginPlay();
	NextMsg = 0;
	LastMsg = 0;
	if (ReceivedMsgMax < 10)
		ReceivedMsgMax = 10;

	Messages.Length = ReceivedMsgMax;
}

function int LastMessage()
{
	return LastMsg;
}

function string NextMessage(out int msg)
{
local string str;

	if (msg == NextMsg)
		return "";

	str = Messages[msg];
	msg++;

	if (msg >= ReceivedMsgMax)
		msg = 0;

	return str;
}

// Implemented Rotating
function AddMessage(PlayerReplicationInfo PRI, String S, name Type)
{
	// Add the message to the array
	Messages[NextMsg] = FormatMessage(PRI, S, Type);
	NextMsg++;

	if (NextMsg >= ReceivedMsgMax)
		NextMsg = 0;

	if (NextMsg == LastMsg)
		LastMsg++;

	if (LastMsg >= ReceivedMsgMax)
		LastMsg = 0;
}

function Dump()
{
	//log("----Begin Dump----");
	if (PlayerReplicationInfo == None)
		//log("NO PLAYER REPLICATION INFO");
	if (Pawn == None) {
		return;
	}
		//log("NO PAWN");
	//log("NextMsg:"@NextMsg);
	//log("LastMsg:"@LastMsg);
	//log("ReceivedMsgMax:"@ReceivedMsgMax);
	//log("Msg[0]"@Messages[0]);
	//log("Msg[1]"@Messages[1]);
	//log("Msg[2]"@Messages[2]);
	//log("Msg[3]"@Messages[3]);
	//log("Msg[4]"@Messages[4]);
	//log("Msg[5]"@Messages[5]);
}

function String FormatMessage(PlayerReplicationInfo PRI, String Text, name Type)
{
	local String Message;

	// format Say and TeamSay messages
	if (PRI != None) {
		if (Type == 'Say' && PRI == PlayerReplicationInfo)
			Message = Text;
		else if (Type == 'Say')
			Message = PRI.PlayerName$": "$Text;
		else if (Type == 'TeamSay')
			Message = "["$PRI.PlayerName$"]: "$Text;
		else
			Message = "("$Type$") "$Text;
	}
	else if (Type == 'Console')
		Message = Text;
	else
		Message = "("$Type$") "$Text;

	return Message;
}

event ClientMessage( coerce string S, optional Name Type )
{
	//Log("Admin Received a ClientMessage");
	if (bClientMessages)
		AddMessage(None, S, Type);
}

function TeamMessage( PlayerReplicationInfo PRI, coerce string S, name Type)
{
	//Log("Admin Received a TeamMessage");
	if (bTeamMessages)
		AddMessage(PRI, S, Type);
}

function ClientVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID)
{
	//Log("Admin Received a ClientVoiceMessage");
	// do nothing?
}

#if IG_TRIBES3	// michaelj:  Added optional string
simulated event ReceiveLocalizedMessage( class<LocalMessage> Message, optional int Switch, optional Core.Object Related1, optional Core.Object Related2, optional Object OptionalObject, optional String OptionalString )
#else
simulated event ReceiveLocalizedMessage( class<LocalMessage> Message, optional int Switch, optional Core.Object Related1, optional Core.Object Related2, optional Object OptionalObject )
#endif
{
	//Log("Admin Received a LocalizedMessage");
	// do nothing?
}

// A couple of functions that should not do anything
function ClientGameEnded() {}

// Report end game in log
function GameHasEnded()
{
	AddMessage(None, "GAME HAS ENDED", 'Console');
}

defaultproperties
{
     ReceivedMsgMax=32
     bClientMessages=True
     bTeamMessages=True
     bLocalizedMessages=True
	 PlayerReplicationInfoClass=Class'Gameplay.TribesReplicationInfo'
}
