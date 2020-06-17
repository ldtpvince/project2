	.data
	re_input:	.asciiz	"\nMoi ban nhap lai.\n"
	input_day: 	.asciiz	"Nhap ngay DAY:"
	input_month:	.asciiz "\nNhap thang MONTH:"
	input_year:	.asciiz "\nNhap nam YEAR:"
	choice:		.asciiz "----------Ban hay chon 1 trong cac thao tac duoi day----------\n"
	choice1:	.asciiz "1.Xuat string TIME theo dinh dang DD/MM/YYYY\n"
	choice2:	.asciiz "2.Chuyen doi string TIME thanh mot trong cac dinh dang sau:\n"
	choice2_A:	.asciiz "\tA.MM/DD/YYYY\n"
	choice2_B:	.asciiz "\tB.Month DD, YYYY\n"
	choice2_C:	.asciiz "\tC.DD Month, YYYY\n"
	choice3:	.asciiz "3.Cho biet ngay vua nhap la ngay thu may trong tuan.\n"
	choice4:	.asciiz "4.Kiem tra nam trong string TIME co phai la nam nhuan khong?\n"
	choice5:	.asciiz "5.Cho biet khoang thoi gian giua string TIME_1 va TIME_2.\n"
	choice6:	.asciiz "6.Cho biet 2 nam nhuan gan nhat voi nam trong string time.\n"
	close_choice:	.asciiz "----------------------------------------------------------------\n"
	str_day:	.space	3
	str_month:	.space	3
	str_nameMonth	.space 	4
	str_year:	.space	5
	time:		.space	11
	time_mon: 	.space 	13
	mon:		.asciiz	"Mon"
	tue:		.asciiz	"Tues"
	wed:		.asciiz	"Wed"
	thu:		.asciiz	"Thurs"
	fri:		.asciiz	"Fri"
	sat:		.asciiz	"Sat"
	sun:		.asciiz	"Sun"
	t0:		.space	15
	t1:		.space	15
	test0:		.asciiz	"1234"
	.text
.globl main
main:
	addi	$a0,$zero,10
	addi	$a1,$zero,3
	addi	$a2,$zero,123
	la	$a3,time
	jal	DATE
	addi	$a0,$v0,0
	jal	print_Str
	addi	$v0,$zero,10
	syscall
#Nhap ngay thang nam
input:
	subi 	$sp,$sp,4
	sw	$ra,0($sp)
read_DMY:
	#Nhap ngay
	la	$a0,input_day
	addi	$a1,$zero,3
	la	$a2,str_day
	jal	request_Read
	#Nhap thang
	la	$a0,input_month
	addi	$a1,$zero,3
	la	$a2,str_month
	jal	request_Read
	#Nhap nam
	la	$a0,input_year
	addi	$a1,$zero,5
	la	$a2,str_year
	jal	request_Read
	#Thu hoi stack
	lw	$ra,0($sp)
	addi	$sp,$sp,4
	jr 	$ra
#Nhap lai
re_Input:
	la	$a0,re_input
	jal	print_Str
	j	read_DMY
#Kiem tra hop le 3 string $a0 (day), $a1 (month), $a2 (year). Ket qua tra ve $v0, 1:dung, 0:sai
check_Valid:
	sw	$a0,0($sp)
	sw	$a1,4($sp)
	sw	$a2,8($sp)
	sw	$ra,12($sp)
	#Kiem tra co toan so khong?
	jal	checkAllNum
	beq	$v0,$zero,return_cv
	lw	$a0,4($sp)
	jal	checkAllNum
	beq	$v0,$zero,return_cv
	lw	$a0,8($sp)
	jal	checkAllNum
	beq	$v0,$zero,return_cv
	#Trich xuat ngay, thang, nam
	subi	$sp,$sp,8
	lw	$t0,8($sp)
	jal	strToNum
	sw	$v0,0($sp)
	lw	$t0,12($sp)
	jal	strToNum
	sw	$v0,4($sp)
	lw	$t0,16($sp)
	jal	strToNum
	lw	$a0,0($sp)
	lw	$a1,4($sp)
	addi	$a2,$v0,0
	addi	$sp,$sp,8
	jal	checkLogic
	beq	$v0,$zero,return_cv
	#Kiem tra ngay thang nam
	addi	$v0,$v0,1
