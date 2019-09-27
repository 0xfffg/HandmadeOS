TOOLPATH = ../z_tools/
MAKE     = $(TOOLPATH)make.exe -r
NASK     = $(TOOLPATH)nask.exe
EDIMG    = $(TOOLPATH)edimg.exe
IMGTOL   = $(TOOLPATH)imgtol.com
COPY     = copy
DEL      = del

# デフォルト動作

default :
	$(MAKE) img

# ファイル生成規則

ipl.bin : ipl.nas Makefile
	$(NASK) ipl.nas ipl.bin ipl.lst

merihari.sys : merihari.nas Makefile
	$(NASK) merihari.nas merihari.sys merihari.lst

merihari.img : ipl.bin merihari.sys Makefile
	$(EDIMG)   imgin:../z_tools/fdimg0at.tek \
		wbinimg src:ipl.bin len:512 from:0 to:0 \
		copy from:merihari.sys to:@: \
		imgout:merihari.img

# コマンド

asm :
	$(MAKE) ipl.bin

img :
	$(MAKE) merihari.img

run :
	$(MAKE) img
	$(COPY) merihari.img ..\z_tools\qemu\fdimage0.bin
	$(MAKE) -C ../z_tools/qemu

install :
	$(MAKE) img
	$(IMGTOL) w a: merihari.img

clean :
	-$(DEL) ipl.bin
	-$(DEL) ipl.lst
	-$(DEL) merihari.sys
	-$(DEL) merihari.lst

src_only :
	$(MAKE) clean
	-$(DEL) merihari.img
