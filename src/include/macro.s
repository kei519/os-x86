; Cの関数風に呼び出すマクロ
%macro	cdecl 1-*.nolist
	%rep	%0 - 1
		push	%{-1:-1}
		%rotate	-1
	%endrep
	%rotate	-1
	call	%1
	%if 1 < %0
		add	sp, (__BITS__ >> 3) * (%0 - 1)
	%endif
%endmacro

struc drive
	.no	resw	1		; ドライブ番号
	.cyln	resw	1		; シリンダ
	.head	resw	1		; ヘッド
	.sect	resw	1		; セクタ
endstruc

%macro	set_vect 1-*
	push	eax
	push	edi

	mov	edi, VECT_BASE + (%1 * 8)	; ベクタアドレス
	mov	eax, %2

    %if 3 == %0
	mov	[edi + 4], %3			; フラグ
    %endif

	mov	[edi + 0], ax			; 例外アドレス[15: 0]
	shr	eax, 16
	mov	[edi + 6], ax			; 例外アドレス[31:16]

	pop	edi
	pop	eax
%endmacro

%macro	outp 2
	mov	al, %2
	out	%1, al
%endmacro

%define	RING_ITEM_SIZE	(1 << 4)
%define RING_INDEX_MASK	(RING_ITEM_SIZE - 1)

struc ring_buff
	.rp	resd	1			; RP：読み込み位置
	.wp	resd	1			; WP：書き込み位置
	.item	resb	RING_ITEM_SIZE		; バッファ
endstruc

%macro	set_desc 2-*
	push	eax
	push	edi

	mov	edi, %1				; ディスクリプタアドレス
	mov	eax, %2				; ベースアドレス

    %if 3 == %0
	mov	[edi + 0], %3			; リミット
    %endif

	mov	[edi + 2], ax			; ベース（[15:0]）
	shr	eax, 16
	mov	[edi + 4], al			; ベース（[23:16]）
	mov	[edi + 7], ah			; ベース（[31:24]）

	pop