return_cv:
	sw	$a0,0($sp)
	sw	$a1,4($sp)
	sw	$a2,8($sp)
	sw	$ra,12($sp)
	addi	$sp,$sp,16
	jr	$ra
#Kiem tra tinh logic cua 3 so $a0 (ngay), $a1 (thang), $a2 (nam). $v0=1: dung, $v0=0: sai
checkLogic:
	addi	$v0,$zero,0	#false
	subi	$sp,$sp,16
	sw	$a0,0($sp)
	sw	$a1,4($sp)
	sw	$a2,8($sp)
	sw	$ra,12($sp)
	#Kiem tra nam
	slti	$t0,$a2,1900
	bne	$t0,$zero,return_cl
	#Kiem tra thang
	slti	$t0,$a1,1
	bne	$t0,$zero,return_cl
	slti	$t0,$a1,13
	beq	$t0,$zero,return_cl
	#Kiem tra ngay
	slti	$t0,$a0,1
	bne	$t0,$zero,return_cl
	addi	$a0,$a2,0
	jal	getDate
	lw	$a0,0($sp)
	addi	$v0,$v0,1
	slt	$t0,$a0,$v0
	beq	$t0,$zero,return_cl
	addi	$v0,$zero,1	#true
return_cl:
	lw	$a0,0($sp)
	lw	$a1,4($sp)
	lw	$a2,8($sp)
	lw	$ra,12($sp)
	addi	$sp,$sp,16
#Lay ngay cua nam $a0 va thang $a1
getDate:
	subi	$sp,$sp,12
	sw	$a0,0($sp)
	sw	$a1,4($sp)
	sw	$ra,8($sp)
	#Neu la nam nhuan va la thang 2
	jal	LeapYear
	beq	$v0,$zero,notLeap
	bne	$a1,2,notLeap
	addi	$v0,$zero,29
	j	return_gd
#Gan $v0=30
set30:
	addi	$v0,$zero,30
	j	return_gd
#Gan $v0=31
set31:
	addi	$v0,$zero,31
	j	return_gd
#Nam khong nhuan hoac nam nhuan va thang khac 2
notLeap:
	beq	$a1,1,set31
	beq	$a1,3,set31
	beq	$a1,5,set31
	beq	$a1,7,set31
	beq	$a1,8,set31
	beq	$a1,10,set31
	beq	$a1,12,set31
	beq	$a1,4,set30
	beq	$a1,6,set30
	beq	$a1,9,set30
	beq	$a1,11,set30
	#Thang 2
	addi	$v0,$zero,28
return_gd:
	lw	$a0,0($sp)
	lw	$a1,4($sp)
	lw	$ra,8($sp)
	addi	$sp,$sp,12
	jr	$ra
#In string vi tri $a0, doc string co $a1 ki tu vao vi tri $a2 (co chuan hoa)
request_Read:
	subi	$sp,$sp,4
	sw	$a0,0($sp)
	jal	print_Str
	addi	$a0,$s2,0
	jal	read_Str
	addi	$a1,$zero,3
	jal	std_Str
	lw	$a0,0($sp)
	addi	$sp,$sp,4
	jr	$ra
#Chuan hoa string $a0 du $a1 ki tu (tinh ca '\0' sau khi chuan hoa), xoa bo '\n' trong string
std_Str:
	subi	$sp,$sp,4
	sw	$ra,0($sp)
	#$t0 chua dia chi cuoi string
	la	$t0,0($a0)
	add	$t0,$t0,$a1
	subi	$t0,$t0,1
	sb	$zero,0($t0)
	subi	$sp,$sp,4
	sw	$t0,0($sp)
	jal	findEndStr
	lw	$t0,0($sp)
	addi	$sp,$sp,4
	addi	$t1,$v0,0
	addi	$t3,$zero,48	#ki tu 0
loop_ssn:
	subi	$t0,$t0,1
	subi	$t1,$t1,1
	slt	$t2,$t1,$a0
	bne	$t2,$zero,loop_ins_0
	lb	$t2,0($t1)
	sb	$t2,0($t0)
	j	loop_ssn
	#Chen 0
loop_ins_0:
	slt	$t1,$t0,$a0
	bne	$t1,$zero,return_ssn
	sb	$t3,0($t0)
	subi	$t0,$t0,1
	j	loop_ins_0
return_ssn:
	lw	$ra,0($sp)
	addi	$sp,$sp,4
	jr	$ra
