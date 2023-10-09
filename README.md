# 作って理解するOS

書籍、作って理解するOS（ISBN:978-4-297-10847-2）に従ってOSを実装していく。

## tips

- **例外のベクター**：
Intel® 64 and IA-32 Architectures Software Developer’s Manual,
Volume 1: Basic Architecture,
6.5.1(P.165)

- **特権命令**：
Intel® 64 and IA-32 Architectures Software Developer’s Manual,
Volume 3A: System Programming Guide, Part 1,
5.9(p.185)

- **IOPL の変更**：
CPL = 0 のときに、`POPF` もしくは `IRET` で変更できる

- **IN/OUT 命令が一般保護例外を出すタイミング**：
 If the CPL is greater than (has less privilege) the I/O privilege level (IOPL) and any of the 
corresponding I/O permission bits in TSS for the I/O port being accessed is 1.
  - If in protected mode and the CPL is less than or equal to the current IOPL, the processor allows all I/O operations 
to proceed. If the CPL is greater than the IOPL or if the processor is operating in virtual-8086 mode, the processor 
checks the I/O permission bit map to determine if access to a particular I/O port is allowed. Each bit in the map 
corresponds to an I/O port byte address. For example, the control bit for I/O port address 29H in the I/O address 
space is found at bit position 1 of the sixth byte in the bit map. Before granting I/O access, the processor tests all 
the bits corresponding to the I/O port being addressed. For a doubleword access, for example, the processors tests 
the four bits corresponding to the four adjacent 8-bit port addresses. If any tested bit is set, a general-protection 
exception (#GP) is signaled. If all tested bits are clear, the I/O operation is allowed to proceed
