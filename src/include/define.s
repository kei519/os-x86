BOOT_SIZE	equ	(1024 * 8)		; ブートコードサイズ

KERNEL_SIZE	equ	(1024 * 8)		; カーネルサイズ

BOOT_LOAD	equ	0x7C00			; ブートプログラムのロード位置

BOOT_END	equ	(BOOT_LOAD + BOOT_SIZE)

KERNEL_LOAD	equ	0x0010_1000		; カーネルがロードされる位置

SECT_SIZE	equ	(512)			; セクタサイズ

BOOT_SECT	equ	(BOOT_SIZE / SECT_SIZE)	; ブートプログラムのセクタ数

KERNEL_SECT	equ	(KERNEL_SIZE / SECT_SIZE)

VECT_BASE	equ	0x0010_0000		; 0010_0000:0010_07FF

STACK_BASE	equ	0x0010_3000		; タスク用スタックエリア

STACK_SIZE	equ	1024			; スタックサイズ

SP_TASK_0	equ	STACK_BASE + (STACK_SIZE * 1)

SP_TASK_1	equ	STACK_BASE + (STACK_SIZE * 2)
SP_TASK_2	equ	STACK_BASE + (STACK_SIZE * 3)
