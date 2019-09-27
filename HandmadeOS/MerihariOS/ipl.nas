; meriharios-ipl
; TAB=4

CYLS	EQU		10				;�ǂݍ��ރV�����_�[��

		ORG		0x7c00			; ���̃v���O�������ǂ��ɓǂݍ��܂��̂�

; �ȉ��͕W���I��FAT12�t�H�[�}�b�g�t���b�s�[�f�B�X�N�̂��߂̋L�q

		JMP		entry
		DB		0x90
		DB		"MERIHARI"		; �u�[�g�Z�N�^�̖��O�����R�ɏ����Ă悢�i8�o�C�g�j
		DW		512			; 1�Z�N�^�̑傫���i512�ɂ��Ȃ���΂����Ȃ��j
		DB		1			; �N���X�^�̑傫���i1�Z�N�^�ɂ��Ȃ���΂����Ȃ��j
		DW		1			; FAT���ǂ�����n�܂邩�i���ʂ�1�Z�N�^�ڂ���ɂ���j
		DB		2			; FAT�̌��i2�ɂ��Ȃ���΂����Ȃ��j
		DW		224			; ���[�g�f�B���N�g���̈�̑傫���i���ʂ�224�G���g���ɂ���j
		DW		2880			; ���̃h���C�u�̑傫���i2880�Z�N�^�ɂ��Ȃ���΂����Ȃ��j
		DB		0xf0			; ���f�B�A�̃^�C�v�i0xf0�ɂ��Ȃ���΂����Ȃ��j
		DW		9			; FAT�̈�̒����i9�Z�N�^�ɂ��Ȃ���΂����Ȃ��j
		DW		18			; 1�g���b�N�ɂ����̃Z�N�^�����邩�i18�ɂ��Ȃ���΂����Ȃ��j
		DW		2			; �w�b�h�̐��i2�ɂ��Ȃ���΂����Ȃ��j
		DD		0			; �p�[�e�B�V�������g���ĂȂ��̂ł����͕K��0
		DD		2880			; ���̃h���C�u�傫����������x����
		DB		0,0,0x29		; �悭�킩��Ȃ����ǂ��̒l�ɂ��Ă����Ƃ����炵��
		DD		0xffffffff		; ���Ԃ�{�����[���V���A���ԍ�
		DB		"MERIHARIOS "		; �f�B�X�N�̖��O�i11�o�C�g�j
		DB		"FAT12   "		; �t�H�[�}�b�g�̖��O�i8�o�C�g�j
		RESB	18				; �Ƃ肠����18�o�C�g�����Ă���

; �v���O�����{��

entry:
		MOV		AX,0			; ���W�X�^������
		MOV		SS,AX
		MOV		SP,0x7c00
		MOV		DS,AX			; DS:�o�b�t�@�A�h���X

; �f�B�X�N��ǂ�

		MOV		AX,0x0820		;0x8200~0x81ff�ɃZ�N�^2��ǂݍ���.���̃Z�N�^������ɑ���(0x8000~0x81ff��ipl)
		MOV		ES,AX
		MOV		CH,0			; �V�����_0
		MOV		DH,0			; �w�b�h0
		MOV		CL,2			; �Z�N�^2
readloop:		
		MOV		SI,0			; �ǂݍ��ݎ��s�񐔁i�Z�N�^���j��������
retry:
		MOV		AH,0x02			; AH=0x02 : �f�B�X�N�ǂݍ���
		MOV		AL,1			; 1�Z�N�^
		MOV		BX,0
		MOV		DL,0x00			; A�h���C�u
		INT		0x13			; �f�B�X�NBIOS�Ăяo��
		JNC		next_load			; �G���[�������Ȃ����(if CL != 1)next_load��
		
		ADD		SI,1			; �ǂݍ��ݎ��s�񐔂�+1
		CMP		SI,5			; ���s�� >= 5 �Ȃ�error��
		JAE		error			
		
		MOV		AH,0x00			; <5�Ȃ�f�B�X�N���Z�b�g
		MOV		DL,0x00			; A�h���C�u�w��
		INT		0x13			; �h���C�u�̃��Z�b�g
		JMP		retry			; �ǂݍ��݃��g���C

next_load:
		MOV		AX,ES			; �A�h���X��0x200(512bite,1sector)�i�߂���
		ADD		AX,0x0020		; ES�̓Z�O�����g���W�X�^.�A�h���X��0x010=16�{
		MOV		ES,AX			; ES��0x20��������̂ƁABX��0x200������͓̂����B�����ł�ES +=0x20 (ES*0x010 + BX)
	;sector
		ADD		CL,1			; CL��1�𑫂�(sector��1�����߂�)
		CMP		CL,18			; CL��18���r�isector��1~18)
		JBE		readloop		; CL=18�ɂȂ�܂œǂݍ��݌p��
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

		MOV		[0x0ff0],CH		; IPL���ǂ��܂œǂ񂾂̂�������

;�ǂݍ��݊����� merihari.sys ���s

load_sys:
		JMP		0xc200

; �Q��

fin:
		HLT					; ��������܂�CPU���~������
		JMP		fin			; �������[�v

error:
		MOV		SI,err_msg
putloop:
		MOV		AL,[SI]
		ADD		SI,1			; SI��1�𑫂�
		CMP		AL,0
		JE		fin
		MOV		AH,0x0e			; �ꕶ���\���t�@���N�V����
		MOV		BX,15			; �J���[�R�[�h
		INT		0x10			; �r�f�IBIOS�Ăяo��
		JMP		putloop
err_msg:
		DB		0x0a, 0x0a		; ���s��2��
		DB		"load error"
		DB		0x0a			; ���s
		DB		0

		RESB	0x7dfe-$			; 0x7dfe�܂ł�0x00�Ŗ��߂閽��

		DB		0x55, 0xaa		;�V�O�l�`��
