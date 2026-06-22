[org 0x0100]
jmp start
 
plen:   dw 10           ; Paddle length
prow:   dw 21           ; Paddle Row
pcol:   dw 35           ; Paddle Column
 
brow:   dw 12           ; Ball row (16-bit)
bcol:   dw 40           ; Ball col (16-bit)
bdx:    dw 0xFFFF       ; FIX: 16-bit signed direction: -1 = UP, +1 = DOWN
bdy:    dw 0x0001       ; FIX: 16-bit signed direction: -1 = LEFT, +1 = RIGHT
 
ball_timer_limit: dw 3000  ; Ball speed (higher = slower)
ball_timer:       dw 0
 
score:  dw 0
lives:  dw 3
 
; Timer variables — use BIOS tick counter at 0040:006C
; BIOS timer ticks at ~18.2 Hz
game_seconds: dw 0
game_minutes: dw 0
last_tick:    dw 0      ; FIX: store last BIOS tick value
tick_accum:   dw 0      ; accumulate ticks
 
; Strings
s:   db 'Score:'
l:   db 'Lives:'
t:   db 'Time: '
slen: dw 6
tlen: dw 6
game_over_txt:    db 'GAME OVER'
press_key_msg:    db 'Press ENTER to Start or ESC to Exit'
winner_exit_msg:  db 'Press any key to exit...'
 
; Credits string
credits_txt: db 'Presented By: HAMNA MARIYAM AND MARYAM FATIMA'
credits_len: dw 46
 
row_char  db 0
row_color db 0
 
; Brick Arrays (15 bricks per row)
row1: db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
row2: db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
row3: db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
row4: db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
 
start:
    ; FIX: Read initial BIOS timer tick so time starts at 0
    push es
    mov ax, 0x0040
    mov es, ax
    mov ax, [es:0x006C]
    mov [last_tick], ax
    pop es

    call StartPage
    call clrscr
    call draw_border
    call dball
    call dbrick
    jmp gameloop
 
;;;;;;;;;;;;;;;;;;;;;;;;; START PAGE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
StartPage:
    pusha
 
    mov al, 3h
    int 10h
 
    mov ah, 06h
    xor al, al
    xor cx, cx
    mov dx, 184Fh
    mov bh, 00h
    int 10h
 
    mov ax, 0B800h
    mov es, ax
 
    ; Title: "ATARI BREAKOUT ARCADE GAME"
    ; Row 3, col 27 => offset = (3*80+27)*2 = 534
    mov di, 534
    mov ah, 0x0E
    mov al, 'A'
    mov [es:di], ax
    add di,2
    mov al, 'T'
    mov [es:di], ax
    add di,2
    mov al, 'A'
    mov [es:di], ax
    add di,2
    mov al, 'R'
    mov [es:di], ax
    add di,2
    mov al, 'I'
    mov [es:di], ax
    add di,2
    mov al, ' '
    mov [es:di], ax
    add di,2
    mov al, 'B'
    mov [es:di], ax
    add di,2
    mov al, 'R'
    mov [es:di], ax
    add di,2
    mov al, 'E'
    mov [es:di], ax
    add di,2
    mov al, 'A'
    mov [es:di], ax
    add di,2
    mov al, 'K'
    mov [es:di], ax
    add di,2
    mov al, 'O'
    mov [es:di], ax
    add di,2
    mov al, 'U'
    mov [es:di], ax
    add di,2
    mov al, 'T'
    mov [es:di], ax
    add di,2
    mov al, ' '
    mov [es:di], ax
    add di,2
    mov al, 'A'
    mov [es:di], ax
    add di,2
    mov al, 'R'
    mov [es:di], ax
    add di,2
    mov al, 'C'
    mov [es:di], ax
    add di,2
    mov al, 'A'
    mov [es:di], ax
    add di,2
    mov al, 'D'
    mov [es:di], ax
    add di,2
    mov al, 'E'
    mov [es:di], ax
    add di,2
    mov al, ' '
    mov [es:di], ax
    add di,2
    mov al, 'G'
    mov [es:di], ax
    add di,2
    mov al, 'A'
    mov [es:di], ax
    add di,2
    mov al, 'M'
    mov [es:di], ax
    add di,2
    mov al, 'E'
    mov [es:di], ax
 
    ; Separator Row 4, col 27
    mov di, 694
    mov ah, 0x0B
    mov cx, 26
