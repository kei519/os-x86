trap_gate_81:
	; 1文字出力
	cdecl	draw_char, ecx, edx, ebx, eax	; 1文字出力

	iret

trap_gate_82:
	; 点の描画
	cdecl	draw_pixel, ecx, edx, ebx	; 点の描画

	iret