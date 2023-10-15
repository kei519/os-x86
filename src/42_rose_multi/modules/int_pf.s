int_pf:
	; レジスタの保存
	pusha
	push	ds
	push	es

	mov	ax, 0x0010
	mov	ds, ax
	mov	es, ax

	; 例外を生成したアドレスの確認
	mov	eax, cr2			; EAX = CR2
	and	eax, ~0x0FFF			; 4Kバイト以内のアクセス
	cmp	eax, 0x0010_7000		; ptr = アクセスアドレス
	jne	.10F

	mov	[0x0010_6000 + 0x107 * 4], dword 0x0010_7007	; ページの有効化
	cdecl	memcpy, 0x0010_7000, DRAW_PARAM, rose_size	; 描画パラメータ：タスク3用

	jmp	.10E
.10F:
	; スタックの調整
	add	esp, 4				; pop es
	add	esp, 4				; pop ds
	popa

	; タスク終了処理
	pushf					; // EFLAGS
	push	cs				; CS
	push	int_stop			; スタック表示処理

	mov	eax, .s0			; 割り込み種別
	iret
.10E:
	; レジスタの復帰
	pop	es
	pop	ds
	popa

	add	esp, 4				; pop エラーコード

	iret

.s0	db " < PAGE FAULT > ", 0
