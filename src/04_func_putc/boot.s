	BOOT_LOAD	equ	0x7C00		; ブートプログラムのロード位置

	ORG	BOOT_LOAD

; マクロ
%include	"../include/macro.s"

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

	; 自分で呼び出して文字を表示
	push	word 'A'
	call	putc
	add	sp, 2

	push	word 'B'
	call	putc
	add	sp, 2

	push	word 'C'
	call	putc
	add	sp, 2

	; マクロで文字表示
	cdecl	putc, word 'X', word 'J', word 'X', word 'Y', word'Z'
	cdecl	putc, word 'Y'
	cdecl	putc, word 'Z'

	jmp	$	; 無限ループ

ALIGN 2, db 0
BOOT:						; ブートドライブに関する情報
.DRIVE		dw 0				; ドライブ番号

; モジュール
%include	"../modules/real/putc.s"

; ブートフラグ
	times 510 - ($ - $$) db 0x00
	db 0x55, 0xAA