sp_sep:
    mov al, '='
    mov [es:di], ax
    add di, 2
    loop sp_sep
 
    ; "HOW TO PLAY:" Row 6, col 32
    mov di, 1024
    mov ah, 0x0A
    mov al, 'H'
    mov [es:di], ax
    add di,2
    mov al, 'O'
    mov [es:di], ax
    add di,2
    mov al, 'W'
    mov [es:di], ax
    add di,2
    mov al, ' '
    mov [es:di], ax
    add di,2
    mov al, 'T'
    mov [es:di], ax
    add di,2
    mov al, 'O'
    mov [es:di], ax
    add di,2
    mov al, ' '
    mov [es:di], ax
    add di,2
    mov al, 'P'
    mov [es:di], ax
    add di,2
    mov al, 'L'
    mov [es:di], ax
    add di,2
    mov al, 'A'
    mov [es:di], ax
    add di,2
    mov al, 'Y'
    mov [es:di], ax
    add di,2
    mov al, ':'
    mov [es:di], ax
 
    ; LEFT ARROW instruction Row 8, col 25
    mov di, 1330
    mov ah, 0x07
    mov al, 'L'
    mov [es:di], ax
    add di,2
    mov al, 'E'
    mov [es:di], ax
    add di,2
    mov al, 'F'
    mov [es:di], ax
    add di,2
    mov al, 'T'
    mov [es:di], ax
    add di,2
    mov al, ' '
    mov [es:di], ax
    add di,2
    mov al, 'A'
    mov [es:di], ax
    add di,2
    mov al, 'R'
    mov [es:di], ax
    add di,2
    mov al, 'R'
    mov [es:di], ax
    add di,2
    mov al, 'O'
    mov [es:di], ax
    add di,2
    mov al, 'W'
    mov [es:di], ax
    add di,2
    mov al, ' '
    mov [es:di], ax
    add di,2
    mov al, '-'
    mov [es:di], ax
    add di,2
    mov al, ' '
    mov [es:di], ax
    add di,2
    mov al, 'M'
    mov [es:di], ax
    add di,2
    mov al, 'o'
    mov [es:di], ax
    add di,2
    mov al, 'v'
    mov [es:di], ax
    add di,2
    mov al, 'e'
    mov [es:di], ax
    add di,2
    mov al, ' '
    mov [es:di], ax
    add di,2
    mov al, 'P'
    mov [es:di], ax
    add di,2
    mov al, 'a'
    mov [es:di], ax
    add di,2
    mov al, 'd'
    mov [es:di], ax
    add di,2
    mov al, 'd'
    mov [es:di], ax
    add di,2
    mov al, 'l'
    mov [es:di], ax
    add di,2
    mov al, 'e'
    mov [es:di], ax
    add di,2
    mov al, ' '
    mov [es:di], ax
    add di,2
    mov al, 'L'
    mov [es:di], ax
    add di,2
    mov al, 'e'
    mov [es:di], ax
    add di,2
    mov al, 'f'
    mov [es:di], ax
    add di,2
    mov al, 't'
    mov [es:di], ax
 
    ; RIGHT ARROW instruction Row 9, col 25
    mov di, 1490
    mov ah, 0x07
    mov al, 'R'
    mov [es:di], ax
    add di,2
    mov al, 'I'
    mov [es:di], ax
    add di,2
    mov al, 'G'
    mov [es:di], ax
    add di,2
    mov al, 'H'
    mov [es:di], ax
    add di,2
    mov al, 'T'
    mov [es:di], ax
    add di,2
    mov al, ' '
    mov [es:di], ax
    add di,2
    mov al, 'A'
    mov [es:di], ax
    add di,2
    mov al, 'R'
    mov [es:di], ax
    add di,2
    mov al, 'R'
    mov [es:di], ax
    add di,2
    mov al, 'O'
    mov [es:di], ax
    add di,2
    mov al, 'W'
    mov [es:di], ax
    add di,2
    mov al, ' '
    mov [es:di], ax
    add di,2
    mov al, '-'
    mov [es:di], ax
    add di,2
    mov al, ' '
    mov [es:di], ax
    add di,2
    mov al, 'M'
    mov [es:di], ax
    add di,2
    mov al, 'o'
    mov [es:di], ax
    add di,2
    mov al, 'v'
    mov [es:di], ax
    add di,2
    mov al, 'e'
    mov [es:di], ax
    add di,2
    mov al, ' '
    mov [es:di], ax
    add di,2
    mov al, 'P'
    mov [es:di], ax
    add di,2
    mov al, 'a'
    mov [es:di], ax
    add di,2
    mov al, 'd'
    mov [es:di], ax
    add di,2
    mov al, 'd'
    mov [es:di], ax
    add di,2
    mov al, 'l'
    mov [es:di], ax
    add di,2
    mov al, 'e'
    mov [es:di], ax
    add di,2
    mov al, ' '
    mov [es:di], ax
    add di,2
    mov al, 'R'
    mov [es:di], ax
    add di,2
    mov al, 'i'
    mov [es:di], ax
    add di,2
    mov al, 'g'
    mov [es:di], ax
    add di,2
    mov al, 'h'
    mov [es:di], ax
    add di,2
    mov al, 't'
    mov [es:di], ax
 
    ; ESC instruction Row 10, col 25
    mov di, 1650
    mov ah, 0x07
    mov al, 'E'
    mov [es:di], ax
    add di,2
    mov al, 'S'
    mov [es:di], ax
    add di,2
    mov al, 'C'
    mov [es:di], ax
    add di,2
    mov al, ' '
    mov [es:di], ax
    add di,2
    mov al, ' '
    mov [es:di], ax
    add di,2
    mov al, ' '
    mov [es:di], ax
    add di,2
    mov al, ' '
    mov [es:di], ax
    add di,2
    mov al, ' '
    mov [es:di], ax
    add di,2
    mov al, ' '
    mov [es:di], ax
    add di,2
    mov al, ' '
    mov [es:di], ax
    add di,2
    mov al, ' '
    mov [es:di], ax
    add di,2
    mov al, '-'
    mov [es:di], ax
    add di,2
    mov al, ' '
    mov [es:di], ax
    add di,2
    mov al, 'E'
    mov [es:di], ax
    add di,2
    mov al, 'x'
    mov [es:di], ax
    add di,2
    mov al, 'i'
    mov [es:di], ax
    add di,2
    mov al, 't'
    mov [es:di], ax
    add di,2
    mov al, ' '
    mov [es:di], ax
    add di,2
    mov al, 'G'
    mov [es:di], ax
    add di,2
    mov al, 'a'
    mov [es:di], ax
    add di,2
    mov al, 'm'
    mov [es:di], ax
    add di,2
    mov al, 'e'
    mov [es:di], ax
 
    ; "SCORING:" Row 12, col 32
    mov di, 1984
    mov ah, 0x0A
    mov al, 'S'
    mov [es:di], ax
    add di,2
    mov al, 'C'
    mov [es:di], ax
    add di,2
    mov al, 'O'
    mov [es:di], ax
    add di,2
    mov al, 'R'
    mov [es:di], ax
    add di,2
    mov al, 'I'
    mov [es:di], ax
    add di,2
    mov al, 'N'
    mov [es:di], ax
    add di,2
    mov al, 'G'
    mov [es:di], ax
    add di,2
    mov al, ':'
    mov [es:di], ax
 
    ; "Each brick broken = 10 points" Row 13, col 27
    mov di, 2134
    mov ah, 0x07
    mov al, 'E'
    mov [es:di], ax
    add di,2
    mov al, 'a'
    mov [es:di], ax
    add di,2
    mov al, 'c'
    mov [es:di], ax
    add di,2
    mov al, 'h'
    mov [es:di], ax
    add di,2
    mov al, ' '
    mov [es:di], ax
    add di,2
    mov al, 'b'
    mov [es:di], ax
    add di,2
    mov al, 'r'
    mov [es:di], ax
    add di,2
    mov al, 'i'
    mov [es:di], ax
    add di,2
    mov al, 'c'
    mov [es:di], ax
    add di,2
    mov al, 'k'
    mov [es:di], ax
    add di,2
    mov al, ' '
    mov [es:di], ax
    add di,2
    mov al, 'b'
    mov [es:di], ax
    add di,2
    mov al, 'r'
    mov [es:di], ax
    add di,2
    mov al, 'o'
    mov [es:di], ax
    add di,2
    mov al, 'k'
    mov [es:di], ax
    add di,2
    mov al, 'e'
    mov [es:di], ax
    add di,2
    mov al, 'n'
    mov [es:di], ax
    add di,2
    mov al, ' '
    mov [es:di], ax
    add di,2
    mov al, '='
    mov [es:di], ax
    add di,2
    mov al, ' '
    mov [es:di], ax
    add di,2
    mov al, '1'
    mov [es:di], ax
    add di,2
    mov al, '0'
    mov [es:di], ax
    add di,2
    mov al, ' '
    mov [es:di], ax
    add di,2
    mov al, 'p'
    mov [es:di], ax
    add di,2
    mov al, 'o'
    mov [es:di], ax
    add di,2
    mov al, 'i'
    mov [es:di], ax
    add di,2
    mov al, 'n'
    mov [es:di], ax
    add di,2
    mov al, 't'
    mov [es:di], ax
    add di,2
    mov al, 's'
    mov [es:di], ax
 
    ; "You have 3 Lives" Row 14, col 30
    mov di, 2300
    mov ah, 0x07
    mov al, 'Y'
    mov [es:di], ax
    add di,2
    mov al, 'o'
    mov [es:di], ax
    add di,2
    mov al, 'u'
    mov [es:di], ax
    add di,2
    mov al, ' '
    mov [es:di], ax
    add di,2
    mov al, 'h'
    mov [es:di], ax
    add di,2
    mov al, 'a'
    mov [es:di], ax
    add di,2
    mov al, 'v'
    mov [es:di], ax
    add di,2
    mov al, 'e'
    mov [es:di], ax
    add di,2
    mov al, ' '
    mov [es:di], ax
    add di,2
    mov al, '3'
    mov [es:di], ax
    add di,2
    mov al, ' '
    mov [es:di], ax
    add di,2
    mov al, 'L'
    mov [es:di], ax
    add di,2
    mov al, 'i'
    mov [es:di], ax
    add di,2
    mov al, 'v'
    mov [es:di], ax
    add di,2
    mov al, 'e'
    mov [es:di], ax
    add di,2
    mov al, 's'
    mov [es:di], ax
 
    ; "Break all bricks to WIN!" Row 15, col 27
    mov di, 2454
    mov ah, 0x07
    mov al, 'B'
    mov [es:di], ax
    add di,2
    mov al, 'r'
    mov [es:di], ax
    add di,2
    mov al, 'e'
    mov [es:di], ax
    add di,2
    mov al, 'a'
    mov [es:di], ax
    add di,2
    mov al, 'k'
    mov [es:di], ax
    add di,2
    mov al, ' '
    mov [es:di], ax
    add di,2
    mov al, 'a'
    mov [es:di], ax
    add di,2
    mov al, 'l'
    mov [es:di], ax
    add di,2
    mov al, 'l'
    mov [es:di], ax
    add di,2
    mov al, ' '
    mov [es:di], ax
    add di,2
    mov al, 'b'
    mov [es:di], ax
    add di,2
    mov al, 'r'
    mov [es:di], ax
    add di,2
    mov al, 'i'
    mov [es:di], ax
    add di,2
    mov al, 'c'
    mov [es:di], ax
    add di,2
    mov al, 'k'
    mov [es:di], ax
    add di,2
    mov al, 's'
    mov [es:di], ax
    add di,2
    mov al, ' '
    mov [es:di], ax
    add di,2
    mov al, 't'
    mov [es:di], ax
    add di,2
    mov al, 'o'
    mov [es:di], ax
    add di,2
    mov al, ' '
    mov [es:di], ax
    add di,2
    mov al, 'W'
    mov [es:di], ax
    add di,2
    mov al, 'I'
    mov [es:di], ax
    add di,2
    mov al, 'N'
    mov [es:di], ax
    add di,2
    mov al, '!'
    mov [es:di], ax
 
    ; "Press ENTER to Start or ESC to Exit" Row 20, col 22
    mov di, 3244
    mov si, press_key_msg
    mov cx, 35
    mov ah, 0x0E