#Tim vi tri '\0' hoac '\n' cua string $a0, ket qua tra ve $v0
findEndStr:
	addi	$v0,$a0,0
loop_fan:
	lb	$t0,0($v0)
	beq	$t0,'\0',return_fan
	beq	$t0,'\n',return_fan
	addi	$v0,$v0,1
	j	loop_fan
return_fan:
	jr	$ra
#Copy string $a1 vao $a0
sCopy:
	addi	$t0,$a0,0	#index $a0
	addi	$t1,$a1,0	#index $a1
loop_cs:
	lb	$t2,0($t1)
	beq	$t2,'\0',return_cs
	addi	$t1,$t1,1
	sb	$t2,0($t0)
	addi	$t0,$t0,1
	j	loop_cs
return_cs:
	sb	$zero,0($t0)
	jr	$ra
#Kiem tra string vi tri $a0 co toan so khong?
checkAllNum:
	addi	$t0,$a0,0
	addi	$v0,$zero,1
loop_can:
	lb	$t1,0($t0)
	beq	$t1,'\0',return_can
	slti	$t2,$t1,48
	bne	$t2,$zero,set_can_false
	slti	$t2,$t1,58
	beq	$t2,$zero,set_can_false
	addi	$t0,$t0,1
	j	loop_can
set_can_false:
	addi	$v0,$zero,0
return_can:
	jr	$ra
#In string $a0
print_Str:
	subi	$sp,$sp,4
	sw	$v0,0($sp)
	addi	$v0,$zero,4
	syscall
	lw	$v0,0($sp)
	addi	$sp,$sp,4
	jr	$ra
#Doc string $a0 do dai $a1
read_Str:
	subi	$sp,$sp,4
	sw	$v0,0($sp)
	addi	$v0,$zero,8
	syscall
	lw	$v0,0($sp)
	addi	$sp,$sp,4
	jr	$ra
#In gia tri $a0
print_Int:
	subi	$sp,$sp,4
	sw	$v0,0($sp)
	addi	$v0,$zero,1
	syscall
	lw	$v0,0($sp)
	addi	$sp,$sp,4
	jr	$ra
#Chuyen string vi tri $a0 thanh so, ket qua tra ve $v0
strToNum:
	addi	$v0,$zero,0
	addi	$t0,$a0,0	#index
loop_stn:
	lb	$t1,0($t0)
	beq	$t1,'\0',return_stn
	subi	$t1,$t1,48
	mul	$v0,$v0,10
	add	$v0,$v0,$t1
	addi	$t0,$t0,1
	j	loop_stn
return_stn:
	jr	$ra
#Do dai chuoi $a0, ket qua tra ve $v0
sLeng:
	addi	$t0,$a0,0
	addi	$v0,$zero,0
loop_sl:
	lb	$t1,0($t0)
	beq	$t1,'\0',return_sl
	addi	$t0,$t0,1
	addi	$v0,$v0,1
	j	loop_sl
return_sl:
	jr	$ra
#Dao nguoc string $a0
sReverse:
	subi	$sp,$sp,4
	sw	$ra,0($sp)
	jal	sLeng
	add	$t0,$a0,$v0
	subi	$t0,$t0,1
	la	$t1,t0		#temp string
loop_sr:
	slt	$t2,$t0,$a0
	bne	$t2,$zero,return_sr
	lb	$t2,0($t0)
	sb	$t2,0($t1)
	subi	$t0,$t0,1
	addi	$t1,$t1,1
	j	loop_sr
return_sr:
	addi	$v0,$a0,0
	sb	$zero,0($t1)
	la	$a1,t0
	jal	sCopy
	lw	$ra,0($sp)
	addi	$sp,$sp,4
	jr	$ra
#Chuyen so $a0 thanh string $v0
numToStr:
	subi	$sp,$sp,8
	sw	$a0,0($sp)
	sw	$ra,4($sp)
	la	$t0,t1
	addi	$t1,$a0,0	#index
loop_nts:
	beq	$t1,$zero,return_nts
	div	$t1,$t1,10
	mfhi	$t2
	addi	$t2,$t2,48
	sb	$t2,0($t0)
	addi	$t0,$t0,1
	j	loop_nts
return_nts:
	sb	$zero,0($t0)
	la	$a0,t1
	jal	sReverse
	lw	$a0,0($sp)
	lw	$ra,4($sp)
	addi	$sp,$sp,8
	la	$v0,t1
	jr	$ra
