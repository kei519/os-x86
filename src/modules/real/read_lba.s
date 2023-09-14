read_lba:	; int read_lba(drive, lba, sect, dst)
	; スタックフレームの構築
	push	bp
	mov	bp, sp

	; レジスタの保存
	push	si

	mov	si, [bp + 4]				; SI = ドライブ情報

	; LBA→CHS変換
	mov	ax, [bp + 6]				; AX = LBA
	cdecl	lba_chs, si, .chs, ax

	; ドライブ番号のコピー
	mov	al, [si + drive.no]
	mov	[.chs + drive.no], al			; .chs->no = ドライブ番号

	; セクタの読み込み
	cdecl	read_chs, .chs, word [bp + 8], word [bp + 10]
							; AX = read_chs(.chs, sect, dst)

	; レジスタの復帰
	pop	si

	; スタックフレームの破棄
	mov	sp, bp
	pop	bp

	ret

.chs:	times drive_size	db 0