sp_print_msg:
    lodsb
    stosw
    loop sp_print_msg
 
sp_wait_key:
    mov ah, 0
    int 0x16
    cmp al, 0x1B
    jne sp_check_enter
    mov ax, 0x4c00
    int 0x21
sp_check_enter:
    cmp al, 0x0D
    jne sp_wait_key
 
    popa
    ret
 
; -------------------------------------------------------
; Draw border: rows 1..22, cols 0..79
; -------------------------------------------------------
draw_border:
    push ax
    push bx
    push cx
    push di
    push es

    mov ax, 0xb800
    mov es, ax

    ; Top border row 1
    mov di, 160         ; (1*80+0)*2
    mov ah, 0x0B
    mov al, 0xC9
    mov [es:di], ax
    add di, 2
    mov cx, 78
tb_draw_top:
    mov al, 0xCD
    mov [es:di], ax
    add di, 2
    loop tb_draw_top
    mov al, 0xBB
    mov [es:di], ax

    ; Bottom border row 22
    mov di, 3520        ; (22*80+0)*2
    mov al, 0xC8
    mov [es:di], ax
    add di, 2
    mov cx, 78
tb_draw_bot:
    mov al, 0xCD
    mov [es:di], ax
    add di, 2
    loop tb_draw_bot
    mov al, 0xBC
    mov [es:di], ax

    ; Left border rows 2..21
    mov cx, 20
    mov di, 320         ; (2*80+0)*2
