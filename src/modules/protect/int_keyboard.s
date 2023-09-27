int_keyboard:
	; レジスタの保存
	pusha
	push	ds
	push	es

	; データ用セグメントの設定
	mov	ax, 0x0010
	mov	ds, ax
	mov	es, ax

	; KBCのバッファ読み取り
	in	al, 0x60			; AL = キーコードの取得

	; キーコードの保存
	cdecl	ring_wr, _KEY_BUFF, eax		; EAX = ring_wr(_KEY_BUFF, EAX) // キーコードの保存

	; 割り込み終了コマンド
	outp	0x20, 0x20			; outp(0x20, 0x20) // マスタPIC：EOIコマンド

	; レジスタの復帰
	pop	es
	pop	ds
	popa

	iret

ALIGN 4, db 0
_KEY_BUFF:	times ring_buff_size db 0