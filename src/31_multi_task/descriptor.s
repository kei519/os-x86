GDT:		dq 0x00_0_0_0_0_000000_0000	; NULL
.cs_kernel:	dq 0x00_C_F_9_A_000000_FFFF	; CODE 4G
.ds_kernel:	dq 0x00_C_F_9_2_000000_FFFF	; DATA 4G
.ldt:		dq 0x0000820000000000
.gdt_end:


LDT:		dq 0x0000000000000000		; NULL
.cs_task_0:	dq 0x00CF9A000000FFFF		; CODE 4G
.ds_task_0:	dq 0x00CF92000000FFFF		; DATA 4G
.cs_task_1:	dq 0x00CF9A000000FFFF		; CODE 4G
.ds_task_0:	dq 0x00CF92000000FFFF		; DATA 4G
.end:

CS_TASK_0	equ (.cs_task_0 - LDT) | 4	; タスク0用CSセレクタ
DS_TASK_0	equ (.ds_task_0 - LDT) | 4	; タスク0用CSセレクタ
CS_TASK_1	equ (.cs_task_1 - LDT) | 4	; タスク1用CSセレクタ
DS_TASK_1	equ (.ds_task_1 - LDT) | 4	; タスク1用CSセレクタ

LDT_LIMIT	equ .end	- LDT - 1