tb_draw_left:
    mov al, 0xBA
    mov [es:di], ax
    add di, 160
    loop tb_draw_left

    ; Right border rows 2..21
    mov cx, 20
    mov di, 478         ; (2*80+79)*2
tb_draw_right:
    mov al, 0xBA
    mov [es:di], ax
    add di, 160
    loop tb_draw_right

    pop es
    pop di
    pop cx
    pop bx
    pop ax
    ret

;;;;;;;;;;;;;;;;;;;;;;;;; MAIN GAME LOOP ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gameloop:
    call scoring        
    call dpaddle
 
    ; Ball timer
    mov ax, [ball_timer]
    inc ax
    mov [ball_timer], ax
    cmp ax, [ball_timer_limit]
    jl gl_skip_ball
    mov word [ball_timer], 0
    call moveBall
gl_skip_ball:

    call update_timer
 
    mov ah, 0x01
    int 0x16        
    jz gameloop
 
    mov ah, 0x00
    int 0x16        
 
    cmp ah, 0x01        ; ESC
    jne gl_check_left
    jmp near game_over
gl_check_left:
    cmp ah, 0x4B        ; Left Arrow
    jne gl_check_right
    jmp near left
gl_check_right:
    cmp ah, 0x4D        ; Right Arrow
    jne gameloop
    jmp near right
 
; -------------------------------------------------------
; FIX: update_timer uses BIOS tick counter at 0040:006C
; BIOS ticks at 18.2 Hz. We count real ticks so 1 second = ~18 ticks.
; -------------------------------------------------------
update_timer:
    push ax
    push bx
    push es

    ; Read current BIOS tick count
    mov ax, 0x0040
    mov es, ax
    mov ax, [es:0x006C]     ; low word of tick counter

    ; Calculate ticks elapsed since last check
    mov bx, [last_tick]
    sub ax, bx              ; ax = ticks elapsed (handles wraparound)
    jz ut_no_change         ; no new ticks

    ; Update last_tick
    mov bx, [es:0x006C]
    mov [last_tick], bx

    ; Add elapsed ticks to accumulator
    add [tick_accum], ax

    ; Check if >= 18 ticks (approx 1 second)
ut_check_sec:
    cmp word [tick_accum], 18
    jl ut_no_change

    sub word [tick_accum], 18

    ; Increment seconds
    mov ax, [game_seconds]
    inc ax
    cmp ax, 60
    jl ut_store_sec
    xor ax, ax
    mov ax, [game_minutes]
    inc ax
    mov [game_minutes], ax
    xor ax, ax
ut_store_sec:
    mov [game_seconds], ax
    jmp ut_check_sec        ; handle multiple seconds at once

ut_no_change:
    pop es
    pop bx
    pop ax
    ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; PADDLE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; FIX: Removed wrong shl cx,1. plen is the count of chars — use directly.
dpaddle:
    mov ax, 0xb800
    mov es, ax

    ; --- Top row of paddle (prow-1 = row 20) ---
    mov ax, [prow]
    dec ax
    mov bx, 80
    mul bx          
    add ax, [pcol]        
    shl ax, 1        
    mov di, ax  
    mov ah, 0x08        ; Dark grey
    mov cx, [plen]      ; FIX: use plen directly, no shl
dp_top:
    mov al, 0xDF        ; Upper half block
    mov [es:di], ax
    add di, 2
    loop dp_top

    ; --- Bottom row of paddle (prow = row 21) ---
    mov ax, [prow]
    mov bx, 80
    mul bx          
    add ax, [pcol]        
    shl ax, 1        
    mov di, ax  
    mov ah, 0x07        ; Light grey
    mov cx, [plen]      ; FIX: use plen directly, no shl
dp_bot:
    mov al, 0xDC        ; Lower half block
    mov [es:di], ax
    add di, 2
    loop dp_bot
    ret
 
left:
    mov ax, [pcol]
    cmp ax, 2           ; left border at col 1
    jle gameloop
    call eraseP
    dec word [pcol]
    call dpaddle
    jmp gameloop
 
right:
    mov ax, [pcol]
    add ax, [plen]
    cmp ax, 78          ; right border at col 79
    jge gameloop
    call eraseP
    inc word [pcol]
    call dpaddle      
    jmp gameloop
 
eraseP:
    push dx
    mov ax, 0xb800
    mov es, ax

    ; Erase top row (prow-1)
    mov ax, [prow]
    dec ax
    mov bx, 80
    mul bx          
    add ax, [pcol]        
    shl ax, 1        
    mov di, ax  
    mov ax, 0x0720
    mov cx, [plen]      ; FIX: use plen directly
ep_top:
    mov [es:di], ax
    add di, 2
    loop ep_top

    ; Erase bottom row (prow)
    mov ax, [prow]
    mov bx, 80
    mul bx          
    add ax, [pcol]        
    shl ax, 1        
    mov di, ax  
    mov ax, 0x0720
    mov cx, [plen]      ; FIX: use plen directly
ep_bot:
    mov [es:di], ax
    add di, 2
    loop ep_bot

    pop dx
    ret
 
;;;;;;;;;;;;;;;;;;;;;;;;; HUD & SCORING ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
clrscr:
    mov ax, 0xb800
    mov es, ax
    xor di, di
    mov ax, 0x0720
    mov cx, 2000
    cld
    rep stosw
    ret
 
scoring:
    push es
    push di
    push si
    push ax
    push bx
    push cx
    push dx
 
    mov ax, 0xb800
    mov es, ax
   
    ; "Score:" HUD row 24 col 3
    mov di, 3846
    mov si, s
    mov cx, [slen]
    mov ah, 0x0B
    cld
sc_score_lbl:
    lodsb
    stosw
    loop sc_score_lbl
    add di, 2
    mov ax, [score]
    call print_number  
 
    ; "Lives:" HUD
    mov di, 3906
    mov si, l
    mov cx, [slen]
    mov ah, 0x0B
    cld
sc_lives_lbl:
    lodsb
    stosw
    loop sc_lives_lbl
    add di, 2
    mov ax, [lives]
    add al, 30h
    mov ah, 0x0B
    mov [es:di], ax
 
    ; FIX: "Time: MM:SS" properly formatted
    ; HUD col ~55 => offset 3840 + 110 = 3950
    mov di, 3950
    mov si, t
    mov cx, [tlen]
    mov ah, 0x0B
    cld
