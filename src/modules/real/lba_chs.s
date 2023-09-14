lba_chs:	; bool lba_chs(drive, drv_chs, lba);
	; スタックフレームの構築
	push	bp
	mov	bp, sp

	; レジスタの保存
	push	bx
	push	dx
	push	si
	push	di

	mov	si, [bp + 4]			; SI = drive
	mov	di, [bp + 6]			; DI = drv_chs

	mov	al, [si + drive.head]		; AL = シリンダあたりのヘッド数
	mul	byte [si + drive.sect]		; AX = AL * トラックあたりのセクタ数
	mov	bx, ax				; BX = シリンダあたりのセクタ数

	mov	dx, 0
	mov	ax, [bp + 8]			; AX = LBA
	div	bx				; DX = DX:AX % BX = 残りのセクタ数
						; AX = DX:AX / BX = シリンダ番号

	mov	[di + drive.cyln], ax		; drv_chs->cyln = シリンダ番号

	mov	ax, dx
	div	byte [si + drive.sect]		; AH = AX % トラックあたりのセクタ数 = セクタ番号 - 1
						; AL = AX / トラックあたりのセクタ数 = ヘッド番号

	movzx	dx, ah				; DX = セクタ番号 - 1
	inc	dx

	mov	ah, 0

	mov	[di + drive.head], ax		; drive->head = ヘッド番号
	mov	[di + drive.sect], dx		; drive->sect = セクタ番号

	; 戻り値のセット
	mov	ax, 1

	; レジスタの復帰
	pop	di
	pop	si
	pop	dx
	pop	bx

	; スタックフレームの破棄
	mov	sp, bp
	pop	bp

	ret