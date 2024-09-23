/// text utilities
Class ks.lib.text.Utils
{

/// strips RTF stream of all control sequences, leaving only plain text on output stream
ClassMethod StripRTFStream(inputStream As %Stream.Object, Output outputStream As %Stream.Object) As %Status
{
  #Dim sc as %Status = $$$OK
  #Dim ex as %Exception.AbstractException

  #Dim rtfRegex as %Regex.Matcher = ##class(%Regex.Matcher).%New("(?i)\\([a-z]{1,32})(-?[0-9]{1,10})?\s?|\\'([0-9a-f]{2})|\\([^a-z])|([{}])|[\r\n]+|(.)")
  #Dim destinations as %List = $listfromstring("aftncn,aftnsep,aftnsepc,annotation,atnauthor,atndate,atnicn,atnid,atnparent,atnref,atntime,atrfend,atrfstart,author,background,bkmkend,bkmkstart,blipuid,buptim,category,colorschememapping,colortbl,comment,company,creatim,datafield,datastore,defchp,defpap,do,doccomm,docvar,dptxbxtext,ebcend,ebcstart,factoidname,falt,fchars,ffdeftext,ffentrymcr,ffexitmcr,ffformat,ffhelptext,ffl,ffname,ffstattext,field,file,filetbl,fldinst,fldrslt,fldtype,fname,fontemb,fontfile,fonttbl,footer,footerf,footerl,footerr,footnote,formfield,ftncn,ftnsep,ftnsepc,g,generator,gridtbl,header,headerf,headerl,headerr,hl,hlfr,hlinkbase,hlloc,hlsrc,hsv,htmltag,info,keycode,keywords,latentstyles,lchars,levelnumbers,leveltext,lfolevel,linkval,list,listlevel,listname,listoverride,listoverridetable,listpicture,liststylename,listtable,listtext,lsdlockedexcept,macc,maccPr,mailmerge,maln,malnScr,manager,margPr,mbar,mbarPr,mbaseJc,mbegChr,mborderBox,mborderBoxPr,mbox,mboxPr,mchr,mcount,mctrlPr,md,mdeg,mdegHide,mden,mdiff,mdPr,me,mendChr,meqArr,meqArrPr,mf,mfName,mfPr,mfunc,mfuncPr,mgroupChr,mgroupChrPr,mgrow,mhideBot,mhideLeft,mhideRight,mhideTop,mhtmltag,mlim,mlimloc,mlimlow,mlimlowPr,mlimupp,mlimuppPr,mm,mmaddfieldname,mmath,mmathPict,mmathPr,mmaxdist,mmc,mmcJc,mmconnectstr,mmconnectstrdata,mmcPr,mmcs,mmdatasource,mmheadersource,mmmailsubject,mmodso,mmodsofilter,mmodsofldmpdata,mmodsomappedname,mmodsoname,mmodsorecipdata,mmodsosort,mmodsosrc,mmodsotable,mmodsoudl,mmodsoudldata,mmodsouniquetag,mmPr,mmquery,mmr,mnary,mnaryPr,mnoBreak,mnum,mobjDist,moMath,moMathPara,moMathParaPr,mopEmu,mphant,mphantPr,mplcHide,mpos,mr,mrad,mradPr,mrPr,msepChr,mshow,mshp,msPre,msPrePr,msSub,msSubPr,msSubSup,msSubSupPr,msSup,msSupPr,mstrikeBLTR,mstrikeH,mstrikeTLBR,mstrikeV,msub,msubHide,msup,msupHide,mtransp,mtype,mvertJc,mvfmf,mvfml,mvtof,mvtol,mzeroAsc,mzeroDesc,mzeroWid,nesttableprops,nextfile,nonesttables,objalias,objclass,objdata,object,objname,objsect,objtime,oldcprops,oldpprops,oldsprops,oldtprops,oleclsid,operator,panose,password,passwordhash,pgp,pgptbl,picprop,pict,pn,pnseclvl,pntext,pntxta,pntxtb,printim,private,propname,protend,protstart,protusertbl,pxe,result,revtbl,revtim,rsidtbl,rxe,shp,shpgrp,shpinst,shppict,shprslt,shptxt,sn,sp,staticval,stylesheet,subject,sv,svb,tc,template,themedata,title,txe,ud,upr,userprops,wgrffmtfilter,windowcaption,writereservation,writereservhash,xe,xform,xmlattrname,xmlattrvalue,xmlclose,xmlname,xmlnstbl,xmlopen")
  #Dim dictionary as %ArrayOfDataTypes = ##class(%ArrayOfDataTypes).%New()    
  #Dim stack as ks.lib.collections.StackOfDataTypes = ##class(ks.lib.collections.StackOfDataTypes).%New()
  #Dim ignorable as %Boolean = 0
  #Dim ucskip as %Integer = 1
  #Dim curskip as %Integer = 0

  s:('$data(outputStream) || '$isobject(outputStream)) outputStream = ##class(%Stream.GlobalCharacter).%New()
  d dictionary.SetAt(outputStream.LineTerminator,"par")
  d dictionary.SetAt(outputStream.LineTerminator_outputStream.LineTerminator,"sect")
  d dictionary.SetAt(outputStream.LineTerminator_outputStream.LineTerminator,"page")
  d dictionary.SetAt(outputStream.LineTerminator,"line")
  d dictionary.SetAt($char(9),"tab")
  d dictionary.SetAt("-","emdash")
  d dictionary.SetAt("-","endash")
  d dictionary.SetAt(" ","emspace")
  d dictionary.SetAt(" ","enspace")
  d dictionary.SetAt(" ","qmspace")
  d dictionary.SetAt("*","bullet")
  d dictionary.SetAt("'","lquote")
  d dictionary.SetAt("'","rquote")
  d dictionary.SetAt("""","ldblquote")
  d dictionary.SetAt("""","rdblquote")
  
  try {

    while ('inputStream.AtEnd) {
      s rtfRegex.Text = inputStream.ReadLine()
      while rtfRegex.Locate() > 0 {
        s word = rtfRegex.Group(1)
        s arg = rtfRegex.Group(2)
        s hex = rtfRegex.Group(3)
        s character = rtfRegex.Group(4)
        s brace = rtfRegex.Group(5)
        s tchar = rtfRegex.Group(6)
        if brace '= "" {
          s curskip = 0
          if (brace = "{") {
           d stack.Push($listbuild(ucskip, ignorable))  
          } elseif brace="}" {
            s entry = stack.Pop()
            s ucskip = $listget(entry,1)
            s ignorable = $listget(entry,2)
          }
        } elseif character '= "" {
          s curskip = 0
          if character = "~"  {
            if 'ignorable {
              d outputStream.Write($char(160))
            }
          } elseif character [ "{}\" {
            if 'ignorable {
              d outputStream.Write(character)
            }
          } elseif character = "*" {
            s ignorable = 1
          }
        } elseif word '= "" {
          s curskip = 0
          if $listfind(destinations,word) {
            s ignorable=1
          } elseif ignorable {

          } elseif dictionary.GetAt(word) '= "" {
            d outputStream.Write(dictionary.GetAt(word))
          } elseif word="uc" {
            s ucskip = arg+0
          } elseif word="u" { 
              d outputStream.Write($char(arg))            
              s curskip = ucskip
          }
        } elseif hex '= "" {
          if (curskip > 0) {
                s curskip = curskip-1
          }
          elseif ('ignorable) {
            d outputStream.Write($char($zhex(hex)))
          }
        } elseif tchar '= "" {
            if (curskip > 0)
                {
                  s curskip = curskip - 1
                }
                elseif ('ignorable)
                {
                    d outputStream.Write(tchar)
                }          
        }
      }
      d outputStream.Write(outputStream.LineTerminator)
    }
  } catch (ex) {
    s sc = ex.AsStatus()
  }
  return sc
}

}