sc_time_lbl:
    lodsb
    stosw
    loop sc_time_lbl

    ; --- Minutes ---
    mov ax, [game_minutes]
    xor dx, dx
    mov bx, 10
    div bx              ; AL = tens, DX = ones
    ; tens digit
    push dx
    add al, '0'
    mov ah, 0x0B
    mov [es:di], ax
    add di, 2
    ; ones digit
    pop dx
    add dl, '0'
    mov dh, 0x0B
    mov [es:di], dx
    add di, 2

    ; Colon
    mov al, ':'
    mov ah, 0x0B
    mov [es:di], ax
    add di, 2

    ; --- Seconds ---
    mov ax, [game_seconds]
    xor dx, dx
    mov bx, 10
    div bx              ; AL = tens, DX = ones
    ; tens digit
    push dx
    add al, '0'
    mov ah, 0x0B
    mov [es:di], ax
    add di, 2
    ; ones digit
    pop dx
    add dl, '0'
    mov dh, 0x0B
    mov [es:di], dx

    pop dx
    pop cx
    pop bx
    pop ax
    pop si
    pop di
    pop es
    ret
 
print_number:
    push ax
    push bx
    push cx
    push dx
    mov bx, 10
    mov cx, 0
pn_divide:
    xor dx, dx
    div bx
    push dx
    inc cx
    cmp ax, 0
    jnz pn_divide
pn_print:
    pop dx
    add dl, '0'
    mov dh, 0x0B
    mov [es:di], dx
    add di, 2
    loop pn_print
    pop dx
    pop cx
    pop bx
    pop ax
    ret
 
dball:
    mov ax, 0xb800
    mov es, ax
    mov ax, [brow]
    mov bx, 80
    mul bx
    add ax, [bcol]
    shl ax, 1
    mov di, ax
    mov dh, 0x0F
    mov dl, 'O'
    mov [es:di], dx
    ret
 
eraseball:
    mov ax, 0xb800
    mov es, ax
    mov ax, [brow]
    mov bx, 80
    mul bx
    add ax, [bcol]
    shl ax, 1
    mov di, ax
    mov dx, 0x0720
    mov [es:di], dx
    ret

; -------------------------------------------------------
; FIX: flip_bdx / flip_bdy now operate on 16-bit words
; -1 (0xFFFF) <-> +1 (0x0001)  via negation
; -------------------------------------------------------
flip_bdx:
    push ax
    mov ax, [bdx]
    neg ax              ; +1 becomes -1 (0xFFFF), -1 becomes +1
    mov [bdx], ax
    pop ax
    ret
 
flip_bdy:
    push ax
    mov ax, [bdy]
    neg ax
    mov [bdy], ax
    pop ax
    ret
 
; -------------------------------------------------------
; FIX: moveBall uses 16-bit signed arithmetic throughout
; brow/bcol are words; bdx/bdy are signed words (+1/-1)
; -------------------------------------------------------
moveBall:
    call eraseball

    ; Move ball: add signed 16-bit direction to position
    mov ax, [bdx]
    add [brow], ax
    mov ax, [bdy]
    add [bcol], ax

    ; --- Left wall (col 2) ---
    cmp word [bcol], 2
    jg mb_check_right
    mov word [bcol], 2
    call flip_bdy
    jmp near mb_check_bricks

mb_check_right:
    ; --- Right wall (col 77) ---
    cmp word [bcol], 77
    jl mb_check_top
    mov word [bcol], 77
    call flip_bdy
    jmp near mb_check_bricks

mb_check_top:
    ; --- Top wall (row 2) ---
    cmp word [brow], 2
    jg mb_check_paddle_zone
    mov word [brow], 2
    call flip_bdx
    jmp near mb_check_bricks

mb_check_paddle_zone:
    ; --- Paddle zone: row 20 (top stripe) or row 21 (bottom) ---
    cmp word [brow], 20
    je mb_check_paddle_hit
    cmp word [brow], 21
    je mb_check_paddle_hit
    jmp near mb_check_bottom

mb_check_paddle_hit:
    ; Check if ball column overlaps with paddle
    mov ax, [bcol]
    cmp ax, [pcol]
    jl mb_no_paddle_hit
    mov bx, [pcol]
    add bx, [plen]
    dec bx
    cmp ax, bx
    jg mb_no_paddle_hit
    ; Hit: ball must be moving DOWN to bounce
    cmp word [bdx], 1
    jne mb_no_paddle_hit
    ; Bounce upward
    mov word [bdx], 0xFFFF  ; -1 = UP
    jmp near mb_check_bricks

mb_no_paddle_hit:
    jmp near mb_check_bottom

mb_check_bottom:
    ; Ball below row 21 = lost life
    cmp word [brow], 22
    jl mb_check_bricks
    call eraseball
    mov ax, [lives]
    dec ax
    mov [lives], ax
    cmp ax, 0
    jne mb_respawn
    jmp near game_over

mb_respawn:
    mov word [brow], 12    
    mov word [bcol], 40    
    mov word [bdx], 0xFFFF ; -1 = UP
    mov word [bdy], 0x0001 ; +1 = RIGHT
    call draw_border        ; FIX: redraw boundary so no gap appears after life loss
    call dball              
    call scoring            
    ; Short pause
    mov cx, 0xFFFF
mb_pause:
    dec cx
    jnz mb_pause
    ret

mb_check_bricks:
    call removeBrick
    call dball            
    ret

