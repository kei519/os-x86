int_timer:
	; レジスタの保存
	pushad
	push	ds
	push	es

	; データ用セグメントの設定
	mov	ax, 0x0010
	mov	ds, ax
	mov	es, ax

	; TICK
	inc	dword [TIMER_COUNT]		; TIMER_COUNT++ // 割り込み回数の更新

	; 割り込みフラグをクリア（EOI）
	outp	0x20, 0x20			; マスタPIC：EOIコマンド

	; レジスタの復帰
	pop	es
	pop	ds
	popad

	iret

ALIGN 4, db 0
TIMER_COUNT:	dd 0