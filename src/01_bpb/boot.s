; エントリポイント
entry:
	jmp	ipl

	;BPM
	times	90 - ($ - $$) db 0x90

	;IPL
ipl:
	jmp	$	; 無限ループ

; ブートフラグ
	times 510 - ($ - $$) db 0x00
	db 0x55, 0xAA
