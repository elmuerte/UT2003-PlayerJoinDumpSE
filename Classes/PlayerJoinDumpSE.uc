/////////////////////////////////////////////////////////////////////////////
// filename:    PlayerJoinDumpSE.uc
// version:     104
// author:      Michiel 'El Muerte' Hendriks <elmuerte@drunksnipers.com>
// perpose:     dumping player join information in the UT2003 log file
///////////////////////////////////////////////////////////////////////////////

// TODO: fix bug

class PlayerJoinDumpSE extends info config;

var FileLog extlog;
var string extlogname;

var config bool bExternalLog;
var config string sLogDir;
var config string sFileFormat;

var bool bScanning;

const VERSION = "104";

struct PlayerCache
{
  var string name;
  var string ip;
  var int magic;
};

var array<PlayerCache> cache;

function string GetServerPort()
{
    local string S;
    local int i;
    S = Level.GetAddressURL();
    i = InStr( S, ":" );
    return Mid(S,i+1);
}

function string GetServerIP()
{
    local string S;
    local int i;
    S = Level.GetAddressURL();
    i = InStr( S, ":" );
    return Left(S,i);
}

function PostBeginPlay()
{
	log("[~] Starting PlayerJoinDumpSE version "$VERSION);
  if (bExternalLog) 
  {
    extlogname = LogFilename();
    extlog = spawn(class'FileLog');
    log("[~] Logging player joins to "$extlogname$".txt");
  }
  log("[~] Michiel 'El Muerte' Hendriks - elmuerte@drunksnipers.com");
  log("[~] The Drunk Snipers - http://www.drunksnipers.com");
  Enable('Tick');
}

function Tick(float DeltaTime)
{   
    if (!bScanning) CheckPlayerList();
}

function CheckPlayerList()
{
  local int pLoc, magicint;
  local string ipstr;
  local PlayerController PC;

  bScanning = true;

  if (Level.Game.CurrentID > cache.length) cache.length = Level.Game.CurrentID+1; // make cache larger
  magicint = Rand(MaxInt);
    
	ForEach DynamicActors(class'PlayerController', PC)
  {
    if (!PC.PlayerReplicationInfo.bBot && !PC.PlayerReplicationInfo.bOnlySpectator)
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
  bScanning = false;
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

function string LogFilename()
{
  local string result;
  result = sFileFormat;
  ReplaceText(result, "%P", GetServerPort());
  ReplaceText(result, "%N", Level.Game.GameReplicationInfo.ServerName);
  ReplaceText(result, "%Y", Right("0000"$string(Level.Year), 4));
  ReplaceText(result, "%M", Right("00"$string(Level.Month), 2));
  ReplaceText(result, "%D", Right("00"$string(Level.Day), 2));
  ReplaceText(result, "%H", Right("00"$string(Level.Hour), 2));
  ReplaceText(result, "%I", Right("00"$string(Level.Minute), 2));
  ReplaceText(result, "%W", Right("0"$string(Level.DayOfWeek), 1));
  ReplaceText(result, "%S", Right("00"$string(Level.Second), 2));
  return sLogDir$result;
}

defaultproperties 
{
  bScanning=false
  bExternalLog=false
  sLogDir=""
  sFileFormat="PlayerJoin_%P_%Y_%M_%D_%H_%I_%S"
}
