get_tss_base:
	mov	eax, [GDT + ebx + 2]		; EAX   = TSS[23: 0]
	shl	eax, 8				; EAX <<= 8
	mov	al, [GDT + ebx + 7]		;  AL   = TSS[31:24]
	ror	eax, 8				; EAX >>= 8

	ret

save_fpu_context:
	fnsave	[eax + 104]			; FPUコンテキストを保存
	mov	[eax + 104 + 108], dword 1	; saved = 1

	ret

load_fpu_context:
	cmp	[eax + 104 + 108], dword 0
	jne	.10F
	fninit
	jmp	.10E
.10F:
	frstor	[eax + 104]
.10E:
	ret

int_nm:
	; レジスタの保存
	pusha
	push	ds
	push	es

	; カーネル用セレクタを設定
	mov	ax, DS_KERNEL
	mov	ds, ax
	mov	es, ax

	; タスクスイッチフラグをクリア
	clts

	; 前回/今回FPUを使用するタスク
	mov	edi, [.last_tss]		; EDI = 前回FPUを使用したタスクのTSS
	str	esi				; ESI = 今回FPUを使用したタスクのTSS
	and	esi, ~0x0007			; 特権レベルをマスク

	; FPUの初回利用をチェック
	cmp	edi, 0
	je	.10F

	cmp	esi, edi
	je	.10E

	cli					; 割り込み禁止

	; 前回のFPUコンテキストを保存
	mov	ebx, edi			; 前回のタスク
	call	get_tss_base			; TSSアドレスを取得
	call	save_fpu_context		; FPUのコンテキストを復帰

.10F:
	cli					; 割り込み禁止

	; 今回のFPUコンテキストを復帰
	mov	ebx, esi			; 今回のタスク
	call	get_tss_base			; 現在のタスクのTSSアドレスを取得
	call	load_fpu_context		; FPUのコンテキストを復帰

	sti
.10E:
	mov	[.last_tss], esi		; FPUを使用したタスクを保存

	; レジスタの復帰
	pop	es
	pop	ds
	popa

	iret

ALIGN 4, db 0
.last_tss: dd 0