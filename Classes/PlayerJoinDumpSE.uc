/////////////////////////////////////////////////////////////////////////////
// filename:    PlayerJoinDumpSE.uc
// version:     102
// author:      Michiel 'El Muerte' Hendriks <elmuerte@drunksnipers.com>
// perpose:     dumping player join information in the UT2003 log file
///////////////////////////////////////////////////////////////////////////////

class PlayerJoinDumpSE extends info config;

var FileLog extlog;
var string extlogname;

var config bool bExternalLog;
var config string sLogDir;

const VERSION = "102";

struct PlayerCache
{
  var string name;
  var string ip;
  var int magic;
};

var array<PlayerCache> cache;

// Return the server's port number.
function string GetServerPort()
{
    local string S;
    local int i;

    // Figure out the server's port.
    S = Level.GetAddressURL();
    i = InStr( S, ":" );
    return Mid(S,i+1);
}

function PostBeginPlay()
{
  local string servaddr;
	log("[~] Starting PlayerJoinDumpSE version "$VERSION);
  if (bExternalLog) 
  {
    servaddr = GetServerPort();
    extlogname = sLogDir$"PlayerJoin_"$servaddr$"_"$Level.Year$"_"$Level.Month$"_"$Level.Day$"_"$Level.Hour$"_"$Level.Minute$"_"$Level.Second;
    extlog = spawn(class'FileLog');
    log("[~] Logging player joins to "$extlogname$".txt");
  }
  log("[~] Michiel 'El Muerte' Hendriks - elmuerte@drunksnipers.com");
  log("[~] The Drunk Snipers - http://www.drunksnipers.com");
  Enable('Tick');
}

function Tick(float DeltaTime)
{   
    CheckPlayerList();
}

function CheckPlayerList()
{
  local int pLoc, magicint;
  local string ipstr;
  local PlayerController PC;

  if (Level.Game.CurrentID > cache.length) cache.length = Level.Game.CurrentID; // make cache larger
  magicint = Rand(MaxInt);
    
	ForEach DynamicActors(class'PlayerController', PC)
  {
    pLoc = PC.PlayerReplicationInfo.PlayerID;
    ipstr = PC.GetPlayerNetworkAddress();
    if (ipstr != "")
    {
      if (cache[pLoc].ip != ipstr)
      {
        cache[pLoc].ip = ipstr;
        cache[pLoc].name = PC.PlayerReplicationInfo.PlayerName;
        LogLine("[PLAYER_JOIN]"@Timestamp()$chr(9)$PC.PlayerReplicationInfo.PlayerName$chr(9)$ipstr$chr(9)$PC.Player.CurrentNetSpeed$chr(9)$PC.GetPlayerIDHash());
      }
      else if (cache[pLoc].name != PC.PlayerReplicationInfo.PlayerName)
      {
        LogLine("[PLAYER_NAME_CHANGE]"@Timestamp()$chr(9)$cache[pLoc].name$chr(9)$PC.PlayerReplicationInfo.PlayerName);
        cache[pLoc].name = PC.PlayerReplicationInfo.PlayerName;
      }
      cache[pLoc].magic = magicint;
    }
  }

  // check parts
  for (pLoc = 0; pLoc < cache.length; pLoc++)
  {
    if ((cache[pLoc].magic != magicint) && (cache[pLoc].magic > -1) && (cache[pLoc].ip != ""))
    {
      cache[pLoc].magic = -1;
      LogLine("[PLAYER_PART]"@Timestamp()$chr(9)$cache[pLoc].name);
    }
  }
}

function LogLine(string logline)
{
  if (bExternalLog) 
  {
    // I can't find a way to close the log at the end of the game, so I use this "work around"
    // if the log isn't closed at the end, nothing is saved :(
    extlog.OpenLog(extlogname);
    extlog.Logf(logline);
    extlog.CloseLog();
  }
  else log(logline, 'PlayerJoinDumpSE');
}

function string Timestamp()
{
  return Level.Year$"/"$Level.Month$"/"$Level.Day$" "$Level.Hour$":"$Level.Minute$":"$Level.Second;
}

defaultproperties 
{
  bExternalLog=false
  sLogDir=""
}
