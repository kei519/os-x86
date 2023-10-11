test_and_set:
	; スタックフレームの構築
	push	ebp
	mov	ebp, esp

	; レジスタの保存
	push	eax
	push	ebx

	; テストアンドセット
	mov	eax, 0				; local = 0
	mov	ebx, [ebp + 8]			; global = アドレス

.10L:
	lock bts [ebx], eax
	jnc	.10E

.12L:
	bt	[ebx], eax
	jc	.12L

	jmp	.10L
.10E:
	; レジスタの復帰
	pop	ebx
	pop	eax

	; スタックフレームの破棄
	mov	esp, ebp
	pop	ebp

	ret