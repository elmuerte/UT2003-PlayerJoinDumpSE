/////////////////////////////////////////////////////////////////////////////
// filename:    PlayerJoinDumpSE.uc
// version:     101
// author:      Michiel 'El Muerte' Hendriks <elmuerte@drunksnipers.com>
// perpose:     dumping player join information in the UT2003 log file
///////////////////////////////////////////////////////////////////////////////

class PlayerJoinDumpSE extends Info config;

var bool bInitialized;
var FileLog extlog;
var string extlogname;

var globalconfig bool bExternalLog;

const VERSION = "101";

var string ips[99]; //keep record of max 100 players

// Return the server's port number.
function string GetServerPort()
{
    local string S;
    local int i;

    // Figure out the server's port.
    S = Level.GetAddressURL();
    i = InStr( S, ":" );
    assert(i>=0);
    return Mid(S,i+1);
}

function PostBeginPlay()
{
  local string servaddr;
	if (!bInitialized)
    {
        bInitialized = true;
        log("[~] Starting PlayerJoinDumpSE version "$VERSION);
        if (bExternalLog) 
        {
          servaddr = GetServerPort();
          extlogname = "PlayerJoin_"$servaddr$"_"$Level.Year$"_"$Level.Month$"_"$Level.Day$"_"$Level.Hour$"_"$Level.Minute$"_"$Level.Second;
          extlog = spawn(class 'FileLog');
          log("[~] Logging player joins to "$extlogname$".txt");
        }
        log("[~] Michiel 'El Muerte' Hendriks - elmuerte@drunksnipers.com");
        log("[~] The Drunk Snipers - http://www.drunksnipers.com");
        Enable('Tick');
    }
}

function Tick(float DeltaTime)
{   
    CheckPlayerList();
}

function CheckPlayerList()
{
  local int pLoc;
  local string ipstr;
  local string logline;
  local controller C;

  for( C=Level.ControllerList; C!=None; C=C.nextController )
  {
		if( C.IsA('PlayerController') )
		{
			pLoc = C.PlayerReplicationInfo.PlayerID;
      ipstr = PlayerController(C).GetPlayerNetworkAddress();
      if ((ips[pLoc] != ipstr) && (ipstr != "") && (!C.PlayerReplicationInfo.bIsSpectator))
      {
        ips[pLoc] = ipstr;
        logline = "[PLAYER_JOIN] "$Level.Year$"/"$Level.Month$"/"$Level.Day$" "$Level.Hour$":"$Level.Minute$":"$Level.Second$" "$C.PlayerReplicationInfo.PlayerName$" "$ipstr$" "$PlayerController(C).Player.CurrentNetSpeed;
        if (bExternalLog) 
        {
          // I can't find a way to close the log at the end of the game, so I use this "work around"
          // if the log isn't closed at the end, nothing is saved :(
          extlog.OpenLog(extlogname);
          extlog.Logf(logline);
          extlog.CloseLog();
        }
        else log(logline);
      }
		}
  }
}

defaultproperties 
{
  bExternalLog=false
}
