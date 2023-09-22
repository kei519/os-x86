draw_rect:	; draw_rect(X0, Y0, X1, Y1)
	; スタックフレームの構築
	push	ebp
	mov	ebp, esp

	; レジスタの保存
	push	eax
	push	ebx
	push	ecx
	push	edx
	push	esi

	mov	eax, [ebp + 8]			; EAX = X0
	mov	ebx, [ebp +12]			; EBX = Y0
	mov	ecx, [ebp +16]			; ECX = X1
	mov	edx, [ebp +20]			; EDX = Y1
	mov	esi, [ebp +24]			; ESI = color

	; 座標軸の大小を確定
	cmp	eax, ecx
	jl	.10E
	xchg	eax, ecx			; EAX <-> ECX
.10E:
	cmp	ebx, edx
	jl	.20E
	xchg	ebx, edx			; EBX <-> EDX
.20E:

	; 矩形を描画
	cdecl	draw_line, eax, ebx, ecx, ebx, esi	; 上線
	cdecl	draw_line, eax, ebx, eax, edx, esi	; 左線

	dec	edx					; EDX-- // 下線は1ドット上げる
	cdecl	draw_line, eax, edx, ecx, edx, esi	; 下線

	dec	ecx					; ECX-- // 右線は1ドット左に移動
	cdecl	draw_line, ecx, ebx, ecx, edx, esi	; 右線

	; レジスタの復帰
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax

	; スタックフレームの破棄
	mov	esp, ebp
	pop	ebp

	ret