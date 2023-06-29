memcmp:
	; スタックフレームの構築
	push	ebp
	mov	esp, ebp

	; レジスタの保存
	push	ecx
	push	esi
	push	edi

	; 引数の取得
	cld
	mov	esi, [ebp + 8]
	mov	edi, [ebp + 12]
	mov	ecx, [ebp + 16]

	; バイト単位での比較
	repe cmpsb
	jnz	.10F
	mov	eax, 0
	jmp	.10E
.10F:
	mov	eax, -1
.10E
	; レジスタの復帰
	pop	edi
	pop	esi
	pop	ecx

	; スタックフレームの破棄
	mov	esp, ebp
	pop	ebp

	ret
