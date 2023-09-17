draw_font:	; draw_font(col, raw)
	; スタックフレームの構築
	push	ebp
	mov	ebp, esp

	; レジスタの保存
	push	eax
	push	ebx
	push	ecx
	push	esi
	push	edi

	mov	esi, [ebp + 8]			; ESI = col
	mov	edi, [ebp +12]			; EDI = raw

	mov	ecx, 0				; ECX = 0
.10L:	cmp	ecx, 256
	jae	.10E

	mov	eax, ecx			; EAX = ECX
	and	eax, 0x0F			; EAX &= 0x0F
	add	eax, esi			; EAX += col

	mov	ebx, ecx			; EBX = ECX
	shr	ebx, 4				; EBX /= 16
	add	ebx, edi			; EBX += raw

	cdecl	draw_char, eax, ebx, 0x07, ecx

	inc	ecx
	jmp	.10L
.10E:
	; レジスタの復帰
	pop	edi
	pop	esi
	pop	ecx
	pop	ebx
	pop	eax

	; スタックフレームの破棄
	mov	esp, ebp
	pop	ebp

	ret