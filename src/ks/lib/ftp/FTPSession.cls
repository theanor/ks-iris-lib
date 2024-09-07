Include Ensemble

Class ks.lib.ftp.FTPSession Extends %Net.FtpSession
{

Property LocalInterface As %String(MAXLEN = 250);

Method %OnNew(localInterface As %String) As %Status
{
	s:$d(localInterface) ..LocalInterface = localInterface
	return $$$OK
}

Method Connect(Server As %String, Username As %String, Password As %String, Port As %Integer = 21) As %Boolean
{
	Set ..ReturnCode=0,..ReturnMessage=""
	If ..Connected Quit ..error(503,"Already connected to a server; disconnect first")
	Set ..device=..GetDevice()
	If ..LegacySSL,..SSLConfiguration'="" {
		$$$TRACE("Connecting to "_Server_" from interface "_..LocalInterface)
		Open ..device:(Server:Port:"CST"::8192:8192:/NOXY:/BINDTO=..LocalInterface:/TLS=$select(..SSLCheckServerIdentity:..SSLConfiguration_"||"_Server,1:..SSLConfiguration)):..Timeout Else  Quit ..error(530,"Unable to open connection to "_Server_" on port "_Port_" SSLConfiguration "_..SSLConfiguration)
	} Else {
		$$$TRACE("Connecting to "_Server_" from interface "_..LocalInterface)
		Open ..device:(Server:Port:"CST"::8192:8192:/NOXY:/BINDTO=..LocalInterface):..Timeout Else  Quit ..error(530,"Unable to open connection to "_Server_" on port "_Port)
	}
	If '..setupIPV6() Quit ..error(530,"Unable to setup IPV6 flag "_Server_" on port "_Port)
	Set ..Connected=1, ok=0
	If '..readResponse() Quit ..returnStatus()
	
	If ..SSLConfiguration'="",'..LegacySSL {
		If '..sendCommand("AUTH TLS")||(..ReturnCode'=234) Quit ..returnStatus()
		Set io=$io Use ..device:(/TLS=$select(..SSLCheckServerIdentity:..SSLConfiguration_"||"_Server,1:..SSLConfiguration)) Use io
	}
	Set ok=..ChangeUser(Username,Password)
	If 'ok,..Connected {
		Set code=..ReturnCode,message=..ReturnMessage
		Do ..Logout()
		Set ..ReturnCode=code,..ReturnMessage=message
	}
	#; At this point we will have connected with TLS and sent one message and so will have the certificate to validate server identity
	If ..Connected,..SSLConfiguration'="",..SSLCheckServerIdentity {
		Set io=$io Use ..device
		Set sc=##class(%Net.HttpRequest).CheckSSLCN(Server)
		Use io
		If $$$ISERR(sc) {
			Set return=..error(534,"Failed to validate TLS server host name certificate '"_Server_"'")
			Do ..Logout()
			Quit ..error(534,"Failed to validate TLS server host name certificate '"_Server_"'")
		}
	}
	If ..SSLConfiguration'="",'..LegacySSL {
		If '..sendCommand("PBSZ 0")||(..ReturnCode'=200) Quit ..returnStatus()
		If '..sendCommand("PROT P")||(..ReturnCode'=200) Quit ..returnStatus()
	}
	Set ..CommandTranslateTable=..CommandTranslateTable
	Set ..ServerName=Server
	Quit ok
}

Method setupPORT(ByRef Device As %String, Output ServerName As %String) As %Boolean [ Private ]
{
	If '..Connected Quit ..error(530,"Not logged in, connect first")
	#; Switch to PORT mode and setup the connection
	Set Device=..GetDevice(),ServerName=..ServerName
	#; Open with port 0 which means OS assigns a port number and then lookup what OS assigned.
	If ..SSLConfiguration'="" {
		$$$TRACE("Connecting to "_ServerName_" from interface "_..LocalInterface)
		Open Device:(:0:"SA"::8192:8192:/NOXY:/BINDTO=..LocalInterface:/TLS=$select(..SSLCheckServerIdentity:..SSLConfiguration_"||"_ServerName,1:..SSLConfiguration):/TCPSNDBUF=65536:/TCPRCVBUF=98304):0 Else  Quit ..error(425,"Unable to open listening data connection SSLConfiguration "_..SSLConfiguration)
	} Else {
		$$$TRACE("Connecting to "_ServerName_" from interface "_..LocalInterface)
		Open Device:(:0:"SA"::8192:8192:/NOXY:/BINDTO=..LocalInterface:/TCPSNDBUF=65536:/TCPRCVBUF=98304):0 Else  Quit ..error(425,"Unable to open listening data connection")
	}
	Set io=$IO
	Use ..device Set server=$$$GetTCPLocalIP(0) Use Device Set port=$system.TCPDevice.LocalPort() Use io
	If server[":"||..UseExtensions {
	    Set ftpPort="EPRT |2|"_server_"|"_port_"|"
	} Else {
	    Set ftpPort="PORT "_$translate(server,".",",")_","_(port\256)_","_(port#256)
	}
	If '..sendCommand(ftpPort) Quit 0
	Quit 1
}

Method setupPASV(ByRef Device As %String, Output ServerName As %String) As %Boolean [ Private ]
{
	If '..Connected Quit ..error(530,"Not logged in, connect first")
	#; Switch to PASV mode and setup the connection
#;SML994+ ; send EPSV command for IPV6.
	If ..UseExtensions {
	    If '..sendCommand("EPSV") Quit 0
	    If ..ReturnCode'=229 Quit 0
	    #; Calculate the port and server from the returned message
	    Set port=$P($P(..ReturnMessage,"(",2),")")
	    Set Server=..ServerAddr
	    Set port=$P(port,"|",4)
	} Else {
	    If '..sendCommand("PASV") Quit 0
	    If ..ReturnCode'=227 Quit 0
	    #; Calculate the port and server from the returned message
	    Set port=$P($P(..ReturnMessage,"(",2),")")
	    Set Server=$TR($P(port,",",1,4),",",".")
	    Set port=$P(port,",",5)*256+$P(port,",",6)
	    If ..AutoDetectPrivate {
		    If ..AutoDetectPrivate=2||(..isPrivate(Server)&&('..isPrivate(..ServerAddr))) Set Server=..ServerName
	    }
	}
	Set ServerName=$select(Server=..ServerAddr:..ServerName,1:Server)
	Set Device=..GetDevice()
	If ..SSLConfiguration'="" {
		$$$TRACE("Connecting to "_ServerName_" from interface "_..LocalInterface)
		Open Device:(Server:port:"S"::32768:32768:/NOXY:/BINDTO=..LocalInterface:/TLS=$select(..SSLCheckServerIdentity:..SSLConfiguration_"||"_ServerName,1:..SSLConfiguration):/TCPSNDBUF=65536:/TCPRCVBUF=98304):..Timeout Else  Quit ..error(425,"Unable to open data connection to "_Server_" on port "_port_" SSLConfiguration "_..SSLConfiguration)
	} Else {
		$$$TRACE("Connecting to "_ServerName_" from interface "_..LocalInterface)
		Open Device:(Server:port:"S"::32768:32768:/NOXY:/BINDTO=..LocalInterface:/TCPSNDBUF=65536:/TCPRCVBUF=98304):..Timeout Else  Quit ..error(425,"Unable to open data connection to "_Server_" on port "_port)
	}
	Quit 1
}

}
