	BOOT_LOAD	equ	0x7C00		; ブートプログラムのロード位置

	ORG	BOOT_LOAD

; マクロ
%include	"../include/macro.s"

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

	mov	[BOOT.DRIVE], dl

	; 文字列を表示
	cdecl	puts, .s0

	; 次の512バイトを読み込む
	mov	ah, 0x02			; AH = 読み込み命令
	mov	al, 1				; AL = 読み込みセクタ
	mov	cx, 0x0002			; CX = シリンダ / セクタ
	mov	dl, [BOOT.DRIVE]		; DL[0:6] = ドライブ番号
	mov	bx, BOOT_LOAD + 0x200		; ES:BX = 読み込みオフセット
	int	0x13				; if (CF = BIOS(0x13, ah)) {
.10Q:	jnc	.10E				; {
.10T:	cdecl	puts, .e0			;   puts(.e0);
	call	reboot				;   reboot();  // 再起動
.10E:						; }
	; 次のステージへ移行
	jmp	stage_2				; ブート処理の第2ステージ

	; データ
.s0	db	"Booting...", 0x0A, 0x0D, 0
.e0	db	"Error: sector read", 0

ALIGN 2, db 0
BOOT:						; ブートドライブに関する情報
.DRIVE		dw 0				; ドライブ番号

; モジュール
%include	"../modules/real/puts.s"
%include	"../modules/real/reboot.s"

; ブートフラグ
	times 510 - ($ - $$) db 0x00
	db 0x55, 0xAA

; ブート処理の第2ステージ
stage_2:
	; 文字列表示
	cdecl	puts, .s0

	; 処理の終了
	jmp	$				; 無限ループ

	; データ
.s0	db "2nd stage...", 0x0A, 0x0D, 0

; パディング（このファイルは8Kバイトとする）
	times (0x400 * 8) - ($ - $$)	db 0
