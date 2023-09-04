read_chs:	; int read_chs(drive, sect, dst)
	; スタックフレームの構築
						;    + 8| コピー先
						;    + 6| セクタ数
						;    + 4| パラメータバッファ
						; ------+----------------
						;    + 2| IP（戻り番地）
	push	bp				;  BP+ 0| BP（元の値）
	mov	bp, sp				; ------+----------------
	push	3				;    - 2| リトライ回数
	push	0				;    - 4| 読み込みセクタ数

	; レジスタの保存
	push	bx
	push	cx
	push	dx
	push	es
	push	si

	; 処理の開始
	mov	si, [bp + 4]

	; CXレジスタの設定
	; （BIOSコールの呼び出しに適した形に変換）
	mov	ch, [si + drive.cyln + 0]	; CH = シリンダ番号（下位バイト）
	mov	cl, [si + drive.cyln + 1]	; CL = シリンダ番号（上位バイト）
	shl	cl, 6				; CL <<= 6; // 最上位2ビットにシフト
	or	cl, [si + drive.sect]		; CL |= セクタ番号

	; セクタ読み込み
	mov	dh, [si + drive.head]		; DH = ヘッド番号
	mov	dl, [si + drive.no]		; DL = ドライブ番号
	mov	ax, 0				; AX = 0x0000
	mov	es, ax				; es = セグメント
	mov	bx, [bp + 8]
.10L:
	mov	ah, 0x02			; AH = セクタ読み込み
	mov	al, [bp + 6]			; AL = セクタ数

	int	0x13				; CF = BIOS(0x13, AH)
	jnc	.11E

	mov	al, 0
	jmp	.10E
.11E:
	cmp	al, 0
	jne	.10E

	mov	ax, 0
	dec	word [bp - 2]
	jnz	.10L
.10E:
	mov	ah, 0

	; レジスタの復帰
	pop	si
	pop	es
	pop	dx
	pop	cx
	pop	bx

	; スタックフレームの破棄
	mov	sp, bp
	pop	bp

	ret
