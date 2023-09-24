rtc_get_time:	; bool rtc_get_time(dst)
	; スタックフレームの構築
	push	ebp
	mov	ebp, esp

	; レジスタの保存
	push	eax
	push	ebx

	mov	al, 0x0A			; AL = 0x0A
	out	0x70, al			; RTC レジスタA
	in	al, 0x71			; AL = レジスタA
	test	al, 0x80
	je	.10F
	mov	eax, 1
	jmp	.10E
.10F:
	mov	al, 0x04			; AL = 0x04
	out	0x70, al			; RTC 時間データ
	in	al, 0x71			; AL = 時間
	shl	eax, 8				; EAX <<= 8

	mov	al, 0x02			; AL = 0x02
	out	0x70, al			; RTC 分データ
	in	al, 0x71			; AL = 分
	shl	eax, 8				; EAX <<= 8

	mov	al, 0x00			; AL = 0x00
	out	0x70, al			; RTC 秒データ
	in	al, 0x71			; AL = 秒

	and	eax, 0x00_FF_FF_FF		; EAXの下位3バイトのみ

	mov	ebx, [ebp + 8]			; EBX = dst
	mov	[ebx], eax			; *dst = 時刻
.10E:
	; レジスタの復帰
	pop	ebx
	pop	eax

	; スタックフレームの破棄
	mov	esp, ebp
	pop	ebp

	ret