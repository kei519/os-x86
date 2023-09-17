get_font_adr:	; void get_font_adr(adr)
	; スタックフレームの構築
	push	bp
	mov	bp, sp

	; レジスタの保存
	push	ax
	push	bx
	push	si
	push	es
	push	bp

	; 引数を取得
	mov	si, [bp + 4]

	; フォントアドレスの取得
	mov	ax, 0x1130		; フォントアドレスの取得
	mov	bh, 0x06		; 8x16 font
	int	0x10			; ES:BX = FONT ADDRESS

	; フォントアドレスを保存
	mov	[si + 0], es		; adr[0] = セグメント
	mov	[si + 2], bp		; adr[1] = オフセット

	; レジスタの復帰
	pop	bp
	pop	es
	pop	si
	pop	bx
	pop	ax

	; スタックフレームの破棄
	mov	sp, bp
	pop	bp

	ret