#Truyen vao 3 so $a0(day),$a1(month),$a2(year), string $a3. Ket qua tra ve la string $v0 dinh dang DD/MM/YYYY
DATE:
	#Khoi tao vung nho
	subi	$sp,$sp,16
	sw	$ra,0($sp)
	sw	$a0,4($sp)
	sw	$a1,8($sp)
	sw	$a2,12($sp)
	addi	$t7,$zero,47	#Dau '/'
	#Ngay
	jal	numToStr
	addi	$a0,$v0,0
	addi	$a1,$zero,3
	jal	std_Str
	addi	$a1,$a0,0
	addi	$a0,$a3,0
	jal	sCopy
	sb	$t7,2($a3)
	#Thang
	lw	$a0,8($sp)
	jal	numToStr
	addi	$a0,$v0,0
	addi	$a1,$zero,3
	jal	std_Str
	addi	$a1,$a0,0
	addi	$a0,$a3,3
	jal	sCopy
	sb	$t7,5($a3)
	#Nam
	lw	$a0,12($sp)
	jal	numToStr
	addi	$a0,$v0,0
	addi	$a1,$zero,5
	jal	std_Str
	addi	$a1,$a0,0
	addi	$a0,$a3,6
	jal	sCopy
	#Thu hoi vung nho
	lw	$ra,0($sp)
	lw	$a0,4($sp)
	lw	$a1,8($sp)
	addi	$sp,$sp,12
	addi	$v0,$a3,0
	jr	$ra
#String TIME $a0, tra ve string $v0 la thu may trong tuan
Weekday:
	subi	$sp,$sp,8
	sw	$a0,0($sp)
	sw	$ra,4($sp)
	subi	$sp,$sp,12
	#Lay ngay, thang, nam vao $t0, $t1, $t2
	jal	Day
	sw	$v0,0($sp)
	jal	Month
	sw	$v0,4($sp)
	jal	Year
	sw	$v0,8($sp)
	#The ky
	addi	$a0,$v0,0
	jal	getCentury
	lw	$t0,0($sp)
	addi	$t0,$v0,0
	sw	$t0,0($sp)
	lw	$t2,8($sp)
	addi	$a0,$t2,0
	jal	LeapYear
	lw	$t0,0($sp)	#result (sum)
	lw	$t1,4($sp)
	lw	$t2,8($sp)
	addi	$sp,$sp,12
	div	$t3,$t2,100
	mfhi	$t2
	add	$t0,$t0,$t2
	div	$t2,$t2,4
	add	$t0,$t0,$t2
	add	$t0,$t0,$t3
	beq	$v0,$zero,notLeap_wd
	beq	$t1,1,set6
	beq	$t1,2,set2
	#Tinh thu
notLeap_wd:
	beq	$t1,2,set3
	beq	$t1,3,set3
	beq	$t1,4,set6
	beq	$t1,5,set1
	beq	$t1,6,set4
	beq	$t1,7,set6
	beq	$t1,8,set2
	beq	$t1,9,set5
	beq	$t1,10,set0
	beq	$t1,11,set3
	beq	$t1,11,set5
setM0:
	addi	$t1,$zero,0
	j	continue_y
setM1:
	addi	$t1,$zero,1
	j	continue_y
setM2:
	addi	$t1,$zero,2
	j	continue_y
setM3:
	addi	$t1,$zero,3
	j	continue_y
setM4:
	addi	$t1,$zero,4
	j	continue_y
setM5:
	addi	$t1,$zero,5
	j	continue_y
setM6:
	addi	$t1,$zero,6
continue_y:
	add	$t0,$t0,$t1
	div	$t0,$t0,7
	mfhi	$t0
	beq	$t0,0,setD0
	beq	$t0,1,setD1
	beq	$t0,2,setD2
	beq	$t0,3,setD3
	beq	$t0,4,setD4
	beq	$t0,5,setD5
	beq	$t0,6,setD6
	sw	$a0,0($sp)
	sw	$ra,4($sp)
	addi	$sp,$sp,8
setD0:
	la	$v0,sun
	jr	$ra
setD1:
	la	$v0,mon
	jr	$ra
setD2:
	la	$v0,tue
	jr	$ra
setD3:
	la	$v0,wed
	jr	$ra
