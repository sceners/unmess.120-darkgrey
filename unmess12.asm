; Mess v1.20 *unpacker* (c) DarkGrey // Delirium Tremens
; Near 200-300 polymorph bytes code only.... But such!
; Partly optimized by MERLiN // Delirium Tremens

                model   tiny
                .code
                .startup
                .386
                jumps
;-
                mov     ah, 09h
                mov     dx, offset msg
                int     21h
;-
                mov     si, 81h
                lodsb
                cmp     al, 0dh
                je      usage_
;-
                xor     ax, ax
                mov     si, 80h
                lodsb
                add     si, ax
                mov     [sh], al
                xchg    si, di
                mov     al, 00h
                stosb
;-
                mov     si, 82h
                mov     dx, si
;-
                mov     ah, 09h
                mov     dx, offset pf
                int     021h
;-
                mov     ah, 40h
                xor     ch, ch
                mov     cl, [sh]
                mov     bx, 1
                mov     dx, 82h
                int     021h
;-
                mov     ax, 3d02h
                mov     dx, 82h
                int     21h
                mov     [hr], ax
                jc      errs
;-
                mov     ax, 4202h
                xor     cx, cx
                xor     dx, dx
                mov     bx, [hr]
                int     21h
                jc      errs
;-
                mov     [f_s], ax
                mov     [b_f_s], dx
;-
                mov     ax, 4200h
                xor     cx, cx
                xor     dx, dx
                mov     bx, [hr]
                int     21h
                jc      errs
;-
                mov     ah, 3fh
                mov     dx, offset buffer
                mov     cx, 1ch
                mov     bx, [hr]
                int     21h
                jc      errs
;-
                call    ip_check
                call    read_code
                call    cry1
                mov     di, offset buffer+0274h
                mov     si, di
                cld
@@c:
                call    find_and_dec
                cmp     [res], 0ffffh
                jne     @@c                                ; Cycle, while not found main code.
;-
                mov     si, di
                mov     al, 0bbh
                mov     cx, 0ffh
@@40:
                repne   scasb
                jcxz    p_errs
;-
                mov     bp, di
                cmp     byte ptr [bp+2], 0eh
                jne     @@40
                cmp     byte ptr [bp+3], 0fch
                jne     @@40
                mov     bx, word ptr [bp]
;-
                mov     cx, 074ah
                mov     di, bp
                add     di, 10h
                mov     si, di
                push    di
;-
                cld
@@41:
                lodsb
                add     al, bh
                xor     al, bl
                rol     bx, 02h
                stosb
                loop    @@41
;-
                pop     di
                mov     al, 0fch
                mov     cx, 0ffffh
                push    di
@@43:
                repne   scasb
                cmp     dword ptr [di], 0ac0010b9h
                jnz     @@43
                mov     ax, [di+6]
                mov     [_1_v], ax
;-
                pop     di
                mov     al, 0d0h
                mov     cx, 0ffffh
@@88:
                repne   scasb
                cmp     dword ptr [di], 0fae24307h
                jne     @@88
;-
                add     di, 4
                mov     si, di
                push    di
                mov     cx, 133h
@@99:
                lodsb
                rol     al, 1
                stosb
                loop    @@99
;-
                pop     di
                push    di
                mov     al, 02eh
                mov     cx, 0ffffh
@@93:
                repne   scasb
                cmp     dword ptr [di], 0b20aeffh
                jne     @@93
;-
                add     di, 4
                mov     [rel_off], di
                mov     si, di
                lodsw
                mov     [ncs], ax
                lodsw
                mov     [nip], ax
                lodsw
                mov     [nsp], ax
                lodsw
                mov     [nss], ax
                add     si, 5
                lodsw
                mov     [rel], ax
;-
                call    linear_size
                xor     eax, eax
                xor     edx, edx
                xor     ecx, ecx
                xor     edi, edi
                xor     eax, eax
                mov     ax, [rel]
                mov     ecx, 4
                mul     ecx
                add     ebp, eax
                xor     edx, edx
;-
                mov     di, [n_f_s]
                sub     ebp, edi
                xchg    eax, ebp
                mov     ebp, 512
                div     ebp
                or      dx, dx
                jz      overf
                inc     ax
overf:
;-
                mov     di, offset pc
                stosw
                mov     di, offset pcl
                xchg    dx, ax
                stosw
