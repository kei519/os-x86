	BOOT_LOAD	equ	0x7C00		; ブートプログラムのロード位置

	ORG	BOOT_LOAD

; エントリポイント
entry:
	jmp	ipl

	;BPM (Boot Parameter Block)
	times	90 - ($ - $$) db 0x90

	;IPL (Initial Program Loader)
ipl:
	cli					; 割り込み禁止

	mov	ax, 0
	mov	ds, ax
	mov	es, ax
	mov	ss, ax
	mov	sp, BOOT_LOAD

	sti					; 割り込み許可

	mov	[BOOT.DRIVE], dl

	mov	al, 'A'				; 表示する文字の指定
	mov	ah, 0x0E			; テレタイプ式1文字出力
	mov	bx, 0				; ページ番号と文字色を0二設定
	int	0x10				; BIOSのビデオサービス

	jmp	$	; 無限ループ

ALIGN 2, db 0
BOOT:						; ブートドライブに関する情報
.DRIVE		dw 0				; ドライブ番号

; ブートフラグ
	times 510 - ($ - $$) db 0x00
	db 0x55, 0xAA
