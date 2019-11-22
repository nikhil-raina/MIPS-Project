RASM  = /home/fac/wrc/bin/rasm
RLINK = /home/fac/wrc/bin/rlink
RSIM  = /home/fac/wrc/bin/rsim


.SUFFIXES:	.asm .obj .lst .out

OBJTS = tents.obj

.asm.obj:
	$(RASM) -l $*.asm > $*.lst

.obj.out:
	$(RLINK) -o $*.out $*.obj

tents.out:	$(OBJTS)
	$(RLINK) -m -o tents.out $(OBJTS) > tents.map

run:	tents.out
	$(RSIM) tents.out
