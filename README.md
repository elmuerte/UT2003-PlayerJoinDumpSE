# UT2003-PlayerJoinDumpSE

PlayerJoinDumpSE is an UT2003 Server add-on with the only purpose to dump player join information in the log file.
You have to install this add-on as a server actor. So add to you server configuration (UT2003.ini), the following line:

```
[Engine.GameEngine]
ServerActors=PlayerJoinDumpSE.PlayerJoinDumpSE
```

When the server starts you should see the following output in the log file:

```
[~] Starting PlayerJoinDumpSE version ###
[~] Michiel 'El Muerte' Hendriks - 
[~] The Drunk Snipers - http://www.drunksnipers.com
```

If you see these lines then the add-on has been started, everytime a player joins the server a line with the following format will be added to the log file:

```
[PLAYER_JOIN] <date time> <name> <client ip>:<client port> 
	<netspeed> <cdkey hash>
```

When a player changes his name you will see the following line:

```
[PLAYER_NAME_CHANGE] <date time> <old name> <new name>
```

And when the player parts you will see the following line:

```
[PLAYER_PART] <date time> <name>
```

These field are divided by TAB characters (ASCII 9) For example:

```
[PLAYER_JOIN] 2003/1/9 19:3:55	El_Muerte_[TDS]	127.0.0.1:1851	2000	
	ac7cce83526c5ba6c738cb3c85fd2ac6
[PLAYER_NAME_CHANGE] 2003/1/9 19:4:21	El_Muerte_[TDS]	bertus
[PLAYER_PART] 2003/1/9 19:4:29	El_Muerte_[TDS]
```

From version 101 it's possible to log to an external log file. To enable this feature, put the following line into your server configuration (UT2003.ini) And from version 102 you can also specify a log directory. If you set the sLogDir variable the directory has to exist. Also it has to end with a forward slash ("/")

```
[PlayerJoinDumpSE.PlayerJoinDumpSE]
bExternalLog=true
sLogDir="Logs/"
```

Now for _every_ game a log file will be created with the following format:

```
PlayerJoin_<game port>_<year>_<month>_<day>_<hour>_<minute>_<second>.txt
```

But this can be changed by editing the config setting sFileFormat (since version 103)
You can use the following replacements:

- %P server Port
- %Y current Year
- %M current Month
- %D current Day
- %H current Hour
- %I current mInute
- %S current Second
- %W day of the week
- %N server Name 

Not all characters are supported in the filename, for example '.', these will be translated to an underscore '_' 
