itoa:	; void itoa(num, buff, size, radix, flags)
	; スタックフレームの構築
	push	bp
	mov	bp, sp

	; レジスタの保存
	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di

	; 引数を取得
	mov	ax, [bp + 4]		; AX = num
	mov	si, [bp + 6]		; SI = buff
	mov	cx, [bp + 8]		; CX = size

	mov	di, si			; バッファの最後尾
	add	di, cx			; DI = buff + size - 1
	dec	di

	mov	bx, word [bp + 12]	; BX = flags

	; 符号付き判定
	test	bx, 0b0001
.10Q:	jz	.10E
	cmp	ax, 0
.12Q:	jge	.12E
	or	bx, 0b0010
.12E:
.10E:

	; 符号出力判定
	test	bx, 0b0010
.20Q:	jz	.20E
	cmp	ax, 0
.22Q:	jge	.22F
	neg	ax
	mov	[si], byte '-'
	jmp	.22E
.22F:
	mov	[si], byte '+'
.22E:
	dec	cx
.20E:

	; ASCII変換
	mov	bx, [bp + 10]		; BX = radix
.30L:
	mov	dx, 0
	div	bx

	mov	si, dx
	mov	dl, byte [.ascii + si]

	mov	[di], dl
	dec	di

	cmp	ax, 0
	loopnz	.30L
.30E:

	; 空欄を埋める
	cmp	cx, 0
.40Q:	je	.40E
	test	[bp + 12], byte 0b0100
	jz	.42Q
	mov	al, byte '0'
	jmp	.42E
.42Q:	mov	al, byte ' '
.42E:
	std
	rep stosb
.40E:

	; レジスタの復帰
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax

	; スタックフレームの破棄
	mov	sp, bp
	pop	bp

	ret

.ascii	db	"0123456789ABCDEF", 0	; 変換テーブル