; -------------------------------------------------------
; row_pattern_new: draw 15 bricks, each 4 chars + 1 space
; -------------------------------------------------------
row_pattern_new:
    push di
    push cx
    push si
rp_loop:
    cmp byte [si], 0
    je rp_empty
    mov al, [row_char]
    mov ah, [row_color]
    mov [es:di], ax
    add di, 2
    mov [es:di], ax
    add di, 2
    mov [es:di], ax
    add di, 2
    mov [es:di], ax
    add di, 2
    mov al, ' '
    mov ah, 0x00
    mov [es:di], ax
    add di, 2
    jmp rp_next
rp_empty:
    mov ax, 0x0720
    mov [es:di], ax
    add di, 2
    mov [es:di], ax
    add di, 2
    mov [es:di], ax
    add di, 2
    mov [es:di], ax
    add di, 2
    mov [es:di], ax
    add di, 2
rp_next:
    inc si
    loop rp_loop
    pop si
    pop cx
    pop di
    ret
 
row_offset:
    ; si = screen row number
    ; returns di = video memory offset for that row, col 2
    mov ax, si
    mov bx, 80
    mul bx
    shl ax, 1
    add ax, 4           ; col 2 => +4 bytes
    mov di, ax
    ret
 
dbrick:
    mov ax, 0B800h
    mov es, ax
 
    mov si, 3        
    call row_offset  
    mov byte [row_char], 219
    mov byte [row_color], 0Ch  ; Red
    mov cx, 15
    mov si, row1
    call row_pattern_new
 
    mov si, 5        
    call row_offset
    mov byte [row_char], 219
    mov byte [row_color], 0Eh  ; Yellow
    mov cx, 15
    mov si, row2
    call row_pattern_new
 
    mov si, 7        
    call row_offset
    mov byte [row_char], 219
    mov byte [row_color], 0Ah  ; Green
    mov cx, 15
    mov si, row3
    call row_pattern_new
 
    mov si, 9        
    call row_offset
    mov byte [row_char], 219
    mov byte [row_color], 0Bh  ; Cyan
    mov cx, 15
    mov si, row4
    call row_pattern_new
    ret
 
; -------------------------------------------------------
; removeBrick: 5 cols per brick, 15 bricks per row
; -------------------------------------------------------
removeBrick:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es
 
    mov ax, 0xb800  
    mov es, ax  
    mov ax, [brow]
    cmp ax, 3
    je rb_row1
    cmp ax, 5
    je rb_row2
    cmp ax, 7
    je rb_row3
    cmp ax, 9
    je rb_row4
    jmp near rb_done
 
rb_row1:
    mov si, 3
    call row_offset
    mov si, row1
    mov cx, 15
    jmp rb_calc
rb_row2:
    mov si, 5
    call row_offset
    mov si, row2
    mov cx, 15
    jmp rb_calc
rb_row3:
    mov si, 7
    call row_offset
    mov si, row3
    mov cx, 15
    jmp rb_calc
rb_row4:
    mov si, 9
    call row_offset
    mov si, row4
    mov cx, 15
 
rb_calc:
    ; Ball video memory position
    mov ax, [brow]
    mov bx, 80
    mul bx
    add ax, [bcol]
    shl ax, 1
    mov bx, ax          ; bx = ball vram offset

    ; di = brick row start (col 2)
    ; Each brick = 4 visible + 1 gap = 5 cols = 10 bytes
rb_loop:
    ; Check all 4 visible columns of this brick
    mov ax, di
    cmp ax, bx
    je rb_hit
    add ax, 2
    cmp ax, bx
    je rb_hit
    add ax, 2
    cmp ax, bx
    je rb_hit
    add ax, 2
    cmp ax, bx
    je rb_hit
    ; Not this brick, move to next (5 cols = 10 bytes)
    add di, 10
    inc si
    loop rb_loop
    jmp near rb_done
 
rb_hit:
    ; Is it already empty?
    cmp byte [si], 0
    je rb_done
    mov byte [si], 0        
    add word [score], 10    
    call check_all_bricks_broken
    call flip_bdx           ; bounce ball
    call dbrick              
   
rb_done:
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
 
check_all_bricks_broken:
    push si
    push cx
    
    mov si, row1
    mov cx, 15
cab_row1:
    cmp byte [si], 1
    je cab_not_done
    inc si
    loop cab_row1
    
    mov si, row2
    mov cx, 15
cab_row2:
    cmp byte [si], 1
    je cab_not_done
    inc si
    loop cab_row2
    
    mov si, row3
    mov cx, 15
cab_row3:
    cmp byte [si], 1
    je cab_not_done
    inc si
    loop cab_row3
    
    mov si, row4
    mov cx, 15
cab_row4:
    cmp byte [si], 1
    je cab_not_done
    inc si
    loop cab_row4
    
    call WinnerPage
    
cab_not_done:
    pop cx
    pop si
    ret
 
