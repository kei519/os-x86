int_rtc:	; int_rtc(flag)
	; レジスタの保存
	pusha
	push	ds
	push	es

	; データ用セグメントセレクタの設定
	mov	ax, 0x0010
	mov	ds, ax
	mov	es, ax

	; RTCから時刻を取得
	cdecl	rtc_get_time, RTC_TIME		; EAX = get_time(&RTC_TIME)

	; RTCの割り込み要因を取得
	outp	0x70, 0x0C			; outp(0x70, 0x0C) // レジスタCを選択
	in	al, 0x71			; AL = port(0x71)

	; 割り込みフラグをクリア(EOI)
	mov	al, 0x20
	out	0xA0, al			; outp(0xA0, AL) // スレーブPIC
	out	0x20, al			; outp(0x20, AL) // マスタPIC

	; レジスタの復帰
	pop	es
	pop	ds
	popa

	iret					; 割り込み処理の終了

rtc_int_en:
	; スタックフレームの構築
	push	ebp
	mov	ebp, esp

	; レジスタの保存
	push	eax

	; 割り込み許可設定
	outp	0x70, 0x0B			; outp(0x70, 0x0B) // レジスタBを選択

	in	al, 0x71			; AL = port(0x71) // レジスタBの選択
	or	al, [ebp + 8]			; AL |= flag      // 指定されたビットをセット

	out	0x71, al			; outp(0x71, AL) // レジスタBに書き込み

	; レジスタの復帰
	pop	eax

	; スタックフレームの破棄
	mov	esp, ebp
	pop	ebp

	ret