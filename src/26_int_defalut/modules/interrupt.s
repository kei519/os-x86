int_stop:
	; EAX で示される文字列を表示
	cdecl	draw_str, 25, 15, 0x060F, eax	; draw_str(EAX)

	; スタックのデータを文字列に変換
	mov	eax, [esp + 0]			; EAX = ESP[ 0]
	cdecl	itoa, eax, .p1, 8, 16, 0b0100	; itoa(EAX, 8, 16, 0b0100)

	mov	eax, [esp + 4]			; EAX = ESP[ 4]
	cdecl	itoa, eax, .p2, 8, 16, 0b0100	; itoa(EAX, 8, 16, 0b0100)

	mov	eax, [esp + 8]			; EAX = ESP[ 8]
	cdecl	itoa, eax, .p3, 8, 16, 0b0100	; itoa(EAX, 8, 16, 0b0100)

	mov	eax, [esp +12]			; EAX = ESP[12]
	cdecl	itoa, eax, .p4, 8, 16, 0b0100	; itoa(EAX, 8, 16, 0b0100)

	; 文字列の表示
	cdecl	draw_str, 25, 16, 0x0F04, .s1	; draw_str("ESP+ 0:-------- ")
	cdecl	draw_str, 25, 17, 0x0F04, .s2	; draw_str("ESP+ 4:-------- ")
	cdecl	draw_str, 25, 18, 0x0F04, .s3	; draw_str("ESP+ 8:-------- ")
	cdecl	draw_str, 25, 19, 0x0F04, .s4	; draw_str("ESP+12:-------- ")

	; 無限ループ
	jmp	$

.s1	db "ESP+ 0:"
.p1	db "-------- ", 0
.s2	db "ESP+ 4:"
.p2	db "-------- ", 0
.s3	db "ESP+ 8:"
.p3	db "-------- ", 0
.s4	db "ESP+12:"
.p4	db "-------- ", 0

int_default:
	pushf					; EFLAGS
	push	cs
	push	int_stop			; スタック表示処理

	mov	eax, .s0			; 割り込み種別
	iret

.s0	db " <    STOP    > ", 0