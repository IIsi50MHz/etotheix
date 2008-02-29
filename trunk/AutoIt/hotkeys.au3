; hot keys

Global $Paused
HotKeySet("{F2}", "BlockComment")
HotKeySet("{F3}", "BlockUncomment")

;;;; Body of program ;;;;
While 1
    Sleep(100)
WEnd
;;;;;;;;;;;;;;;;;;;;;;;;;

Func BlockComment()    
	If WinActive("Notepad++") Then
		; save current clipboard
		$origClip = ClipGet()
		
		; comment out selected code
		Send("^c")
		$clip = ClipGet()
		ClipPut(StringRegExpReplace($clip, "(?m)(^.*$)", "//\1"));
		Send("^v")	
		
		; restore clipboard
		ClipPut($origClip)
	EndIf	
EndFunc

Func BlockUncomment()    
	If WinActive("Notepad++") Then
		; save current clipboard
		$origClip = ClipGet()
		
		; uncomment selected code
		Send("^c")
		$clip = ClipGet()
		ClipPut(StringRegExpReplace($clip, "(?m)(^\s*)//(.*$)", "\1\2"));
		Send("^v")
		
		; restore clipboard
		ClipPut($origClip)
	EndIf		
EndFunc