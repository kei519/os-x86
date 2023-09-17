draw_char:	; draw_char(col, raw, color, ch)
	; スタックフレームの構築
	push	ebp
	mov	ebp, esp

	; レジスタの保存
	push	ebx
	push	esi
	push	edi

	; コピー元フォントアドレスを設定
	movzx	esi, byte [ebp +20]		; ESI = 文字コード
	shl	esi, 4				; ESI *= 16 // 1文字16バイト
	add	esi, [FONT_ADR]			; ESI = フォントアドレス

	; コピー先アドレスを取得
	; adr = 0xA_0000 + (640 / 8 * 16) * raw + col
	mov	edi, [ebp +12]			; EDI = raw
	shl	edi, 8				; EDI = raw * 256
	lea	edi, [edi * 4 + edi + 0xA_0000]	; EDI = Y * 1280 + 0xA_0000
	add	edi, [ebp + 8]			; EDI = VRAM

	; 1文字分のフォントを出力
	movzx	ebx, word [ebp +16]		; EBX = 表示色

	cdecl	vga_set_read_plane, 0x03	; 読み込みプレーン：輝度（I）
	cdecl	vga_set_write_plane, 0x08	; 書き込みプレーン：輝度（I）
	cdecl	vram_font_copy, esi, edi, 0x08, ebx

	cdecl	vga_set_read_plane, 0x02	; 読み込みプレーン：赤（R）
	cdecl	vga_set_write_plane, 0x04	; 書き込みプレーン：赤（R）
	cdecl	vram_font_copy, esi, edi, 0x04, ebx

	cdecl	vga_set_read_plane, 0x01	; 読み込みプレーン：緑（G）
	cdecl	vga_set_write_plane, 0x02	; 書き込みプレーン：緑（G）
	cdecl	vram_font_copy, esi, edi, 0x02, ebx

	cdecl	vga_set_read_plane, 0x00	; 読み込みプレーン：青（B）
	cdecl	vga_set_write_plane, 0x01	; 書き込みプレーン：青（B）
	cdecl	vram_font_copy, esi, edi, 0x01, ebx

	; レジスタの復帰
	pop	edi
	pop	esi
	pop	ebx

	; スタックフレームの破棄
	mov	esp, ebp
	pop	ebp

	ret