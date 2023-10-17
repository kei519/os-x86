ctrl_alt_end:
	; スタックフレームの構築
	push	ebp
	mov	ebp, esp

	push	ebx

	; キー状態保存
	mov	eax, [ebp + 8]			; EAX = key

	btr	eax, 7				; CF = EAX & 0x80
	jc	.10F
	bts	[.key_state], eax		; フラグセット
	jmp	.10E
.10F:
	btr	[.key_state], eax		; フラグクリア
.10E:
	; キー押下判定
	mov	eax, 0x1D			; [Ctrl]キーが押されているか？
	bt	[.key_state], eax
	jnc	.22E

	mov	eax, 0x38			; [Alt]キーが押されているか？
	bt	[.key_state], eax
	jnc	.22E

	mov	eax, 0x4F			; [End]キーが押されているか？
	bt	[.key_state], eax
	jnc	.22E
	jmp	.24E

	; 上記のチェックは、ctrl + alt を押したあとの End が qemu? 上では
	; 正常に動かないため（End だけ押下しないと 0x4F にならない）、
	; 下でもチェックする
.22E:
	mov	eax, 0x53
	bt	[.key_state], eax
	jnc	.20E

.24E:
	mov	eax, -1

.20E:
	sar	eax, 8				; ret >>= 8

	pop	ebx

	; スタックフレームの破棄
	mov	esp, ebp
	pop	ebp

	ret

.key_state:	times 32 db 0