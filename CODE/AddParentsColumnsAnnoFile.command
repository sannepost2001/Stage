{
	if (NR < 2 ){
	#add headers
		print $0 "\tGT.father\tAD.father\tDP.father\tGQ.father\tJL.father\tJP.father\tPGT.father\tPID.father\tPL.father\tPP.father\tAD1.father\tAD2.father\tAD3.father\tGT.mother\tAD.mother\tDP.mother\tGQ.mother\tJL.mother\tJP.mother\tPGT.mother\tPID.mother\tPL.mother\tPP.mother\tAD1.mother\tAD2.mother\tAD3.mother"
	}else{
	#check if $172 is the same as given thn split all so it can be worked with
		if ($172  ~ "GT:AD:DP:GQ:JL:JP:PGT:PID:PL:PP"){
			# GT:AD:DP:GQ:JL:JP:PGT:PID:PL:PP
			# 1  2  3  4  5  6  7  8    9  10
			split($174,FatherArr,":")
			split($175,MotherArr,":")
			split(FatherArr[2],FatherAdArr,",")
			split(MotherArr[2],MotherAdArr,",")
			print $0 "\t" FatherArr[1] "\t" FatherArr[2] "\t" FatherArr[3] "\t" FatherArr[4] "\t" FatherArr[5] "\t" FatherArr[6] "\t" FatherArr[7] "\t" FatherArr[8] "\t" FatherArr[9] "\t" FatherArr[10] "\t" FatherAdArr[1] "\t" FatherAdArr[2] "\t" FatherAdArr[3]  "\t" MotherArr[1] "\t" MotherArr[2] "\t" MotherArr[3] "\t" MotherArr[4] "\t" MotherArr[5] "\t" MotherArr[6] "\t" MotherArr[7] "\t" MotherArr[8] "\t" MotherArr[9] "\t" MotherArr[10] "\t" MotherAdArr[1] "\t" MotherAdArr[2] "\t" MotherAdArr[3]
		}

		else if ($172 ~ "GT:AD:DP:GQ:JL:JP:PL:PP"){
			#GT:AD:DP:GQ:JL:JP:PL:PP
			# 1 2  3  4  5  6  7  8
			# missing PGT:PID: ==> misssing 7 8
			split($174,FatherArr,":")
			split($175,MotherArr,":")
			split(FatherArr[2],FatherAdArr,",")
			split(MotherArr[2],MotherAdArr,",")
			print $0 "\t" FatherArr[1] "\t" FatherArr[2] "\t" FatherArr[3] "\t" FatherArr[4] "\t" FatherArr[5] "\t" FatherArr[6] "\t" "NA"  "\t" "NA" "\t" FatherArr[7] "\t" FatherArr[8] "\t" FatherAdArr[1] "\t" FatherAdArr[2] "\t" FatherAdArr[3] "\t" MotherArr[1] "\t" MotherArr[2] "\t" MotherArr[3] "\t" MotherArr[4] "\t" MotherArr[5] "\t" MotherArr[6] "\t" "NA"  "\t" "NA" "\t" MotherArr[7] "\t" MotherArr[8] "\t" MotherAdArr[1] "\t" MotherAdArr[2] "\t" MotherAdArr[3]
		
		}
		else if ($172 ~ "GT:AD:DP:GQ:PGT:PID:PL:PP"){
			# GT:AD:DP:GQ:PGT:PID:PL:PP
			# 1 2  3  4  5  6  7  8  9
			# missing JL:JP ==> 5 6
			split($174,FatherArr,":")
			split($175,MotherArr,":")
			split(FatherArr[2],FatherAdArr,",")
			split(MotherArr[2],MotherAdArr,",")
			print $0 "\t" FatherArr[1] "\t" FatherArr[2] "\t" FatherArr[3] "\t" FatherArr[4] "\t"  "NA"  "\t" "NA" "\t" FatherArr[5] "\t" FatherArr[6] "\t" FatherArr[7] "\t" FatherArr[8] "\t" FatherAdArr[1] "\t" FatherAdArr[2] "\t" FatherAdArr[3] "\t" MotherArr[1] "\t" MotherArr[2] "\t" MotherArr[3] "\t" MotherArr[4] "\t"  "NA"  "\t" "NA" "\t" MotherArr[5] "\t" MotherArr[6] "\t" MotherArr[7] "\t" MotherArr[8] "\t" MotherAdArr[1] "\t" MotherAdArr[2] "\t" MotherAdArr[3]
		
		}
		else if ($172 ~ "GT:AD:DP:GQ:PL:PP"){
			# GT:AD:DP:GQ:PL:PP
			# 1  2  3  4  5  6 
			# missing JL:JP:PGT:PID ==> 5 6 7 8
			split($174,FatherArr,":")
			split($175,MotherArr,":")
			split(FatherArr[2],FatherAdArr,",")
			split(MotherArr[2],MotherAdArr,",")
			print $0 "\t" FatherArr[1] "\t" FatherArr[2] "\t" FatherArr[3] "\t" FatherArr[4] "\t" "NA"  "\t" "NA"   "\t" "NA"  "\t" "NA"  "\t" FatherArr[5] "\t" FatherArr[6] "\t" FatherAdArr[1] "\t" FatherAdArr[2] "\t" FatherAdArr[3] "\t" MotherArr[1] "\t" MotherArr[2] "\t" MotherArr[3] "\t" MotherArr[4] "\t" "NA"  "\t" "NA"   "\t" "NA"  "\t" "NA"  "\t" MotherArr[5] "\t" MotherArr[6] "\t" MotherAdArr[1] "\t" MotherAdArr[2] "\t" MotherAdArr[3]
		
		}
		else if ($172 ~ "GT:AD:DP:GQ:PL"){
			# GT:AD:DP:GQ:PL
			split($174,FatherArr,":")
			split($175,MotherArr,":")
			split(FatherArr[2],FatherAdArr,",")
			split(MotherArr[2],MotherAdArr,",")
			print $0 "\t" FatherArr[1] "\t" FatherArr[2] "\t" FatherArr[3] "\t" FatherArr[4]  "\t"  "NA"  "\t" "NA"   "\t" "NA"  "\t" "NA"  "\t" FatherArr[5] "\t" "NA" "\t" FatherAdArr[1] "\t" FatherAdArr[2] "\t" FatherAdArr[3] "\t" MotherArr[1] "\t" MotherArr[2] "\t" MotherArr[3] "\t" MotherArr[4]  "\t"  "NA"  "\t" "NA"   "\t" "NA"  "\t" "NA"  "\t" MotherArr[5] "\t" "NA" "\t" MotherAdArr[1] "\t" MotherAdArr[2] "\t" MotherAdArr[3]

		}
		else if ($172 ~ "GT:AD:DP:GQ:PGT:PID:PL"){
			# GT:AD:DP:GQ:PGT:PID:PL
			split($174,FatherArr,":")
			split($175,MotherArr,":")
			split(FatherArr[2],FatherAdArr,",")
			split(MotherArr[2],MotherAdArr,",")
			print $0 "\t" FatherArr[1] "\t" FatherArr[2] "\t" FatherArr[3] "\t" FatherArr[4] "\t"  "NA"  "\t" "NA"   "\t" FatherArr[5] "\t" FatherArr[6] "\t" FatherArr[7]  "\t" "NA" "\t" FatherAdArr[1] "\t" FatherAdArr[2] "\t" FatherAdArr[3] "\t" MotherArr[1] "\t" MotherArr[2] "\t" MotherArr[3] "\t" MotherArr[4] "\t"  "NA"  "\t" "NA"    "\t" MotherArr[5] "\t" MotherArr[6] "\t" MotherArr[7]  "\t" "NA" "\t" MotherAdArr[1] "\t" MotherAdArr[2] "\t" MotherAdArr[3]																																																			
		}
		
		else {
			print $0 "\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t" 
		}
	}
}
