task_2:
	cdecl	draw_str, 63, 1, 0x07, .s0	;draw_str(s0);

	fild	dword [.c1000]			; push 1000
	fldpi					; push pi
	fidiv	dword [.c180]			; st0 /= 180
	fldpi					; push pi
	fadd	st0, st0			; st0 += st0
	fldz					; push 0

.10L:
	fadd	st0, st2			; st0 += st2
	fprem					; st0 %= st1
	fld	st0				; push st0
	fsin					; st0 = sin(st0)
	fmul	st0, st4			; st0 *= st4 (=1000)
	fbstp	[.bcd]				; pop [bcd] (BCD形式)

	mov	eax, [.bcd]			; EAX = [bcd]
	mov	ebx, eax			; EBX = EAX

	and	eax, 0x0F0F			; 上位4ビットをクリア
	or	eax, 0x3030			; 上位4ビットに0x3を設定

	shr	ebx, 4				; EBX >>= 4
	and	ebx, 0x0F0F			; 上位4ビットをクリア
	or	ebx, 0x3030			; 上位4ビットに0x3を設定

	mov	[.s2 + 0], bh
	mov	[.s3 + 0], ah
	mov	[.s3 + 1], bl
	mov	[.s3 + 2], al

	mov	eax, 7
	bt	[.bcd + 9], eax			; CF = bcd[9] & 0x80 (bcd[9]の7bit目)
	jc	.10F

	mov	[.s1 + 0], byte '+'
	jmp	.10E
.10F:
	mov	[.s1 + 0], byte '-'
.10E:
	cdecl	draw_str, 72, 1, 0x07, .s1	; draw_str(s1)

	; ウェイト
	cdecl	wait_tick, 10			; wait_tick(10)

	jmp	.10L

ALIGN 4, db 0
.c1000:		dd 1000
.c180:		dd 180
.bcd:	times 10 db 0x00
.s0	db "Task-2", 0
.s1	db "-"
.s2	db "0."
.s3	db "000", 0