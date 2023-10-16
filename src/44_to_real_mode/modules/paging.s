page_set_4m:
	; スタックフレームの構築
	push	ebp
	mov	ebp, esp

	; レジスタの保存
	pusha

	; ページディレクトリの作成(P=0)
	cld					; DFクリア(+方向)
	mov	edi, [ebp + 8]			; EDI = ページディレクトリの先頭
	mov	eax, 0x0000_0000		; EAX = 0
	mov	ecx, 1024			; count = 1024
	rep stosd

	; 先頭のエントリを設定
	mov	eax, edi			; EAX = EDI    // ページディレクトリの直後
	and	eax, ~0x0000_0FFF		; EAX &= ~0FFF // 物理アドレスの指定
	or	eax, 7				; EAX |= 7     // RWの許可
	mov	[edi - (1024 * 4)], eax		; 先頭のエントリを指定

	; ページテーブルの設定(リニア)
	mov	eax, 0x0000_0007		; 物理アドレスの指定とRWの許可
	mov	ecx, 1024			; count = 1024
.10L:
	stosd
	add	eax, 0x0000_1000		; EAX += 0x1000
	loop	.10L

	; レジスタの復帰
	popa

	; スタックフレームの破棄
	mov	esp, ebp
	pop	ebp

	ret

init_page:
	; レジスタの保存
	pusha

	; ページ変換テーブルの作成
	cdecl	page_set_4m, CR3_BASE		; ページ変換テーブルの作成：タスク3用
	cdecl	page_set_4m, CR3_TASK_4		; ページ変換テーブルの作成：タスク4用
	cdecl	page_set_4m, CR3_TASK_5		; ページ変換テーブルの作成：タスク5用
	cdecl	page_set_4m, CR3_TASK_6		; ページ変換テーブルの作成：タスク6用

	; ページテーブルの設定（不在）
	mov	[0x00106000 + 0x107 * 4], dword 0 ; 0x0010_7000をページ不在に設定

	; アドレス変換設定
	mov	[0x0020_1000 + 0x107 * 4], dword PARAM_TASK_4 + 7	; // アドレス変換：タスク4用
	mov	[0x0020_3000 + 0x107 * 4], dword PARAM_TASK_5 + 7	; // アドレス変換：タスク5用
	mov	[0x0020_5000 + 0x107 * 4], dword PARAM_TASK_6 + 7	; // アドレス変換：タスク6用

	; 描画パラメータの設定
	cdecl	memcpy, PARAM_TASK_4, DRAW_PARAM.t4, rose_size	; 描画パラメータ：タスク4用
	cdecl	memcpy, PARAM_TASK_5, DRAW_PARAM.t5, rose_size	; 描画パラメータ：タスク5用
	cdecl	memcpy, PARAM_TASK_6, DRAW_PARAM.t6, rose_size	; 描画パラメータ：タスク6用

	; レジスタの復帰
	popa

	ret