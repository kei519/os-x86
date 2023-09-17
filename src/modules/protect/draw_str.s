draw_str:	; draw_str(col, row, color, p)
	; スタックフレームの構築
	push	ebp
	mov	ebp, esp

	; レジスタの保存
	push	eax
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi

	mov	ecx, [ebp + 8]			; ECX = 列
	mov	edx, [ebp +12]			; EDX = 行
	movzx	ebx, word [ebp +16]		; EBX = 表示色
	mov	esi, [ebp +20]			; ESI = 文字列へのアドレス

	cld					; DF = 0 // アドレス加算
.10L:
	; 文字の表示
	lodsb					; AL = *ESI++
	cmp	al, 0
	je	.10E

	cdecl	draw_char, ecx, edx, ebx, eax

	; 表示位置更新
	inc	ecx				; ECX++
	cmp	ecx, 80
	jl	.12E
	mov	ecx, 0
	inc	edx				; EDX++
	cmp	edx, 30
	jl	.12E
	mov	edx, 0
.12E:
	jmp	.10L
.10E:
	; レジスタの復帰
	pop	edi
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax

	; スタックフレームの破棄
	mov	esp, ebp
	pop	ebp

	ret