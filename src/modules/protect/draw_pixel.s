draw_pixel:	; draw_pixel(X, Y, color)
	; スタックフレームの構築
	push	ebp
	mov	ebp, esp

	; レジスタの保存
	push	eax
	push	ebx
	push	ecx
	push	edi

	; Y座標を80(640/8)倍にする
	mov	edi, [ebp +12]			; EDI = Y
	shl	edi, 4
	lea	edi, [edi * 4 + edi + 0xA_0000]	; EDI = 0xA_0000[80 * Y]

	; X座標を1/8して加算（書き込むバイト位置を決定）
	mov	ebx, [ebp + 8]			; EBX = X
	mov	ecx, ebx
	shr	ebx, 3
	add	edi, ebx			; EDI = 0xA_0000[80*Y + X/8]

	; X座標を8で割った余りからビット位置を計算
	; (0 = 0x80, 1 = 0x40, ..., 7 = 0x01)
	and	ecx, 0x07			; ECX = X % 8
	mov	ebx, 0x80
	shr	ebx, cl				; EBX = 指定された点だけフラグが立った状態

	; 色指定
	mov	ecx, [ebp +16]			; ECX = 表示色

	; プレーンごとに出力
	cdecl	vga_set_read_plane, 0x03	; 輝度（I）プレーンを選択
	cdecl	vga_set_write_plane, 0x08
	cdecl	vram_bit_copy, ebx, edi, 0x08, ecx

	cdecl	vga_set_read_plane, 0x02	; 赤（R）プレーンを選択
	cdecl	vga_set_write_plane, 0x04
	cdecl	vram_bit_copy, ebx, edi, 0x04, ecx

	cdecl	vga_set_read_plane, 0x01	; 緑（G）プレーンを選択
	cdecl	vga_set_write_plane, 0x02
	cdecl	vram_bit_copy, ebx, edi, 0x02, ecx

	cdecl	vga_set_read_plane, 0x00	; 青（B）プレーンを選択
	cdecl	vga_set_write_plane, 0x01
	cdecl	vram_bit_copy, ebx, edi, 0x01, ecx

	; レジスタの復帰
	pop	edi
	pop	ecx
	pop	ebx
	pop	eax

	; スタックフレームの破棄
	mov	esp, ebp
	pop	ebp

	ret