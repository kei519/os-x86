call_gate:	; draw_str(col, row, color, p)
	; スタックフレームの構築
	push	ebp
	mov	ebp, esp

	; レジスタの保存
	pusha
	push	ds
	push	es

	; データ用セグメントの設定
	mov	ax, 0x0010
	mov	ds, ax
	mov	es, ax

	; 文字を表示
	mov	eax, [ebp +12]			; ECX = 列
	mov	ebx, [ebp +16]			; EDX = 行
	mov	ecx, [ebp +20]			; EBX = 表示色
	mov	edx, [ebp +24]			; ESI = 文字列へのアドレス
	cdecl	draw_str, eax, ebx, ecx, edx	; draw_char(col, row, color, p)

	; レジスタの復帰
	pop	es
	pop	ds
	popa

	; スタックフレームの破棄
	mov	esp, ebp
	pop	ebp

	retf 4 * 4