setD4:
	la	$v0,thu
	jr	$ra
setD5:
	la	$v0,fri
	jr	$ra
setD6:
	la	$v0,sat
	jr	$ra
#$a0 (nam), $v0 the ky
getCentury:
	subi	$sp,$sp,4
	sw	$a0,0($sp)
	addi	$a0,$a0,99
	div	$v0,$a0,100
	sw	$a0,0($sp)
	addi	$sp,$sp,4
# Ham chuyen doi chuoi time $a0 voi kieu chuyen TYPE $a1, truyen vao chuoi $a2, tra ve $v0 la chuoi time_mon
Convert: 
	addi 	$sp, $sp, -24
	sw	$ra, 0($sp)
	sw	$a0, 16($sp)
	sw	$a1, 20($sp)
	#Lay ngay, thang, nam vao $t0, $t1, $t2
	jal	Day
	sw	$v0,4($sp)
	jal	Month
	sw	$v0,8($sp)
	jal	Year
	sw	$v0,12($sp)
				
	beq	$a1, 'A', typeA
	beq	$a1, 'B', typeB
	beq 	$a1, 'C', typeC
typeA:
	addi	$t7,$zero,47		#Dau '/'
	# Thang
	lw 	$a0, 8($sp)		# Lay gia tri cua Month
	jal	numToStr
	addi	$a0,$v0,0
	addi	$a1,$zero,3
	jal	std_Str
	addi	$a1,$a0,0
	addi	$a0,$a2,0
	jal	sCopy
	sb	$t7,2($a2)
	# Ngay
	lw 	$a0, 4($sp)		# Lay gia tri cua Day
	jal	numToStr
	addi	$a0,$v0,0
	addi	$a1,$zero,3
	jal	std_Str
	addi	$a1,$a0,0
	addi	$a0,$a2,3
	jal	sCopy
	sb	$t7,5($a2)
	# Nam
	lw 	$a0, 12($sp)		# Lay gia tri cua Year
	jal	numToStr
	addi	$a0,$v0,0
	addi	$a1,$zero,5
	jal	std_Str
	addi	$a1,$a0,0
	addi	$a0,$a2,6
	jal	sCopy
	sb	$0, 10($a2)		# Ket chuoi
	j	return_Convert
typeB:
	addi	$t7, $zero, ' '		# Dau ' '
	addi	$t6, $zero, ','		# Dau ','
	# Thang
	la	$a0, str_nameMonth
	lw 	$a1, 8($sp)		# Lay gia tri cua Month
	jal	nameOfMonth
	addi	$a1,$a0,0
	addi	$a0,$a2,0
	jal	sCopy
	sb	$t7,3($a2)
	# Ngay
	lw 	$a0, 4($sp)		# Lay gia tri cua Day
	jal	numToStr
	addi	$a0,$v0,0
	addi	$a1,$zero,3
	jal	std_Str
	addi	$a1,$a0,0
	addi	$a0,$a2,4
	jal	sCopy
	sb	$t6, 6($a2)
	sb	$t7, 7($a2)
	# Nam
	lw 	$a0, 12($sp)		# Lay gia tri cua Year
	jal	numToStr
	addi	$a0,$v0,0
	addi	$a1,$zero,5
	jal	std_Str
	addi	$a1,$a0,0
	addi	$a0,$a2,8
	jal	sCopy
	sb	$0,12($a2)
	
	j	return_Convert
typeC:
	addi	$t7, $zero, ' '		# Dau ' '
	addi	$t6, $zero, ','		# Dau ','
	# Ngay
	lw 	$a0, 4($sp)		# Lay gia tri cua Day
	jal	numToStr
	addi	$a0,$v0,0
	addi	$a1,$zero,3
	jal	std_Str
	addi	$a1,$a0,0
	addi	$a0,$a2,0
	jal	sCopy
	sb	$t7, 2($a2) 
	# Thang
	la	$a0, str_nameMonth
	lw 	$a1, 8($sp)		# Lay gia tri cua Month
	jal	nameOfMonth
	addi	$a1,$a0,0
	addi	$a0,$a2,3
	jal	sCopy
	sb	$t6, 6($a2)
	sb	$t7, 7($a2)
	# Nam
	lw 	$a0, 12($sp)		# Lay gia tri cua Year
	jal	numToStr
	addi	$a0,$v0,0
	addi	$a1,$zero,5
	jal	std_Str
	addi	$a1,$a0,0
	addi	$a0,$a2,8
	jal	sCopy
	sb	$0,12($a2)
	
	j	return_Convert
