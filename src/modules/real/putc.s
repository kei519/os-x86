putc:
	; スタックフレームの構築
	push	bp
	mov	bp, sp

	; レジスタの保存
	push	ax
	push	bx

	; 処理の開始
	mov	al, [bp + 4]		; 文字コードの取得
	mov	ah, 0x0E		; テレタイプ式1文字出力
	mov	bx, 0			; ページ番号と文字色を0に設定
	int	0x10			; ビデオBIOSコール

	; レジスタの復帰
	pop	bx
	pop	ax

	; スタックフレームの破壊
	mov	sp, bp
	pop	bp

	ret
