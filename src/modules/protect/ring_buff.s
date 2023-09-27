ring_rd:	; bool ring_rd(buff, data)
	; スタックフレームの構築
	push	ebp
	mov	ebp, esp

	; レジスタの保存
	push	ebx
	push	esi
	push	edi

	; 引数を取得
	mov	esi, [ebp + 8]
	mov	edi, [ebp +12]

	; 読み込み位置を確認
	mov	eax, 0				; EAX = 0 // データなし
	mov	ebx, [esi + ring_buff.rp]	; EBX = rp // 読み込み位置
	cmp	ebx, [esi + ring_buff.wp]
	je	.10E

	mov	al, [esi + ring_buff.item + ebx] ; AL = BUFF[rp] // キーコードを保存

	mov	[edi], al			; data = al // データを保存

	inc	ebx				; EBX++ // 次の読み込み位置
	and	ebx, RING_INDEX_MASK		; EBX &= 0x0F // サイズの制限
	mov	[esi + ring_buff.rp], ebx	; rp = EBX // 読み込み位置を保存

	mov	eax, 1				; EAX = 1 // データあり
.10E:
	; レジスタの復帰
	pop	edi
	pop	esi
	pop	ebx

	; スタックフレームの破棄
	mov	esp, ebp
	pop	ebp

	ret

ring_wr:	; bool ring_wr(buff, data)
	; スタックフレームの構築
	push	ebp
	mov	ebp, esp

	; レジスタの保存
	push	ebx
	push	ecx
	push	esi

	; 引数を取得
	mov	esi, [ebp + 8]			; ESI = リングバッファ

	; 書き込み位置を確認
	mov	eax, 0				; EAX = 0 // 失敗
	mov	ebx, [esi + ring_buff.wp]	; EBX = wp // 書き込み位置
	mov	ecx, ebx			; ECX = EBX
	inc	ecx				; ECX++ // 次の書き込み位置
	and	ecx, RING_INDEX_MASK		; ECX &= 0x0F // サイズの制限

	cmp	ecx, [esi + ring_buff.rp]
	je	.10E

	mov	al, [ebp + 12]			; AL = data

	mov	[esi + ring_buff.item + ebx], al ; BUFF[wp] = AL // キーコードを保存
	mov	[esi + ring_buff.wp], ecx	; wp = ECX // 書き込み位置を保存
	mov	eax, 1				; EAX = 1 // 成功
.10E:
	; レジスタの復帰
	pop	esi
	pop	ecx
	pop	ebx

	; スタックフレームの破棄
	mov	esp, ebp
	pop	ebp

	ret

draw_key:	; draw_key(X, Y, buff)
	; スタックフレームの構築
	push	ebp
	mov	ebp, esp

	; レジスタの保存
	push	ebx
	push	ecx
	push	edx
	push	esi
	push	edi

	; 引数を取得
	mov	edx, [ebp + 8]			; EBX = X（列）
	mov	edi, [ebp +12]			; EDI = Y（行）
	mov	esi, [ebp +16]			; ESI = リングバッファ

	; リングバッファの情報を取得
	mov	ebx, [esi + ring_buff.rp]	; EBX = wp // 書き込み位置
	lea	esi, [esi + ring_buff.item]	; ESI = &BUFF
	mov	ecx, RING_ITEM_SIZE		; ECX = RING_ITEM_SIZE // 要素数
.10L:
	dec	ebx				; EBX--
	and	ebx, RING_INDEX_MASK		; EBX &= 0x0F
	mov	al, [esi + ebx]			; AL = BUFF[EBX]

	cdecl	itoa, eax, .tmp, 2, 16, 0b0100	; キーコードを文字列に変換
	cdecl	draw_str, edx, edi, 0x02, .tmp	; 変換した文字列を表示

	add	edx, 3				; EDX += 3 // 表示位置を更新（3文字分）

	loop	.10L
.10E:
	; レジスタの復帰
	pop	edi
	pop	esi
	pop	edx
	pop	ecx
	pop	ebx

	; スタックフレームの破棄
	mov	esp, ebp
	pop	ebp

	ret

.tmp	db "-- ", 0