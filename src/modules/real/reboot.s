reboot:
	; メッセージを表示
	cdecl	puts, .s0

	; キー入力待ち
.10L:
	mov	ah, 0
	int	0x16		; キーボード読み取り

	cmp	al, ' '		; AL = 読み取り結果のASCIIコード
	jne	.10L
	
	; 改行を出力
	cdecl	puts, .s1

	; 再起動
	int	0x19

	; 文字列データ
.s0:	db 0x0A, 0x0D, "Push SPACE key to reboot...", 0
.s1:	db 0x0A, 0x0D, 0x0A, 0x0D, 0