return_Convert:
	lw	$ra, 0($sp)
	lw 	$a0, 16($sp)
	lw 	$a1, 20($sp)
	addi	$sp, $sp, 24
	jr 	$ra
# Ham lay ngay tu chuoi TIME
# int Day(char* TIME);
# *TIME ~ $a0
Day:
	# Luu lai dia chi address
	addi 	$sp, $sp, -8
	sw 	$ra, 0($sp)
	sw 	$a0, 4($sp)
	
	la	$a0, str_day
	lw	$a1, 4($sp)
	addi	$a2, $0, 0		# Vi tri DD/MM/YYYYY: 0 -> 1
	addi 	$a3, $0, 1
	jal	sCopyStr		## $a0 = DD
	#Lay lai dia chi address
	jal	strToNum
	addi	$v0, $v0, 0
	lw 	$a0, 4($sp)
	lw 	$ra, 0($sp)
	addi 	$sp, $sp, 8
	jr 	$ra
# Ham lay thang tu chuoi TIME
# int Month(char* TIME);
# *TIME ~ $a0
Month:
	# Luu lai dia chi address
	addi 	$sp, $sp, -8
	sw 	$ra, 0($sp)
	sw 	$a0, 4($sp)
	
	la	$a0, str_month
	lw	$a1, 4($sp)
	addi	$a2, $0, 3		# Vi tri DD/MM/YYYYY: 3 -> 4
	addi 	$a3, $0, 4
	jal	sCopyStr
	#Lay lai dia chi address
	jal	strToNum
	addi	$v0, $v0, 0
	lw 	$a0, 4($sp)
	lw 	$ra, 0($sp)
	addi 	$sp, $sp, 8
	jr 	$ra
# Ham lay nam tu chuoi TIME
# int Year(char* TIME);
# *TIME ~ $a0
Year:
	# Luu lai dia chi address
	addi 	$sp, $sp, -8
	sw 	$ra, 0($sp)
	sw 	$a0, 4($sp)
	
	la	$a0, str_year
	lw	$a1, 4($sp)
	addi	$a2, $0, 6		# Vi tri DD/MM/YYYYY: 6 -> 9
	addi 	$a3, $0, 9
	jal	sCopyStr
	#Lay lai dia chi address
	jal	strToNum
	addi	$v0, $v0, 0
	lw 	$a0, 4($sp)
	lw 	$ra, 0($sp)
	addi 	$sp, $sp, 8
	jr 	$ra
# Ham copy string chuoi $a1 tu vi tri $a2 den vi tri $a3 vao $a0
sCopyStr:
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	addi	$t0, $a2, 0		# Dia chi bat dau copy
	addi	$t1, $0, 0		# i = 0
	slt	$t2, $a3, $t0
	bne	$t2, 0, out_sCopyStr
loop_sCopyStr:
	slt	$t2, $a3, $t0
	bne	$t2, 0, out_sCopyStr
	add 	$t3, $t0, $a1
	add	$t4, $t1, $a0
	lb 	$t5, 0($t3)		# Doc byte cua $a1 vao $t5
	sb	$t5, 0($t4)		# Luu $t5 vao $a0
	
	addi	$t1, $t1, 1
	addi 	$t0, $t0, 1
	j 	loop_sCopyStr
out_sCopyStr:
	add 	$t4, $t1, $a0
	sb	$0,  0($t4)		# Them '/0' cuoi chuoi $a0
	lw 	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr	$ra

# Ham lay ten cua thang $a1 tra ve chuoi cho $a0
nameOfMoth:
	addi	$sp, $sp, -4
	sw 	$a1, 0($sp)
	
	beq	$a1, 1, set_Jan
	beq	$a1, 2, set_Feb
	beq	$a1, 3, set_Mar
	beq	$a1, 4, set_Apr
	beq	$a1, 5, set_May
	beq	$a1, 6, set_Jun
	beq	$a1, 7, set_Jul
	beq	$a1, 8, set_Aug
	beq	$a1, 9, set_Sep
	beq	$a1, 10, set_Oct
	beq	$a1, 11, set_Nov
	beq	$a1, 12, set_Dec
