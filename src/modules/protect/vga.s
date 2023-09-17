vga_set_read_plane:	; vga_set_read_plane(plane)
	; スタックフレームの構築
	push	ebp
	mov	ebp, esp

	; レジスタの保存
	push	eax
	push	edx

	; 読み込みプレーンの選択
	mov	ah, [ebp + 8]			; AH = プレーンを選択（3=輝度 2～0=RGB）
	and	ah, 0x03			; AH &= 0x03	余計なビットをマスク
	mov	al, 0x04			; AL = 読み込みマップ選択レジスタ
	mov	dx, 0x03CE			; DX = グラフィックス制御ポート
	out	dx, ax

	; レジスタの復帰
	pop	edx
	pop	eax

	; スタックフレームの破棄
	mov	esp, ebp
	pop	ebp

	ret

vga_set_write_plane:	; vga_set_write_plane(plane)
	; スタックフレームの構築
	push	ebp
	mov	ebp, esp

	; レジスタの保存
	push	eax
	push	edx

	; 読み込みプレーンの選択
	mov	ah, [ebp + 8]			; AH = プレーンを選択（3=輝度 2～0=RGB）
	and	ah, 0x0F			; AH &= 0x0F	余計なビットをマスク
	mov	al, 0x02			; AL = マップマスクレジスタ（書き込みプレーンを指定）
	mov	dx, 0x03C4			; DX = シーケンサ制御ポート
	out	dx, ax

	; レジスタの復帰
	pop	edx
	pop	eax

	; スタックフレームの破棄
	mov	esp, ebp
	pop	ebp

	ret

vram_font_copy:	; vram_font_copy(font, vram, plane, color)
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

	mov	esi, [ebp + 8]			; ESI = フォントアドレス
	mov	edi, [ebp +12]			; EDI = VRAMアドレス
	movzx	eax, byte [ebp +16]		; EAX = プレーン（ビット指定）
	movzx	ebx, word [ebp +20]		; EBX = 色（背景色 前景色）

	test	bh, al				; ZF = (背景色 & プレーン)
	setz	dh				; DH = ZF ? 0x01 : 0x00
	dec	dh				; DH--;	0x00 or 0xFF

	test	bl, al				; ZF = (前景色 & プレーン)
	setz	dl				; DL = ZF ? 0x01 : 0x00
	dec	dl				; DL--; 0x00 or 0xFF

	; 16ドットフォントのコピー
	cld					; DF = アドレス加算

	mov	ecx, 16				; ECX 16 // 16ドット
.10L:
	; フォントマスクの作成
	lodsb					; AL = *ESI++
	mov	ah, al				; AH = AL
	not	ah				; AH = !フォント（ビット反転）

	; 前景色
	and	al, dl				; AL = 前景色 & フォント

	; 背景色
	test	ebx, 0x0010			; if (透過モード)
	jz	.11F
	and	ah, [edi]			; AH = !フォント & VRAM
	jmp	.11E
.11F:						; else
	and	ah, dh				; AH = !フォント & 背景色
.11E:

	; 前景色と背景色を合成
	or	al, ah				; AL = 前景 | 背景

	; 新しい値を出力
	mov	[edi], al			; VRAM = AL

	add	edi, 80
	loop	.10L				; while (--CX > 0)
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