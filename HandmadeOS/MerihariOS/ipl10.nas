; meriharios-ipl
; TAB=4

CYLS	EQU		10				; 読み込むシリンダー数

		ORG		0x7c00			; このプログラムがどこに読み込まれるのか

; 以下は標準的なFAT12フォーマットフロッピーディスクのための記述

		JMP		entry
		DB		0x90
		DB		"MERIHARI"		; ブートセクタの名前を自由に書いてよい（8バイト）
		DW		512			; 1セクタの大きさ（512にしなければいけない）
		DB		1			; クラスタの大きさ（1セクタにしなければいけない）
		DW		1			; FATがどこから始まるか（普通は1セクタ目からにする）
		DB		2			; FATの個数（2にしなければいけない）
		DW		224			; ルートディレクトリ領域の大きさ（普通は224エントリにする）
		DW		2880			; このドライブの大きさ（2880セクタにしなければいけない）
		DB		0xf0			; メディアのタイプ（0xf0にしなければいけない）
		DW		9			; FAT領域の長さ（9セクタにしなければいけない）
		DW		18			; 1トラックにいくつのセクタがあるか（18にしなければいけない）
		DW		2			; ヘッドの数（2にしなければいけない）
		DD		0			; パーティションを使ってないのでここは必ず0
		DD		2880			; このドライブ大きさをもう一度書く
		DB		0,0,0x29		; よくわからないけどこの値にしておくといいらしい
		DD		0xffffffff		; たぶんボリュームシリアル番号
		DB		"MERIHARIOS "		; ディスクの名前（11バイト）
		DB		"FAT12   "		; フォーマットの名前（8バイト）
		RESB	18				; とりあえず18バイトあけておく

;プログラム本体

entry:
		MOV		AX,0			; レジスタ初期化
		MOV		SS,AX
		MOV		SP,0x7c00
		MOV		DS,AX			; DS:バッファアドレス

; フロッピー読み込み

		MOV		AX,0x0820		; 0x8200~0x81ffにセクタ2を読み込み.他のセクタもそれに続く(0x8000~0x81ffはipl)
		MOV		ES,AX
		MOV		CH,0			; シリンダ0
		MOV		DH,0			; ヘッド0
		MOV		CL,2			; セクタ2
readloop:		
		MOV		SI,0			; 読み込み失敗回数（セクタ毎）を初期化
retry:
		MOV		AH,0x02			; AH=0x02 : ディスク読み込み
		MOV		AL,1			; 1セクタ
		MOV		BX,0
		MOV		DL,0x00			; Aドライブ
		INT		0x13			; ディスクBIOS呼び出し
		JNC		next_load			; エラーがおきなければ(if CL != 1)next_loadへ
		
		ADD		SI,1			; 読み込み失敗回数に+1
		CMP		SI,5			; 失敗回数 >= 5 ならerrorへ
		JAE		error			
		
		MOV		AH,0x00			; <5ならディスクリセット
		MOV		DL,0x00			; Aドライブ指定
		INT		0x13			;ドライブのリセット
		JMP		retry			; 読み込みリトライ

next_load:
		MOV		AX,ES			; アドレスを0x200(512bite,1sector)進めたい
		ADD		AX,0x0020		; ESはセグメントレジスタ.アドレスが0x010=16倍
		MOV		ES,AX			; ESに0x20を加えるのと、BXに0x200加えるのは同じ。ここではES +=0x20 (ES*0x010 + BX)
	;sector
		ADD		CL,1			; CLに1を足す(sectorを1すすめる)
		CMP		CL,18			; CLと18を比較（sectorは1~18)
		JBE		readloop		; CL=18になるまで読み込み継続
		MOV		CL,1			
	;head
		ADD		DH,1
		CMP		DH,2
		JB		readloop
		MOV		DH,0
	;cylinder
		ADD		CH,1
		CMP		CH,CYLS
		JB		readloop

		MOV		[0x0ff0],CH		; IPLがフロッピーをどこまで読んだのかを、メモリの0x0ff0にメモ

;読み込み完了後 merihari.sys 実行
		JMP		0xc200

error:
		MOV		SI,err_msg
putloop:
		MOV		AL,[SI]
		ADD		SI,1			; SIに1を足す
		CMP		AL,0
		JE		fin
		MOV		AH,0x0e			; 一文字表示ファンクション
		MOV		BX,15			; カラーコード
		INT		0x10			; ビデオBIOS呼び出し
		JMP		putloop
fin:
		HLT					; 何かあるまでCPUを停止させる
		JMP		fin			; 無限ループ
err_msg:
		DB		0x0a, 0x0a		; 改行を2つ
		DB		"load error"
		DB		0x0a			; 改行
		DB		0

		RESB	0x7dfe-$			; 0x7dfeまでを0x00で埋める命令

		DB		0x55, 0xaa		; シグネチャ
