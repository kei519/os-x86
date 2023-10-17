power_off:
	; スタックフレームの構築
	push	ebp
	mov	ebp, esp

	; レジスタの保存
	push	eax
	push	ebx
	push	ecx
	push	edx

	cdecl	draw_str, 25, 14, 0x020F, .s0

	; ページングを無効化
	mov	eax, cr0			; PGビットをクリア
	and	eax, 0x7FFF_FFFF		; CR0 &= ~PG
	mov	cr0, eax
	jmp	$ + 2

	; ACPIデータの確認
	mov	eax, [BOOT_LOAD + SECT_SIZE + 4]	; EAX = ACPIアドレス
	mov	ebx, [BOOT_LOAD + SECT_SIZE + 8]	; EAX = 長さ
	cmp	eax, 0
	je	.10E

	; RSDTテーブルの検索
	cdecl	acpi_find, eax, ebx, 'RSDT'	; EAX = acpi_find('RSDT')
	cmp	eax, 0
	je	.10E

	; FACPテーブルの検索
	cdecl	find_rsdt_entry, eax, 'FACP'	; EAX = find_rsdt_entry('FACP')
	cmp	eax, 0
	je	.10E

	mov	ebx, [eax + 40]			; DSDTアドレスの取得
	cmp	ebx, 0
	je	.10E

	; ACPIレジスタの設定
	mov	ecx, [eax + 64]			; ACPIレジスタの取得
	mov	[PM1a_CNT_BLK], ecx		; PM1a_CNT_BLK = FACP.PM1a_CNT_BLK
	
	mov	ecx, [eax + 68]			; ACPIレジスタの取得
	mov	[PM1b_CNT_BLK], ecx		; PM1b_CNT_BLK = FACP.PM1b_CNT_BLK

	; S5名前空間の検索
	mov	ecx, [ebx + 4]			; ECX = DSDT.Length // データ長
	sub	ecx, 36				; ECX -= 36         // テーブルヘッダ分減算
	add	ebx, 36				; EBX += 36         // テーブルヘッダ分加算
	cdecl	acpi_find, ebx, ecx, '_S5_'	; EAX = acpi_find('_S5_')
	cmp	eax, 0
	je	.10E

	; パッケージデータの取得
	add	eax, 4				; EAx = 先頭の要素
	cdecl	acpi_package_value, eax		; EAX = パッケージデータ
	mov	[S5_PACKAGE], eax		; S5_PACKAGE = EAX;

.10E:
	; ページングを有効化
	mov	eax, cr0			; PGビットをセット
	or	eax, (1 << 31)			; CR0 |= PG
	mov	cr0, eax
	jmp	$ + 2

	; ACPIレジスタの取得
	mov	edx, [PM1a_CNT_BLK]		; EDX = FACP.PM1a_CNT_BLK
	cmp	edx, 0
	je	.20E

	; カウントダウンの表示
	cdecl	draw_str, 38, 14, 0x020F, .s3	; draw_str() // カウントダウン...3
	cdecl	wait_tick, 100
	cdecl	draw_str, 38, 14, 0x020F, .s2	; draw_str() // カウントダウン...2
	cdecl	wait_tick, 100
	cdecl	draw_str, 38, 14, 0x020F, .s1	; draw_str() // カウントダウン...1
	cdecl	wait_tick, 100

	; PM1a_CNT_BLKの設定
	movzx	ax, [S5_PACKAGE.0]		; PM1a_CNT_BLK
	shl	ax, 10				; AX |= SLP_TYPx
	or	ax, 1 << 13			; AX |= SLP_EN
	out	dx, ax				; out(PM1b_CNT_BLK, AX)

	; PM1b_CNT_BLKの確認
	mov	edx, [PM1b_CNT_BLK]		; EBX = FACP.PM1b_CNT_BLK
	cmp	edx, 0
	je	.20E

	; PM1b_CNT_BLKの設定
	movzx	ax, [S5_PACKAGE.1]		; PM1b_CNT_BLK
	shl	ax, 10				; AX = SLP_TYPx
	or	ax, 1 << 13			; AX |= SLP_EN;
	out	dx, ax				; out(PM1b_CNT_BLK, AX)

.20E:
	; 電断待ち
	cdecl	wait_tick, 100			; 100[ms]ウェイト

	; 電断失敗メッセージ
	cdecl	draw_str, 38, 14, 0x020F, .s4	; draw_str() // 電断失敗メッセージ

	; レジスタの復帰
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax
	
	; スタックフレームの破棄
	mov	esp, ebp
	pop	ebp

	ret

.s0:	db " Power off...   ", 0
.s1:	db " 1", 0
.s2:	db " 2", 0
.s3:	db " 3", 0
.s4:	db "NG", 0
ALIGN 4, db 0
PM1a_CNT_BLK:	dd 0
PM1b_CNT_BLK:	dd 0

S5_PACKAGE:
.0:		db 0
.1:		db 0
.2:		db 0
.3:		db 0