; -------------------------------------------------------
; Game Over screen
; -------------------------------------------------------
game_over:
    mov al, 3h
    mov ah, 0
    int 10h
    
    mov ah, 06h
    xor al, al
    xor cx, cx
    mov dx, 184Fh
    mov bh, 00h
    int 10h
    
    mov ax, 0xb800
    mov es, ax
    
    ; "GAME OVER" row 10, col 35
    mov di, 1670
    mov si, game_over_txt
    mov cx, 9
    mov ah, 0x0C
go_print:
    lodsb
    stosw
    loop go_print
 
    ; "Final Score: " row 12, col 32
    mov di, 1984
    mov ah, 0x0E
    mov al, 'F'
    mov [es:di], ax
    add di,2
    mov al, 'i'
    mov [es:di], ax
    add di,2
    mov al, 'n'
    mov [es:di], ax
    add di,2
    mov al, 'a'
    mov [es:di], ax
    add di,2
    mov al, 'l'
    mov [es:di], ax
    add di,2
    mov al, ' '
    mov [es:di], ax
    add di,2
    mov al, 'S'
    mov [es:di], ax
    add di,2
    mov al, 'c'
    mov [es:di], ax
    add di,2
    mov al, 'o'
    mov [es:di], ax
    add di,2
    mov al, 'r'
    mov [es:di], ax
    add di,2
    mov al, 'e'
    mov [es:di], ax
    add di,2
    mov al, ':'
    mov [es:di], ax
    add di,2
    mov al, ' '
    mov [es:di], ax
    add di,2
    mov ax, [score]
    call print_number
 
    ; Credits row 22, col 17
    mov di, 3554
    mov si, credits_txt
    mov cx, [credits_len]
    mov ah, 0x0B
go_credits:
    lodsb
    stosw
    loop go_credits
    
    mov ah, 0
    int 0x16
    mov ax, 0x4c00
    int 0x21
 
; -------------------------------------------------------
; Winner Page
; -------------------------------------------------------
WinnerPage:
    pusha
 
    mov al, 3h
    int 10h
 
    mov ah, 06h
    xor al, al
    xor cx, cx
    mov dx, 184Fh
    mov bh, 00h
    int 10h
 
    mov ax, 0B800h
    mov es, ax
 
    ; "CONGRATULATIONS!" row 10, col 32
    mov di, 1664
    mov ah, 0x0A
    mov al, 'C'
    mov [es:di], ax
    add di,2
    mov al, 'O'
    mov [es:di], ax
    add di,2
    mov al, 'N'
    mov [es:di], ax
    add di,2
    mov al, 'G'
    mov [es:di], ax
    add di,2
    mov al, 'R'
    mov [es:di], ax
    add di,2
    mov al, 'A'
    mov [es:di], ax
    add di,2
    mov al, 'T'
    mov [es:di], ax
    add di,2
    mov al, 'U'
    mov [es:di], ax
    add di,2
    mov al, 'L'
    mov [es:di], ax
    add di,2
    mov al, 'A'
    mov [es:di], ax
    add di,2
    mov al, 'T'
    mov [es:di], ax
    add di,2
    mov al, 'I'
    mov [es:di], ax
    add di,2
    mov al, 'O'
    mov [es:di], ax
    add di,2
    mov al, 'N'
    mov [es:di], ax
    add di,2
    mov al, 'S'
    mov [es:di], ax
    add di,2
    mov al, '!'
    mov [es:di], ax
 
    ; "YOU WIN!" row 12, col 36
    mov di, 1992
    mov ah, 0x0E
    mov al, 'Y'
    mov [es:di], ax
    add di,2
    mov al, 'O'
    mov [es:di], ax
    add di,2
    mov al, 'U'
    mov [es:di], ax
    add di,2
    mov al, ' '
    mov [es:di], ax
    add di,2
    mov al, 'W'
    mov [es:di], ax
    add di,2
    mov al, 'I'
    mov [es:di], ax
    add di,2
    mov al, 'N'
    mov [es:di], ax
    add di,2
    mov al, '!'
    mov [es:di], ax
 
    ; "Score: " row 14, col 32
    mov di, 2304
    mov ah, 0x0B
    mov al, 'S'
    mov [es:di], ax
    add di,2
    mov al, 'c'
    mov [es:di], ax
    add di,2
    mov al, 'o'
    mov [es:di], ax
    add di,2
    mov al, 'r'
    mov [es:di], ax
    add di,2
    mov al, 'e'
    mov [es:di], ax
    add di,2
    mov al, ':'
    mov [es:di], ax
    add di,2
    mov al, ' '
    mov [es:di], ax
    add di,2
    mov ax, [score]
    call print_number
 
    ; Credits row 20, col 17
    mov di, 3234
    mov si, credits_txt
    mov cx, [credits_len]
    mov ah, 0x0B
wp_credits:
    lodsb
    stosw
    loop wp_credits
 
    ; "Press any key to exit" row 22, col ~28
    mov di, 3580
    mov si, winner_exit_msg
    mov cx, 24
    mov ah, 0x07
wp_exit:
    lodsb
    stosw
    loop wp_exit
 
    mov ah, 0
    int 0x16
    mov ax, 0x4c00
    int 0x21
 
    popa
    ret