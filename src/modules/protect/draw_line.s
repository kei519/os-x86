draw_line:	; draw_line(X0, Y0, X1, Y1, color)
	; スタックフレームの構築
	push	ebp
	mov	ebp, esp

	push	dword 0				; EBP- 4| sum   = 0 // 相対軸の積算値
	push	dword 0				;    - 8| x0    = 0 // X座標
	push	dword 0				;    -12| dx    = 0 // X幅
	push	dword 0				;    -16| inc_x = 0 // X座標増分(1 or -1)
	push	dword 0				;    -20| y0    = 0 // Y座標
	push	dword 0				;    -24| dy    = 0 // Y幅
	push	dword 0				;    -28| inc_y = 0 // Y座標増分(1 or -1)

	; レジスタの保存
	push	eax
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi

	; 幅を計算（X軸）
	mov	eax, [ebp + 8]			; EAX = X0
	mov	ebx, [ebp +16]			; EBX = X1
	sub	ebx, eax			; EBX = X1 - X0 // 幅
	jge	.10F

	neg	ebx				; EBX = 幅
	mov	esi, -1
	jmp	.10E
.10F:
	mov	esi, 1
.10E:

	; 高さを計算（Y軸）
	mov	ecx, [ebp +12]			; ECX = Y0
	mov	edx, [ebp +20]			; EDX = Y1
	sub	edx, ecx			; EDX = Y1 - Y0 // 高さ
	jge	.20F

	neg	edx				; EDX = 高さ
	mov	edi, -1
	jmp	.20E
.20F:
	mov	edi, 1
.20E:

	; X軸
	mov	[ebp - 8], eax
	mov	[ebp -12], ebx
	mov	[ebp -16], esi

	; Y軸
	mov	[ebp -20], ecx
	mov	[ebp -24], edx
	mov	[ebp -28], edi

	; 基準軸（絶対軸は毎回増減する）を決める
	cmp	ebx, edx
	jg	.22F

	lea	esi, [ebp -20]			; ESI = &(絶対軸の座標)
	lea	edi, [ebp - 8]			; EDI = &(相対軸の座標)

	jmp	.22E
.22F:
	lea	esi, [ebp - 8]			; ESI = &(絶対軸の座標)
	lea	edi, [ebp -20]			; EDI = &(相対軸の座標)
.22E:

	; 繰り返し回数
	mov	ecx, [esi - 4]			; ECX = 基準軸描画幅
	cmp	ecx, 0
	jnz	.30E
	mov	ecx, 1				; ECX = 1
.30E:
	; 線を描画
.50L:
%ifdef	USE_SYSTEM_CALL
	push	ecx

	mov	ebx, dword [ebp +24]		; EBX = 表示色
	mov	ecx, dword [ebp - 8]		; ECX = X座標
	mov	edx, dword [ebp -20]		; EDX = Y座標
	int	0x82

	pop	ecx
%else
	cdecl	draw_pixel, dword [ebp - 8], dword [ebp -20], dword [ebp +24]	; 点の描画
%endif

	; 基準軸更新
	mov	eax, [esi - 8]			; EAX = 基準軸増分
	add	[esi - 0], eax			; 基準軸を更新

	; 相対軸を更新
	mov	eax, [ebp - 4]			; EAX = sum // 相対軸の積算値
	add	eax, [edi - 4]			; EAX += 相対軸幅

	mov	ebx, [esi - 4]			; EBX = 絶対軸幅

	cmp	eax, ebx
	jl	.52E

	sub	eax, ebx			; EAX -= 絶対軸幅
	mov	ebx, [edi - 8]			; EBX = 相対軸増分
	add	[edi - 0], ebx			; 相対軸を更新
.52E:
	mov	[ebp - 4], eax			; 積算値を更新

	loop	.50L
.50E:

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