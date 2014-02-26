	.data
list:	.space 40
stack:	.space 40
NL:	.asciiz "\n"
prompt:	.asciiz "Zadejte posloupnost max. deseti celych cisel ukoncenych 0:\n"

	.text
	.globl	main

main:	la	$t7, list	#V $t7 bude adresa prvního prvku pole
	la	$t8, list	#V $t8 bude adresa posledního prvku pole 
	la	$t5, stack	#V $t5 bude adresa vrcholu zásobníku
	la	$t9, stack	#V $t9 bude adresa začátku zásobníku, jestliže je $t5 = $t9 zásobník je prázdný
	la	$a0,prompt	#Do $a0 znak konce řádku
	li	$v0,4		#Do $v0 číslo systémové služby 4 (print string)
	syscall			#Zavolání služby ve $v0

rloop:	li	$v0,5		#Do $v0 číslo systémové služby 5 (read int)
	syscall			#Zavolání služby ve $v0
	beq	$v0,0,sstart	#Pokud se hodnota ve $v0 rovná 0, skoč do bloku sstart
	nop
	sw	$v0,($t8)	#Ulož hodnotu z $v0 na adresu $t8
	addi	$t8,$t8,4	#Zvětši $t8 o 4 bajty (velikost datového typu word), $t8 nyní ukazuje na druhý prvek pole
	j	rloop		#Skoč na začátek čtecího cyklu (rloop)
	nop

sstart:	addi	$t8,$t8,-4	#Na konci pole nyní máme 0, proto posuneme ukazatel $t8 na jednu buňku doleva
	sw	$t7,($t5)	#Na vrchol zásobníku vlož adresu prvního prvku pole
	addi	$t5,$t5,4	#Posuň ukazatel na vrchol zásobníku o buňku doprava
	sw	$t8,($t5)	#Na vrchol zásobníku vlož vlož adresu posledního prvku pole
	addi	$t5,$t5,4	#Posuň ukazatel na vrchol zásobníku o buňku doprava

sort:	lw	$s1,-4($t5)	#Do $s1 ulož pravou mez pole z vrcholu zásobníku
	lw	$t0,-8($t5)	#Do $t0 ulož levou mez pole z vrcholu zásobníku, to bude levé ukazovátko
	lw	$t1,-8($t5)	#Do $t1 ulož levou mez pole z vrcholu zásobníku, to bude pravé ukazovátko
	lw	$s0,-8($t5)	#Do $s0 ulož levou mez pole z vrcholu zásobníku
	addi	$t5,$t5,-8	#Posuň ukazatel na vrchol zásobníku o dvě buňky doleva, protože jsme z něj právě dvě hodnoty přečetli
	lw	$t3,($s1)	#Do $t3 ulož hodnotu prvku na pravé mezi, to bude pivot
	addi	$t1,$t1,-4	#Sniž pravé ukazovátko

sloop:	addi	$t1,$t1,4	#Zvyš pravé ukazovátko
	bge	$t1,$s1,endswp	#Ukazuje-li pravé ukazovátko na pravou mez, jsme na konci posloupnosti, skoč na endswp
	nop
	lw	$t2,($t1)	#Do $t2 ulož hodnotu na kterou ukazuje pravé ukazovátko
	nop
	nop
	blt	$t2,$t3,swap	#Je-li hodnota v $t2 menší než pivot, skoč na swap
	nop
	j	sloop		#Skoč na začátek cyklu
	nop

swap:	lw	$t4,($t0)	#Do $t4 ulož hodnotu na kterou ukazuje levé ukazovátko
	sw	$t2,($t0)	#Hodnotu, na kterou ukazuje pravé ukazovátko ulož tam kam ukazuje levé ukazovátko
	addi	$t0,$t0,4	#Posuň levé ukazovátko
	sw	$t4,($t1)	#Hodnotu z $t4 ulož tam kam ukazuje pravé ukazovátko
	j	sloop		#Pokračuj v sortovacím cyklu (sloop)
	nop

endswp:	lw	$t4,($t0)	#
	sw	$t3,($t0)	#
	addi	$t0,$t0,-4	#Sniž levé ukazovátko o jedna - to bude nová pravá mez
	sw	$t4,($t1)	#Prohoď pivot s prvkem na který ukazuje levé ukazovátko
	blt	$s0,$t0,lins	#Jestliže se levá mez nerovná pravé, ulož meze do zásobníku (lins)
	nop

bckswp:	addi	$t0,$t0,8	#Zvyš levé ukazovátko - to bude nová levá mez
	blt	$t0,$s1,rins	#Jestliže se levá mez nerovná pravé, ulož meze do zásobníku (rins)
	nop
	ble	$t5,$t9,wloop	#Je-li zásobník prázdný, vypiš výsledky (wloop)
	nop
	j	sort		#Pokračuj v sortovacím cyklu (sloop)
	nop

lins:	sw	$s0,($t5)	#Uloží do zásobníku meze levé podposloupnosti 
	sw	$t0,4($t5)
	addi	$t5,$t5,8
	j	bckswp
	nop

rins:	sw	$t0,($t5)	#Uloží do zásobníku meze pravé podposloupnosti 
	sw	$s1,4($t5)
	addi	$t5,$t5,8
	j	sort
	nop

wloop:	bgt	$t7,$t8,end	#Pokud je $t7 rovno $t8, jsme na konci pole
	lw	$a0,($t7)	#Obsah adresy $t7 do $a0
	li	$v0,1		#Do $v0 číslo systémové služby 1 (print int)
	syscall			#Zavolání služby ve $v0
	la	$a0,NL		#Do $a0 znak konce řádku
	li	$v0,4		#Do $v0 číslo systémové služby 4 (print string)
	syscall			#Zavolání služby ve $v0
	addi	$t7,$t7,4	#Zvětši $t7 o 4 bajty (velikost datového typu word), $t7 nyní ukazuje na druhý prvek pole
	j	wloop		#Skoč na začátek zapisovacího cyklu (wloop)

end:	nop
	j	$ra
	nop
	
