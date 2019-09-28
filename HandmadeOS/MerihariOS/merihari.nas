;merihari-os
; TAB=4

; BOOT_INFO関係のメモ
CYLS	EQU		0x0ff0		; iplが設定
LEDS	EQU		0x0ff1		; keyboard LED
VMODE	EQU		0x0ff2		; 色数に関する情報。何ビットカラーか？
SCRNX	EQU		0x0ff4		; 解像度
SCRNY	EQU		0x0ff6		
VRAM	EQU		0x0ff8		; グラフィックバッファの開始番地

		ORG		0xc200	; merihari.sys のファイルの中身は merihari.img 上の0x4200から書き込まれる
						; ブートセクタの先頭はメモリ上の0x8000に読み込んでいるので 0x8000 + 0x4200 = 0xc200
						; ジャンプ元はipl.nas の load_sys

		MOV		AL,0x13			; VGAグラフィックス、320x200x8bitカラー 64kB
		MOV		AH,0x00
		INT		0x10
		MOV		BYTE [VMODE],8		;以下は画面モードのメモ
		MOV		WORD [SCRNX],320
		MOV		WORD [SCRNY],200
		MOV		DWORD [VRAM],0x000a0000

;キーボードのLED状態をBIOSに教えてもらう

		MOV		AH,0x02
		INT		0X16		; keyboard BIOS
		MOV		[LEDS],AL

fin:
		HLT
		JMP	fin