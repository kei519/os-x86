; マクロ
%include	"../include/define.s"
%include	"../include/macro.s"

	ORG	BOOT_LOAD

; エントリポイント
entry:
	;BPM (Boot Parameter Block)
	jmp	ipl
	times	90 - ($ - $$) db 0x90

	;IPL (Initial Program Loader)
ipl:
	cli					; 割り込み禁止

	mov	ax, 0
	mov	ds, ax
	mov	es, ax
	mov	ss, ax
	mov	sp, BOOT_LOAD

	sti					; 割り込み許可

	mov	[BOOT + drive.no], dl

	; 文字列を表示
	cdecl	puts, .s0

	; 残りのセクタをすべて読み込む
	mov	bx, BOOT_SECT - 1		; BX = 残りのブートセクタ数
	mov	cx, BOOT_LOAD + SECT_SIZE	; CX = 次のロードアドレス

	cdecl	read_chs, BOOT, bx, cx		; AX = read_chs(.chs, bx, cx)

	cmp	ax, bx				; AX != 残りのセクタ数 のとき
.10Q:	jz	.10E
.10T:	cdecl	puts, .e0
	call	reboot
.10E:
	; 次のステージへ移行
	jmp	stage_2				; ブート処理の第2ステージ

	; データ
.s0	db	"Booting...", 0x0A, 0x0D, 0
.e0	db	"Error: sector read", 0

; ブートドライブに関する情報
ALIGN 2, db 0
BOOT:						; ブートドライブに関する情報
	istruc	drive
	    at	drive.no,	dw 0		; ドライブ番号
	    at	drive.cyln,	dw 0		; C: シリンダ
	    at	drive.head,	dw 0		; H: ヘッド
	    at	drive.sect,	dw 2		; S: セクタ
	iend

; モジュール
%include	"../modules/real/puts.s"
%include	"../modules/real/reboot.s"
%include	"../modules/real/read_chs.s"

; ブートフラグ
	times (SECT_SIZE - 2) - ($ - $$) db 0x00
	db 0x55, 0xAA

; リアルモード時に取得した情報
FONT:						; フォント
.seg:	dw 0
.off:	dw 0
ACPI_DATA:
.adr:	dd 0
.len:	dd 0

; モジュール（先頭512バイト以降に配置）
%include "../modules/real/itoa.s"
%include "../modules/real/get_drive_param.s"
%include "../modules/real/get_font_adr.s"
%include "../modules/real/get_mem_info.s"
%include "../modules/real/kbc.s"

; ブート処理の第2ステージ
stage_2:
	; ドライブ情報を取得
	cdecl	get_drive_param, BOOT
	cmp	ax, 0
.10Q:	jne	.10E
.10T:	cdecl	puts, .e0
	call	reboot
.10E:
	; ドライブ情報を表示
	mov	ax, [BOOT + drive.no]		; AX = ブートドライブ
	cdecl	itoa, ax, .p1, 2, 16, 0b0100
	mov	ax, [BOOT + drive.cyln]
	cdecl	itoa, ax, .p2, 4, 16, 0b0100
	mov	ax, [BOOT + drive.head]
	cdecl	itoa, ax, .p3, 2, 16, 0b0100
	mov	ax, [BOOT + drive.sect]
	cdecl	itoa, ax, .p4, 2, 16, 0b0100
	cdecl	puts, .s1

	; 次のステージへ移行
	jmp	stage_3rd			; 無限ループ

	; データ
.s0	db "2nd stage...", 0x0A, 0x0D, 0

.s1	db " Drive:0x"
.p1	db "  , C:0x"
.p2	db "    , H:0x"
.p3	db "  , S:0x"
.p4	db "  ", 0x0A, 0x0D, 0

.e0	db "Can't get drive parameter.", 0

stage_3rd:
	; 文字列を表示
	cdecl	puts, .s0

	; プロテクトモードで使用するフォントは、
	; BIOSに内蔵されたものを流用する
	cdecl	get_font_adr, FONT

	; フォントアドレスの表示
	cdecl	itoa, word [FONT.seg], .p1, 4, 16, 0b0100
	cdecl	itoa, word [FONT.off], .p2, 4, 16, 0b0100
	cdecl	puts, .s1

	; メモリ情報の取得と表示
	cdecl	get_mem_info
	mov	eax, [ACPI_DATA.adr]
	cmp	eax, 0
	je	.10E

	cdecl	itoa, ax, .p4, 4, 16, 0b0100
	shr	eax, 16
	cdecl	itoa, ax, .p3, 4, 16, 0b0100
	cdecl	puts, .s2
.10E:
	; 処理の終了
	jmp	stage_4

	; データ
.s0	db "3rd stage...", 0x0A, 0x0D, 0

.s1	db " Font Address="
.p1	db "ZZZZ:"
.p2	db "ZZZZ", 0x0A, 0x0D, 0
	db 0x0A, 0x0D, 0

.s2	db " ACPI data="
.p3	db "ZZZZ"
.p4	db "ZZZZ", 0x0A, 0x0D, 0

stage_4:
	; 文字列を表示
	cdecl	puts, .s0

	; A20ゲートの有効化
	cli					; 割込み禁止
	cdecl	KBC_Cmd_Write, 0xAD		; キーボード無効化

	cdecl	KBC_Cmd_Write, 0xD0		; 出力ポート読み出し
	cdecl	KBC_Data_Read, .key		; 出力ポートデータ

	mov	bl, [.key]
	or	bl, 0x02			; B1 をセット

	cdecl	KBC_Cmd_Write, 0xD1		; 出力ポート書き込みコマンド
	cdecl	KBC_Data_Write, bx		; 出力ポートデータ

	cdecl	KBC_Cmd_Write, 0xAE		; キーボード有効化
	sti					; 割り込み許可

	; 文字列を表示
	cdecl	puts, .s1

	; 処理の終了
	jmp	$

.s0	db "4th stage...", 0x0A, 0x0D, 0
.s1	db " A20 Gate Enabled.", 0x0A, 0x0D, 0

.key	dw 0

; パディング（このファイルは8Kバイトとする）
	times BOOT_SIZE - ($ - $$)	db 0	; パディング
