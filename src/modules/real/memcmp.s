memcmp:
	; スタックフレームの構築
	push	bp
	mov	bp, sp

	; レジスタの保存
	push	cx
	push	si
	push	di

	; 引数の取得
	cld
	mov	si, [bp + 4]
	mov	di, [bp + 6]
	mov	cx, [bp + 8]

	; バイト単位での比較
	repe cmpsb
	jnz	.10F
	mov	ax, 0
	jmp	.10E
.10F:
	mov	ax, -1
.10E:
	; レジスタの復帰
	pop	di
	pop	si
	pop	cx

	; スタックフレームの破棄
	mov	sp, bp
	pop	bp

	ret
