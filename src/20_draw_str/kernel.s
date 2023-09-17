%include	"../include/define.s"
%include	"../include/macro.s"

	ORG	KERNEL_LOAD

[BITS 32]
; エントリポイント
kernel:
	; フォントアドレスの取得
	mov	esi, BOOT_LOAD + SECT_SIZE	; ESI = 0x7C00 + 512
	movzx	eax, word [esi + 0]		; EAX = [ESI + 0] = セグメント
	movzx	ebx, word [esi + 2]		; EBX = [ESI + 2] = オフセット
	shl	eax, 4				; EAX <<= 4
	add	eax, ebx			; EAX = セグメント << 4 + オフセット
	mov	[FONT_ADR], eax			; *FONT_ADR = EAX

	cdecl	draw_font, 63, 13		; フォントの一覧表示

	; 文字列の表示
	cdecl	draw_str, 25, 14, 0x010F, .s0

	; 処理の終了
	jmp	$

.s0	db " Hello, kernel! ", 0

ALIGN 4, db 0
FONT_ADR:	dd 0

; モジュール
%include	"../modules/protect/vga.s"
%include	"../modules/protect/draw_char.s"
%include	"../modules/protect/draw_font.s"
%include	"../modules/protect/draw_str.s"

; パディング
	times KERNEL_SIZE - ($ - $$)	db 0