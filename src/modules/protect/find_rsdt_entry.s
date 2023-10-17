find_rsdt_entry:	; int find_rsdt_entry(facp, word)
	; スタックフレームの構築
	push	ebp
	mov	ebp, esp

	; レジスタの保存
	push	ebx
	push	ecx
	push	esi
	push	edi

	mov	ebx, 0

	; 引数を取得
	mov	esi, [ebp + 8]		; ESI = RSDT
	mov	ecx, [ebp +12]		; ECX = 名前

	; ACPIテーブル検索処理
	mov	edi, esi		; EDI = &ENTRY[MAX]
	add	edi, [esi + 4]		; ESI = &ENTRY[0]
	add	esi, 36
.10L:
	cmp	esi, edi
	jge	.10E

	lodsd				; EAX = [ESI++] // エントリ

	cmp	[eax], ecx
	jne	.12E
	mov	ebx, eax
	jmp	.10E
.12E:	jmp	.10L
.10E:
	mov	eax, ebx

	; レジスタの復帰
	pop	edi
	pop	esi
	pop	ecx
	pop	ebx

	; スタックフレームの破棄
	mov	esp, ebp
	pop	ebp

	ret