# Cac ham dat ten thang
set_Jan:	
	addi	$a1, $zero, 'J'
	addi	$a2, $zero, 'a'
	addi	$a3, $zero, 'n'
	j 	getName
set_Feb:	
	addi	$a1, $zero, 'F'
	addi	$a2, $zero, 'e'
	addi	$a3, $zero, 'b'
	j 	 getName
set_Mar:	
	addi	$a1, $zero, 'M'
	addi	$a2, $zero, 'a'
	addi	$a3, $zero, 'r'
	j 	 getName
set_Apr:	
	addi	$a1, $zero, 'A'
	addi	$a2, $zero, 'p'
	addi	$a3, $zero, 'r'
	j 	 getName
set_May:	
	addi	$a1, $zero, 'M'
	addi	$a2, $zero, 'a'
	addi	$a3, $zero, 'y'
	j 	 getName
set_Jun:	
	addi	$a1, $zero, 'J'
	addi	$a2, $zero, 'u'
	addi	$a3, $zero, 'n'
	j 	 getName
set_Jul:	
	addi	$a1, $zero, 'J'
	addi	$a2, $zero, 'u'
	addi	$a3, $zero, 'l'
	j 	 getName
set_Aug:	
	addi	$a1, $zero, 'A'
	addi	$a2, $zero, 'u'
	addi	$a3, $zero, 'g'
	j 	 getName
set_Sep:	
	addi	$a1, $zero, 'S'
	addi	$a2, $zero, 'e'
	addi	$a3, $zero, 'p'
	j 	 getName
set_Oct:	
	addi	$a1, $zero, 'O'
	addi	$a2, $zero, 'c'
	addi	$a3, $zero, 't'
	j 	 getName
set_Nov:	
	addi	$a1, $zero, 'N'
	addi	$a2, $zero, 'o'
	addi	$a3, $zero, 'v'
	j 	 getName
set_Dec:	
	addi	$a1, $zero, 'D'
	addi	$a2, $zero, 'e'
	addi	$a3, $zero, 'c'
	j 	 getName	
# Ket hop cac ky tu cua thang
getName:
	sb	$a1, 0($a0)
	sb	$a2, 1($a0)
	sb	$a3, 2($a0)
	addi	$t0, $0, 0		# Dau ket thuc chuoi '/0'
	sb	$t0, 3($a0)
return_nameMon:
	lw	$a1, 0($sp)
	addi	$sp, $sp, 4
	jr 	$ra
# int GetTime(char&* TIME_1, char* TIME_2)
# Ham tinh khoang cach giua 2 chuoi TIME $a0, $a1 tra ve $v0
GetTime:
	addi	$sp, $sp, 
	sw	$ra, 0($sp)
	sw	$a0, 4($sp)
	sw	$a1, 8($sp)
	
	# Lay nam cua 2 TIME gan vao $t0, $t1
	jal 	Year
	addi	$t0, $v0, 0
	lw	$a0, 8($sp)
	jal	Year
	addi	$t1, $v0, 0

	sub	$t2, $t1, $t0
	beq	$t2, 0, set0_distance
	# Kiem tra thoi gian nao lon hon, gan $a2 = 1 neu TIME_1 < TIME_2 va nguoc lai
	slt	$t3, $t2, $0
	beq	$t3, $0, set_SmallerTime
	addi	$a2, $zero, 0
	# t2 = t0 - t1
	addi	$t2, $t0, $t1
	j	compare_DayMonth
set_SmallerTime:	
	addi 	$a2, $0, 1
# So sanh ngay, thang cua 2 TIME_1 va TIME_2
compare_DayMonth:
	sw	$t2, 16($sp)		# Luu lai gia tri distance(TIME1, TIME2)
	sw	$a2, 12($sp)		# Luu lai bien kiem tra TIME1 < TIME2
	# So sanh thang
	lw	$a0, 4($sp)
	lw 	$a1, 8($sp)
	jal	compare_Month
	addi	$t1, $v0, 0
	beq	$t1, $zero, setMinus_distance
	addi	$t0, $zero, 1
	beq	$t1, $t0, set_distance
	# So sanh ngay
	lw	$a0, 4($sp)
	lw 	$a1, 8($sp)
	jal	compare_Day
	addi	$t1, $v0, 0
	beq	$t1, $zero, setMinus_distance
	j	 set_distance
set0_distance:
	addi	$v0, $0, 0
	j 	return_GT