;-
                pop     di
                mov     al, 35h
                mov     cx, 0ffffh
@@89:
                repne   scasb
                cmp     dword ptr [di], 01005d88ch
                jne     @@89
;-
                add     di, 7
                mov     si, di
                lodsd
                mov     edx, eax
                add     si, 7
                lodsd
                mov     ebx, eax
                add     si, 4
                lodsd
                mov     ebp, eax
                mov     cx, [rel]
                or      cx, cx
                jz      no_rel
;-
                mov     di, [rel_off]
                add     di, 0fh
                mov     si, di
                mov     [rel_off], di
@@9EF:
                lodsd
                sub     eax, edx
                sub     edx, ebx
                xor     eax, ebp
                stosd
                loop    @@9EF
;-
no_rel:
                call    get_ph
                call    write_head
                xor     dx, dx
                mov     ax, [rel]
                mov     bx, 4
                mul     bx
;-
                push    ax
                xchg    ax, cx
                mov     ah, 40h
                mov     dx, [rel_off]
                mov     bx, [hw]
                int     21h
                jc      errs
;-
                xor     cx, cx
                xor     dx, dx
                xor     bp, bp
@@100:
                mov     ax, 4201h
                mov     bx, [hw]
                int     21h
                test    al, 0000fh
                pushf
                inc     dx
                popf
                jne     @@100
;-
                call    encod_f
;-
                jmp     result
;-
get_ph:
                pusha
                xor     edx, edx
                xor     eax, eax
                xor     ebx, ebx
                mov     ax, [rel]
                mov     ebx, 4
                mul     ebx
;-
                xor     edx, edx
                mov     ebx, 16
                div     ebx
                cmp     dx, 0fh/2
                jb      nin_c
;-
                inc     ax
nin_c:
                add     ax, 2
                mov     [hdrs], ax
                popa
                ret
;-
clear:
                push    di dx bp
                mov     bp, 4
                mov     al, 01eh
                mov     cx, 0ffh
                xor     dx, dx
@@125:
                repne   scasb
                jcxz    @@127
                cmp     dword ptr ds:[di], 0d88ec033h
                jne     @@125
                push    cx
                call    rem_mus
                pop     cx
                add     dx, 19
                dec     bp
                jnz     @@125
@@127:
                add     [hov_otn], dx
                mov     cx, 050h
                pop     bp dx di
                ret
;-
rem_mus:
                push    di
                dec     di
                mov     si, di
                add     si, 19
                mov     bp, di
                sub     bp, offset buffer
                add     bp, 9
                mov     cx, [n_f_s]
                sub     cx, bp
                repne   movsb
                pop     di
                ret
;-
write_head:
                call    create
                mov     ah, 40h
                mov     dx, offset mz_head
                mov     bx, [hw]
                mov     cx, 1ch
                int     21h
                ret
;-
encod_f:
;-
                mov     ax, 4200h
                xor     cx, cx
                mov     dx, 20h
                mov     bx, [hr]
                int     21h
                jc      errs
;-
                mov     cx, [b_f_s]
                jcxz    w_s2
;-
                call    linear_size
                xor     ecx, ecx
                xor     eax, eax
                mov     cx, [n_f_s]
                sub     ebp, ecx
                sub     ebp, 1eh
;-
                xchg    eax, ebp
                mov     ebp, 65535
                div     ebp
                mov     [b_f_s], ax
                mov     [f_s], dx
                xchg    ax, cx
;-
@@3:
                push    cx
                call    bwrt
                pop     cx
                loop    @@3
;-
w_s:
                mov     ah, 3fh
                mov     dx, offset buffer
                mov     cx, [f_s]
                mov     bx, [hr]
                int     21h
                jc      errs
;-
                mov     di, offset buffer
                mov     si, di
;-
                xchg    ax, cx
                mov     bp, cx
;-
                xor     bx, bx
                mov     bx, [_2_v]
@@427:
                lodsb
                add     bx, [_1_v]
                ror     bx, 03h
                sub     al, bl
                stosb
                loop    @@427
;-
                mov     ah, 40h
                mov     dx, offset buffer
                mov     cx, bp
                mov     bx, [hw]
                int     21h
                jc      errs
                ret
;-
w_s2:
                mov     ah, 3fh
                mov     cx, [f_s]
                sub     cx, [n_f_s]
                sub     cx, 20h
                mov     dx, offset buffer
                mov     bx, [hr]
                int     21h
                jc      errs
