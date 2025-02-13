
org 0x7c00
bits 16

jmp short main
nop

bdb_oem:                    db 'MSWIN.1'
bdb_bytes_per_sector:       dw 512
bdb_sectores_per_cluster:   db 1
bdb_reserved_sector:        db 1
bdb_fat_count:              db 2
bdb_dir_entries_count:      dw 0E0h
bdb_totals_sectors:         dw 2880
bdb_media_descriptor_type:  db 0F0h
bdb_sectors_per_fat:        dw 9
bdb_sectors_per_track:      dw 18
bdb_heads:                  dw 2
bdb_hidden_sectors:         dw 0
bdb_large_sector_count:     dw 0

ebr_drive_number:           db 0
ebr_reserved_byte:          db 0
ebr_signature:              db 29h
ebr_volume_id:              db 12h,34h,56h,78h
ebr_volume_label:           db 'fork OS    '
ebr_system_id:              db 'FAT12   '

main:
    mov ax,0
    mov ds,ax
    mov es,ax
    mov ss,ax

    mov sp,0x7c00
    mov si,boot_msg
    call print
    hlt

halt:
    jmp halt

print:
    push si
    push ax
    push bx

print_loop:
    lodsb 
    or al,al 
    jz done_print
    mov ah, 0x0e
    mov bh, 0
    int 0x10

    jmp print_loop

done_print:
    pop si
    pop ax
    pop bx
    ret

boot_msg: DB "Fork has booted!" , 0x0d, 0x0a, 0


times 510 - ($-$$) DB 0
    dw 0aa55h


