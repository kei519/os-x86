acpi_find:	; int acpi_find(address, size, word)
	; スタックフレームの構築
	push	ebp
	mov	ebp, esp

	; レジスタの保存
	push	ecx
	push	edi

	; 引数を取得
	mov	edi, [ebp + 8]		; EDI = アドレス
	mov	ecx, [ebp +12]		; ECX = サイズ
	mov	eax, [ebp +16]		; EAX = 検索データ

	; 名前の検索
	cld				; DFクリア（+方向）

.10L:
	repne	scasb

	cmp	ecx, 0
	jnz	.11E
	mov	eax, 0
	jmp	.10E
.11E:
	cmp	eax, [es:edi - 1]
	jne	.10L

	dec	edi
	mov	eax, edi
.10E:
	; レジスタの復帰
	pop	edi
	pop	ecx

	; スタックフレームの破棄
	mov	esp, ebp
	pop	ebp

	ret