;-
                mov     di, offset buffer
                mov     si, di
;-
                xchg    ax, cx
                mov     bp, cx
;-
                mov     bx, [_2_v]
@@428:
                lodsb
                add     bx, [_1_v]
                ror     bx, 03h
                sub     al, bl
                stosb
                loop    @@428
;-
                mov     ah, 40h
                mov     dx, offset buffer
                mov     cx, bp
                mov     bx, [hw]
                int     21h
                jc      errs
                ret
;-

;-
bwrt:
                mov     cx, 3
@@1:
                push    cx
                mov     ah, 3fh
                mov     dx, offset buffer
                mov     cx, 5555h
                mov     bx, [hr]
                int     21h
                jc      errs
;-
                call    cry2
;-
                mov     ah, 40h
                mov     dx, offset buffer
                mov     cx, 5555h
                mov     bx, [hw]
                int     21h
                jc      errs
;-
                pop     cx
                loop    @@1
                ret
;-
cry2:
                mov     di, offset buffer
                mov     si, di
                mov     cx, 5555h
                xor     bx, bx
                cld
                mov     bx, [_2_v]
@@424:
                lodsb
                add     bx, [_1_v]
                ror     bx, 03h
                sub     al, bl
                stosb
                loop    @@424
                mov     [_2_v], bx
                ret
; ------------ This part of code was optimized by MERLiN // DTG
find_and_dec :
                call    check
                cmp     ah,15
                jbe     _1
                retn
_1:
                movzx   si,ah
                push    ax
                mov     al,[si+offset table1]
                shl     si,1
                mov     dx,[si+offset table2]
                mov     si, di
                mov     cx, 0ffh
                repne   scasb
                jcxz    p_errs
                mov     bx, word ptr [di]
                add     bx, offset buffer
                sub     bx, [hov_otn]
                pop     ax
                push    bx
                mov     cx, 769h
@@17:
                call    dx
                inc     bx
                loop    @@17
                pop     di
                ret
table1:
                db      0beh,0bbh,0bfh,0beh,0beh,0bfh,0bfh,0bbh,0bbh,0beh,0bbh
                db      0bbh,0bfh,0bfh,0beh,0beh
table2:
                dw      _xor,_xor,_add,_add,_sub,_sub,_xor,_add,_sub,_xor
                dw      _neg,_not,_neg,_not,_neg,_not
_xor:
                xor     [bx],al
                retn
_add:
                add     [bx],al
                retn
_sub:
                sub     [bx],al
                retn
_neg:
                neg     byte ptr [bx]
                retn
_not:
                not     byte ptr [bx]
                retn
; in = di offset to find code
; out = ax type of crypting , if ax = 0ffffh , then find main proc.
_tbl1      db      34h,37h,05,04,2ch,2dh,35h,07,2fh,34h
_tbl2      db      1fh,17h,1dh,15h,1ch,14h
check:
                call    clear
                mov     dx,10
                lea     si,_tbl1
a01:
                push    di
                mov     cx, 50h
a07:
                mov     al, 02eh
                repne   scasb
                jcxz    a02
;-
                mov     al,80h
                mov     ah,[si]
                cmp     word ptr [di],ax
                jz      _found
                jmp     a07
a02:
                pop     di
                inc     si
                dec     dx
                jnz     a01
                jmp     a09
_found:
                sub     si,offset _tbl1
                xchg    ax,si
                xchg    al,ah
                mov     al,[di+2]
                pop     di
                ret
a09:
                mov     dl,6
a06:
                push    di
                mov     cx, 50h
a05:
                mov     al, 02eh
                repne   scasb
                jcxz    a03
;-
                mov     ah,[si]
                mov     al,0f6h
                cmp     word ptr [di],ax
                jz      _found
                jmp     a05
a03:
                pop     di
                dec     dx
                inc     si
                jnz     a06

                mov     cx, 50h
a08:
                mov     al, 0beh
                repne   scasb
                jcxz    p_errs
;-
                cmp     word ptr [di],03e2h
                jnz     a08

                mov     ax, 0ffffh
                mov     [res],ax                      ; End of polymorph code.
                retn
;---------------------------------------------------------------------
cry1:
                std
                mov     di, offset buffer+0500h
                mov     si, di
                xor     dx, dx
                mov     bx, offset buffer+60h
                mov     ax, dx
