draw_rotation_bar:
; タイマーカウントが16進んだら回る棒を表示
	; レジスタの保存
	push	eax

	mov	eax, [TIMER_COUNT]		; EAX = タイマー割り込みカウンタ
	shr	eax, 4				; EAX >>= 4 // 16で除算
	cmp	eax, [.index]
	je	.10E

	mov	[.index], eax			; 前回値 = EAX
	and	eax, 0x03			; EAX &= 0x03 // 0~3に限定

	mov	al, [.table + eax]		; AL = TABLE[EAX]
	cdecl	draw_char, 0, 29, 0x000F, eax	; draw_char(0, 29, 0x0F, EAX)
.10E:
	; レジスタの復帰
	pop	eax

	ret

ALIGN 4, db 0
.index	dd 0					; 前回値
.table	db "|/-\\"				; 表示キャラクタ