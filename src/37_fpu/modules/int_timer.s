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

	; タスクの切り替え
	str	ax				; AX = TR // 現在のタスクレジスタ
	cmp	ax, SS_TASK_0
	je	.11L
	cmp	ax, SS_TASK_1
	je	.12L

	jmp	SS_TASK_0:0
	jmp	.10E
.11L:
	jmp	SS_TASK_1:0
	jmp	.10E
.12L:
	jmp	SS_TASK_2:0
	jmp	.10E
.10E:

	; レジスタの復帰
	pop	es
	pop	ds
	popad

	iret

ALIGN 4, db 0
TIMER_COUNT:	dd 0