Class ks.lib.ftp.ba.InboundAdapter Extends EnsLib.FTP.InboundAdapter
{

Parameter SETTINGS = "LocalInterface:Connection:selector?context={Ens.ContextSearch/TCPLocalInterfaces}";

/// In a multi-homed system, specify which network interface the TCP connection should go through.  An empty value means to use any interface. <br/>
/// To be able to bind to IPv6 interfaces you may need to enable IPv6 in your InterSystems IRIS instance.  This is done in the System Management Portal under 
/// System Administration > Configuration > Additional Settings > Startup, by editing the IPv6 setting.
Property LocalInterface As %String(MAXLEN = 250);

Method OnInit() As %Status
{
    #Dim sc as %Status = $$$OK
    #Dim ex as %Exception.AbstractException
    
    try {
        $$$TOE(sc,##super())        
        set ..FTP = ##class(ks.lib.ftp.FTPSession).%New()    
        set ..LocalInterface = $zstrip($piece(..LocalInterface,"("),"*W")        
        set ..FTP.LocalInterface = ..LocalInterface
    }
    catch (ex) {
      set sc = ex.AsStatus()
    }
    quit sc
}

Method Connect(pTimeout As %Numeric = 30, pInbound As %Boolean = 0) As %Status
{
	set $ztrap="Trap", tSC=$$$OK, tFTPPort=..FTPPort
	do {
		if ..Connected { do ..TestConnection(pInbound) quit:..Connected }

		#; Connect to the FTP server
		if '$isobject(..%CredentialsObj) do ..CredentialsSet(..Credentials) if '$isobject(..%CredentialsObj) { set tSC=$$$ERROR($$$EnsErrNoCredentials,..Credentials) quit }
		set ..%LastSetFilePath=""

		#; find FTP type; get a configuration-settings instance, use it to open an FTP Session instance
	 	if ..%isSFTP {
		 	#; Connect using an SFTP object
			set:""=tFTPPort tFTPPort=22
			set tIOAddr=..FTPServer_":"_tFTPPort_"/"_..Credentials_"/SSL='"_..SSLConfig_"'/PubKey='"_..SFTPPublicKeyFile_"'/PrivKey='"_..SFTPPrivateKeyFile_"'"
			$$$catTRACE("connwait","Connecting to "_tIOAddr_"/"_..Credentials_"'/PubKey='"_..SFTPPublicKeyFile_"'/PrivKey='"_..SFTPPrivateKeyFile_"' with timeout="_pTimeout)
		 	set:'$isobject(..FTP)||'..FTP.%Extends("EnsLib.FTP.CommonSSH") ..FTP=$this
		 	set t0=$zhorolog
		 	set tSC=..FTP.ConnectSSH(pTimeout, pInbound, tFTPPort)
	 	} else {
		 	#; Connect using standard FTP, or FTPS with SSLConfig
			set:""=tFTPPort tFTPPort=21
			set tIOAddr=..FTPServer_":"_tFTPPort_"/"_..Credentials_"/SSL='"_..SSLConfig
			$$$catTRACE("connwait","Connecting to "_tIOAddr_"/"_..Credentials_" with timeout="_pTimeout)
		 	set:'$isobject(..FTP)||'..FTP.%Extends("%Net.FtpSession") ..FTP=##class(ks.lib.ftp.FTPSession).%New(..LocalInterface)
			set t0=$zhorolog, ..FTP.Timeout=pTimeout, ..FTP.UsePASV=..UsePASV, ..FTP.LegacySSL=("*"=$extract(..SSLConfig,*)), ..FTP.SSLConfiguration=$select("*"=$extract(..SSLConfig,*):$extract(..SSLConfig,1,*-1),1:..SSLConfig)
			if (..FTP.SSLConfiguration'="") set ..FTP.SSLCheckServerIdentity = ..SSLCheckServerIdentity
			if '..FTP.Connect(..FTPServer,..%CredentialsObj.Username,..%CredentialsObj.Password,tFTPPort) {
				set tSC=$$$ERROR($$$EnsErrFTPConnectFailed,tIOAddr_"/"_..Credentials,..FTP.ReturnMessage,..FTP.ReturnCode)
			}
			#; Set after connect since FTP class will query server if empty string
			set ..FTP.CommandTranslateTable = ..CommandTranslateTable
	 	}
		if $$$ISERR(tSC) {
			set tSC=$select((-1'=pTimeout)&&(t0+pTimeout<=$zhorolog): $$$ADDSC($$$ERROR($$$EnsErrOutConnectExpired,pTimeout,$select(..%isSFTP:"SFTP",1:"FTP"),tIOAddr),tSC)
													 , 1: $$$ERROR($$$EnsErrOutConnectFailed,$$$StatusDisplayString(tSC),$select(..%isSFTP:"SFTP",1:"FTP"),tIOAddr))
			set ..FTP=$$$NULLOREF
			quit
		}
		#; Get the system declaration from the FTP server
		set ..%Syst=""  set:..FTP.System(.tSystem) ..%Syst=tSystem
		if ""'=..%Syst {
			set ..%isVMS = ("VMS " = $extract(..%Syst,1,$length("VMS ")))
			$$$catTRACE("connwait","Detected FTP server system type '"_..%Syst_"'")
		}
		#; Set the current directory
		set ..%LastSetFilePath=..fixSvrPath(..FilePath,0)
		if ""=..%LastSetFilePath {
			$$$catTRACE("connwait","Not setting FTP working directory because FilePath is empty")
		} else {
			if ..FTP.SetDirectory(..%LastSetFilePath) {
				$$$catTRACE("connwait","Set FTP working directory to "_..%LastSetFilePath)
			} else {
				set tSC=$$$ERROR($$$EnsErrFTPDirectoryChangeFailed,..%LastSetFilePath,..FTP.ReturnMessage,..FTP.ReturnCode) 
				set ..%LastSetFilePath=""
				quit
			}
		}
		#; Set the transfer mode
		set tTable = "RAW"
		set csetlc=$zconvert(..Charset,"L")
		set tAscii=$case($extract(csetlc,1,5),"":1,"defau":1,"ascii":1,"latin":1,"iso-8":1,"utf-8":1,:0)
		if 'tAscii {
			if '..FTP.Binary() {
				set tSC=$$$ERROR($$$EnsErrFTPModeChangeFailed,"Binary",..FTP.ReturnMessage,..FTP.ReturnCode)
				set ..FTP.TranslateTable = ""
				quit
			}
			if "binary"'=csetlc {
				set tEnc=..Charset   set:"*"=$extract(tEnc) $extract(tEnc)=""
				set tTable = ##class(%IO.I.TranslationDevice).GetCharEncodingTable(tEnc)
				set:tTable="" tTable="RAW"
			}
		} else {
			if '..FTP.Ascii() {
				set tSC=$$$ERROR($$$EnsErrFTPModeChangeFailed,"Ascii",..FTP.ReturnMessage,..FTP.ReturnCode)
				quit
			}
			if "ascii"'=csetlc {
				if $case(csetlc,"":0,"default":0,"native":0,:1) {
					set tTable = ##class(%IO.I.TranslationDevice).GetCharEncodingTable(..Charset)
				} else { set tTable = "" }
				set:tTable="" tTable=$$DefIO^%NLS(5)
			}
		}
		#; Success
		set ..FTP.TranslateTable = tTable
		set tTxt="Connected to FTP Server '"_tIOAddr_"' at path '"_..%LastSetFilePath_"' using Credentials '"_..Credentials_"'"
		if ..StayConnected<0 { $$$LOGINFO(tTxt) }
		else {
			if pInbound&&'..StayConnected { $$$catTRACE("connwait",tTxt) }
			elseif ..%logTransfers { $$$LOGINFO(tTxt) }
			else { $$$sysTRACE(tTxt) }
		}
		set ..Connected=1
		$$$ASSERT(..FTP.Connected)
		if (..BusinessHost.%LastReportedError [ "ERROR <Ens>ErrOutConnect")
		 ||(..BusinessHost.%LastReportedError [ ..%LastNetErr) {
			set ..BusinessHost.%LastReportedError=""
			$$$SetHostMonitor(..BusinessHost.%ConfigName,$$$eMonitorStatus,"OK")
		}
		set ..%LastNetErr="%%%%%"
		set i%%IOAddr=tIOAddr
	} while 0
Exit
	if $$$ISERR(tSC) {
		$$$ASSERT('..Connected)
		do:..FTP.Connected ..FTP.Logout() ; force FTP class into sync in case it made a mistake
	}
	quit tSC
Trap
	set $ztrap="",tSC=$$$EnsSystemError
	set tSC =$$$ERROR($$$EnsErrOutConnectException,$$$StatusText(tSC),$select(..%isSFTP:"SFTP",1:"FTP"),tIOAddr_"/"_..Credentials)
	goto Exit
}

}
