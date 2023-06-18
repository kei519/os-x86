; vim: tabstop=8

%macro v_push 1-*
	%rep %0
		push %1
		%rotate 1
	%endrep
%endmacro

	v_push 1, 2, 3, 4
