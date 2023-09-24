itoa:	; void itoa(num, buff, size, radix, flags)
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

	; 引数を取得
	mov	eax, [ebp + 8]		; AX = num
	mov	esi, [ebp +12]		; SI = buff
	mov	ecx, [ebp +16]		; CX = size

	mov	edi, esi		; バッファの最後尾
	add	edi, ecx		; DI = buff + size - 1
	dec	edi

	mov	ebx, [ebp +24]		; BX = flags

	; 符号付き判定
	test	ebx, 0b0001
.10Q:	jz	.10E
	cmp	eax, 0
.12Q:	jge	.12E
	or	ebx, 0b0010
.12E:
.10E:

	; 符号出力判定
	test	ebx, 0b0010
.20Q:	jz	.20E
	cmp	eax, 0
.22Q:	jge	.22F
	neg	eax
	mov	[esi], byte '-'
	jmp	.22E
.22F:
	mov	[esi], byte '+'
.22E:
	dec	ecx
.20E:

	; ASCII変換
	mov	ebx, [ebp +20]		; BX = radix
.30L:
	mov	edx, 0
	div	ebx

	mov	esi, edx
	mov	dl, byte [.ascii + esi]

	mov	[edi], dl
	dec	edi

	cmp	eax, 0
	loopnz	.30L
.30E:

	; 空欄を埋める
	cmp	ecx, 0
.40Q:	je	.40E
	test	[ebp +24], byte 0b0100
	jz	.42Q
	mov	al, byte '0'
	jmp	.42E
.42Q:	mov	al, byte ' '
.42E:
	std
	rep stosb
.40E:

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

.ascii	db	"0123456789ABCDEF", 0	; 変換テーブル