setMinus_distance:
	lw	$v0, 16($sp)
	addi	$v0, $v0, -1
	j	return_GT
set_distance:
	lw	$v0, 16($sp)
	j 	return_GT
return_GT:
	lw	$ra, 0($sp)
	lw	$a0, 4($sp)
	lw 	$a1, 8($sp)
	addi	$sp, $sp, 12
	jr	$ra
# Ham so sanh thang cua 2 chuoi TIME_1 $a0 va TIME_2 $a1 voi $a2 la dieu kien kiem tra, $a2 = 1 TIME1 < TIME2
# va nguoc lai, tra ve $v0 = 1 neu thoa nho hon, $v0 = 0 thi khoang cach - 1, $v0 = 2 tiep tuc so sanh ngay
compare_Month:
	addi	$sp, $sp, 20
	sw 	$ra, 0($sp)
	sw	$a0, 4($sp)
	sw 	$a1, 8($sp)
	sw	$a2, 16($sp)
	jal	Month
	addi	$t0, $zero, 0
	sw	$t0, 12($sp)
	lw	$a0, 8($sp)
	jal	Month
	addi	$t1, $zero, 0
	
	lw	$t0, 12($sp)
	lw	$a2, 16($sp)
	beq	$a2, $0, distance_Month
	sub	$t2, $t1, $t0
	j	check_cM
# t2 = t0 - t1 neu $v0 = 0: TIME1 > TIME2
distance_Month:
	sub	$t2, $t0, $t1
check_cM:
	beq	$t2, $0, set2_cM
	slt	$t3, $t2, $0
	beq	$t3, $0, set1_cM
	addi	$v0, $zero, 0 		# Thang cua nam nho hon lon hon
	j	return_cM
set1_cM:
	addi	$v0, $0, 1
	j	return_cM
set2_cM:
	addi	$v0, $zero, 2
	j	return_cM
return_cM:
	lw 	$ra, 0($sp)
	lw	$a0, 4($sp)
	lw 	$a1, 8($sp)
	lw	$a2, 16($sp)
	addi	$sp, $sp, 20
	jr	$ra	
# Ham so sanh ngay cua 2 chuoi TIME_1 $a0 va TIME_2 $a1 voi $a2 la dieu kien kiem tra, $a2 = 1 TIME1 < TIME2
# va nguoc lai, tra ve $v0 = 1 neu thoa nho hon hoac bang hoac TH dac biet nam nhuan, $v0 = 0 thi khoang cach - 1
compare_Day:
	addi	$sp, $sp, 24
	sw 	$ra, 0($sp)
	sw	$a0, 4($sp)
	sw 	$a1, 8($sp)
	sw	$a2, 12($sp)
	
	jal	Day
	addi	$t0, $zero, 0
	sw	$t0, 16($sp)
	lw	$a0, 8($sp)
	jal	Day
	addi	$t1, $zero, 0
	sw	$t1, 20($sp)
	
	lw	$t0, 16($sp)
	lw	$a2, 12($sp)
	beq	$a2, $0, distance_Day
	sub	$t2, $t1, $t0
	j	check_cD
# t2 = t0 - t1 neu $v0 = 0: TIME1 > TIME2
distance_Day:
	sub	$t2, $t0, $t1
check_cD:
	slt	$t3, $t2, $0
	beq	$t3, $0, set1_cD
	addi	$t7, $0, 29
	addi	$t6, $0, 28
	lw	$a2, 12($sp)
	# Kiem tra truong hop dac biet
	beq	$a2, $zero, check_cD_LeapYear
	lw	$t0, 16($sp)
	bne	$t0, $t7, set0_cD
	lw	$t1, 20($sp)
	bne	$t1, $t6, set0_cD
	j	set1_cD
check_cD_LeapYear:
	lw	$t0, 16($sp)
	bne	$t0, $t6, set0_cD
	lw	$t1, 20($sp)
	bne	$t1, $t7, set0_cD
	j	set1_cD
set1_cD:
	addi	$v0, $0, 1
	j	return_cD
set0_cD:
	addi	$v0, $0, 0
	j	return_cD
return_cD:
	lw 	$ra, 0($sp)
	lw	$a0, 4($sp)
	lw 	$a1, 8($sp)
	lw	$a2, 12($sp)
	addi	$sp, $sp, 24
	jr	$ra	
