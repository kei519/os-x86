wait_tick:	; wait_tick(int tick)
	; スタックフレームの構築
	push	ebp
	mov	ebp, esp

	; レジスタの保存
	push	eax
	push ecx

	; ウェイト
	mov	ecx, [ebp + 8]			; ECX = ウェイト回数
	mov	eax, [TIMER_COUNT]		; EAX = TIMER

.10L:
	cmp	[TIMER_COUNT], eax
	je	.10L
	inc	eax				; EAX++
	loop	.10L

	; レジスタの復帰
	pop	ecx
	pop	eax

	; スタックフレームの破棄
	mov	esp, ebp
	pop	ebp

	ret