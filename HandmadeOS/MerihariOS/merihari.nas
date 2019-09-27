;merihari-os
; TAB=4
		ORG		0xc200	; merihari.sys のファイルの中身は merihari.img 上の0x4200から書き込まれる
					; ブートセクタの先頭はメモリ上の0x8000に読み込んでいるので 0x8000 + 0x4200 = 0xc200
					;ジャンプ元はipl.nas の load_sys

		MOV		AL,0x13			; VGAグラフィックス、320x200x8bitカラー
		MOV		AH,0x00
		INT		0x10
fin:
		HLT
		JMP	fin