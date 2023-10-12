%define	USE_SYSTEM_CALL
%define USE_TEST_AND_SET

%include	"../include/define.s"
%include	"../include/macro.s"

	ORG	KERNEL_LOAD

[BITS 32]
; エントリポイント
kernel:
	; フォントアドレスの取得
	mov	esi, BOOT_LOAD + SECT_SIZE	; ESI = 0x7C00 + 512
	movzx	eax, word [esi + 0]		; EAX = [ESI + 0] = セグメント
	movzx	ebx, word [esi + 2]		; EBX = [ESI + 2] = オフセット
	shl	eax, 4				; EAX <<= 4
	add	eax, ebx			; EAX = セグメント << 4 + オフセット
	mov	[FONT_ADR], eax			; *FONT_ADR = EAX

	; TSSディスクリプタの設定
	set_desc	GDT.tss_0, TSS_0	; タスク0用TSSの設定
	set_desc	GDT.tss_1, TSS_1	; タスク1用TSSの設定
	set_desc	GDT.tss_2, TSS_2	; タスク2用TSSの設定
	set_desc	GDT.tss_3, TSS_3	; タスク3用TSSの設定

	; コールゲートの設定
	set_gate	GDT.call_gate, call_gate	; コールゲートの設定

	; LDTの設定
	set_desc	GDT.ldt, LDT, word LDT_LIMIT

	; GDTをロード（再設定）
	lgdt	[GDTR]				; グローバルディスクリプタテーブルをロード

	; スタックの設定
	mov	esp, SP_TASK_0			; タスク0用のスタックを設定

	; タスクレジスタの初期化
	mov	ax, SS_TASK_0
	ltr	ax				; タスクレジスタの設定

	; 初期化
	cdecl	init_int			; 割り込みベクタの初期化
	cdecl	init_pic			; 割り込みコントローラの初期化
	cdecl	init_page			; ページングの初期化

	set_vect	0x00, int_zero_div	; 割り込み処理の登録：0除算
	set_vect	0x07, int_nm		; 割り込み処理の登録：デバイス使用不可
	set_vect	0x20, int_timer		; 割り込み処理の登録：タイマー
	set_vect	0x21, int_keyboard	; 割り込み処理の登録：KBC
	set_vect	0x28, int_rtc		; 割り込み処理の登録：RTC
	set_vect	0x81, trap_gate_81, word 0xEF00	; トラップゲートの登録：1文字出力
	set_vect	0x82, trap_gate_82, word 0xEF00	; トラップゲートの登録：点の描画

	; デバイスの割り込み許可
	cdecl	rtc_int_en, 0x10		; rtc_int_en(UIE) // 更新サイクル終了割り込み許可
	cdecl	int_en_timer0			; int_en_timer0() // タイマーの割り込みを10msで設定

	; IMR（割り込みマスクレジスタ）の設定
	outp	0x21, 0b1111_1000		; 割り込み有効：スレーブPIC/KBC/タイマー
	outp	0xA1, 0b1111_1110		; 割り込み有効：RTC

	; ページテーブルの登録
	mov	eax, CR3_BASE
	mov	cr3, eax

	; ページングの有効化
	mov	eax, cr0
	or	eax, (1 << 31)			; CR0 |= PG
	mov	cr0, eax
	jmp	$ + 2				; FLUSH()

	; CPUの割り込み許可
	sti					; 割り込み許可

	; フォントの一覧表示
	cdecl	draw_font, 63, 13		; フォントの一覧表示
	cdecl	draw_color_bar, 63, 4		; カラーバーの表示

	; 文字列の表示
	cdecl	draw_str, 25, 14, 0x010F, .s0

.10L:
	; キーコード履歴の表示
	cdecl	ring_rd, _KEY_BUFF, .int_key	; EAX = ring_rd(_KEY_BUFF, &.int_key)
	cmp	eax, 0
	je	.10E

	cdecl	draw_key, 2, 29, _KEY_BUFF	; draw_key(2, 29, _KEY_BUFF)
.10E:
	; 回転する棒を表示
	cdecl	draw_rotation_bar		; draw_rotation_bar()

	jmp	.10L

	; 処理の終了
	jmp	$

.s0	db " Hello, kernel! ", 0

ALIGN 4, db 0
.int_key	dd 0
FONT_ADR:	dd 0
RTC_TIME:	dd 0

; モジュール
%include	"../modules/protect/vga.s"
%include	"../modules/protect/draw_char.s"
%include	"../modules/protect/draw_font.s"
%include	"../modules/protect/draw_str.s"
%include	"../modules/protect/draw_color_bar.s"
%include	"../modules/protect/draw_pixel.s"
%include	"../modules/protect/draw_line.s"
%include	"../modules/protect/draw_rect.s"
%include	"../modules/protect/itoa.s"
%include	"../modules/protect/rtc.s"
%include	"../modules/protect/draw_time.s"
%include	"../modules/protect/interrupt.s"
%include	"../modules/protect/pic.s"
%include	"../modules/protect/int_rtc.s"
%include	"../modules/protect/ring_buff.s"
%include	"../modules/protect/int_keyboard.s"
%include	"../modules/protect/timer.s"
%include	"../modules/protect/draw_rotation_bar.s"
%include	"../modules/protect/call_gate.s"
%include	"../modules/protect/trap_gate.s"
%include	"../modules/protect/test_and_set.s"
%include	"../modules/protect/int_nm.s"
%include	"../modules/protect/wait_tick.s"
%include	"./modules/int_timer.s"
%include	"./modules/paging.s"
%include	"./descriptor.s"
%include	"./tasks/task_1.s"
%include	"./tasks/task_2.s"
%include	"./tasks/task_3.s"

; パディング
	times KERNEL_SIZE - ($ - $$)	db 0