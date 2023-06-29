puts:	; void puts(str)
	; スタックフレームの構築
	push	bp
	mov	bp, sp

	; レジスタの保存
	push	ax
	push	bx
	push	si

	; 引数を取得
	mov	si, [bp + 4]

	; 処理の開始
	mov	ah, 0x0E		; テレタイプ式1文字出力
	mov	bx, 0x0000		; ページ番号と文字色を0に設定
	cld				; DF(Direction Flag) = 0	ストリング命令で加算
.10L:
	lodsb				; al = [si]; si++;

	cmp	al, 0
	je	.10E

	int	0x10
	jmp	.10L
.10E:

	; レジスタの復帰
	pop	si
	pop	bx
	pop	ax

	; スタックフレームの破棄
	mov	sp, bp
	pop	bp

	ret