@@116:
                lodsb
                push    bx
                mov     cx, 00D4h
@@11C:
                add     dx, word ptr cs:[bx]
                inc     bx
                loop    @@11C
                pop     bx
                xor     ax, dx
                stosb
                cmp     di, offset buffer+0133h
                jnz     @@116
                ret
;
read_code:
                mov     ebx, [loff]
                cmp     [loff], 65535
                jc      not_del
;-
                xor     edx, edx
                mov     eax, ebx
                mov     ebx, 65535
                div     ebx
                and     edx, 1111111111111111111111110000b
;-
                xchg    eax, ecx
                jmp     short seek_
;-
not_del:
                xchg    bx, dx
                xor     cx, cx
;-
seek_:
                mov     ax, 4200h
                mov     bx, [hr]
                int     21h
                jc      errs
;-
                call    linear_size
;-
                mov     ah, 3fh
                mov     dx, offset buffer
                mov     cx, 0ffffh
                mov     bx, [hr]
                int     21h
                jc      errs
                mov     [n_f_s], ax
                mov     si, offset buffer
                lodsd
                cmp     eax, 'SSEM'
                jne     not_
;-
                ret
linear_size:
;- Get linear file size
; in:
; [b_f_s] = file sz in 65535 bytes
; [f_s]   = file sz in bytes
; out:
; ebp     = linear size
                xor     edx, edx
                xor     eax, eax
                mov     dx, [b_f_s]
                mov     ax, [f_s]
;-
                push    ax
                movzx   ebx, dx
                mov     ax, 65535
                mul     ebx
;-
                xchg    ebx, eax
                pop     ax
                movzx   eax, ax
                add     ebx, eax
                xchg    ebx, ebp
;-
                ret
;-
ip_check:
                pusha
                xor     eax, eax
                mov     si, offset buffer+14h
                lodsw
                mov     [ip], eax
                lodsw
                mov     word ptr [cs_], ax
;-
                xor     ebx, ebx
                mov     ebx, eax
                mov     ax, 10h
                mul     ebx
                mov     ebx, eax
;-
                xor     eax, eax
                mov     ax, 16
                mov     cx, word ptr ds:[buffer+8]
                mul     cx
                add     ebx, eax
;-
                mov     [loff], ebx
                popa
                ret
;-
create:
                mov     ah, 3ch
                mov     dx, offset fn
                xor     cx, cx
                int     21h
                jc      errs
;-
                mov     [hw], ax
                ret
;-
write:
                mov     ah, 09h
                int     21h
                ret
;-
errs:
                mov     dx, offset errs_
                call    write
                jmp     ext
;-
not_:
                mov     dx, offset nt_
                call    write
                jmp     ext
;-
usage_:
                mov     dx, offset usage
                call    write
;-
ext:
                mov     ah, 4ch
                int     21h
;-
p_errs:
                mov     dx, offset p_err
                call    write
                jmp     ext
;-
result:
                mov     dx, offset cm
                call    write
                jmp     ext
;-
msg             db      , 13, 10, 'Mess v1.20 *unpacker* (c) DarkGrey // Delirium Tremens', 13, 10, 13, 10, '$'
usage           db      'Usage: unmess.com packed.exe', 13, 10, '$'
nt_             db      , 13, 10, 'This file is not crypted with Mess v1.20', 13, 10, '$'
pf              db      'Unpacking file: $'
cm              db      , 13, 10, 'Complete! Result in out.exe ...', 13, 10, '$'
errs_           db      'I/O Error!', 13, 10, '$'
p_err           db      , 13, 10, 'Polymorph decoding error!', 13, 10, '$'
fn              db      'out.exe', 0
mz_head         db      'MZ'
pcl             dw      0
pc              dw      0
rel             dw      0
hdrs            dw      0
minm            dw      0
maxm            dw      0ffffh
nss             dw      0
nsp             dw      0
chsm            dw      0
ncs             dw      0
nip             dw      0
reloctdl        dw      1ch
ovln            dw      0
;-
hov_otn         dw      0
_1_v            dw      0
_2_v            dw      0
loff            dd      0
f_s             dw      0
b_f_s           dw      0
cs_             dw      0
ip              dd      0
n_f_s           dw      0
hr              dw      0
hw              dw      0
sh              db      0
res             dw      0
rel_off         dw      0
buffer          db      ?
                end