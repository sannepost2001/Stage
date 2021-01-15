{
	if (NR < 2 ){
		print $0 "\tCHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\tMF005051\tMF005052\tMF005053\tGT\tAD\tDP\tGQ\tJL\tJP\tPGT\tPID\tPL\tPP\tAD1\tAD2\tAD3\tConf\tPopMax\tVarAlFreq"
	}
else{
		new_var = $0
		DP =  0
		AD2 = 0
#		print $new_var
		PopMax = 0
		if ($172  ~ "GT:AD:DP:GQ:JL:JP:PGT:PID:PL:PP"){
			# GT:AD:DP:GQ:JL:JP:PGT:PID:PL:PP
			# 1  2  3  4  5  6  7  8    9  10
			split($173,OutArr,":")
			split(OutArr[2],AdArr,",")
			DP =  OutArr[3]
			AD2 = AdArr[2]
			new_var = new_var "\t" OutArr[1] "\t" OutArr[2] "\t" OutArr[3] "\t" OutArr[4] "\t" OutArr[5] "\t" OutArr[6] "\t" OutArr[7] "\t" OutArr[8] "\t" OutArr[9] "\t" OutArr[10] "\t" AdArr[1] "\t" AdArr[2] "\t" AdArr[3] 
		}
		else if ($172 ~ "GT:AD:DP:GQ:JL:JP:PL:PP"){
			#GT:AD:DP:GQ:JL:JP:PL:PP
			# 1 2  3  4  5  6  7  8
			# missing PGT:PID: ==> misssing 7 8
			split($173,OutArr,":")
			split(OutArr[2],AdArr,",")
			DP =  OutArr[3]
			AD2 = AdArr[2]
			new_var = new_var "\t" OutArr[1] "\t" OutArr[2] "\t" OutArr[3] "\t" OutArr[4] "\t" OutArr[5] "\t" OutArr[6] "\t"  "NA"  "\t" "NA" "\t" OutArr[7]  "\t" OutArr[8] "\t" AdArr[1] "\t" AdArr[2] "\t" AdArr[3]
		}
		else if ($172 ~ "GT:AD:DP:GQ:PGT:PID:PL:PP"){
			# GT:AD:DP:GQ:PGT:PID:PL:PP
			# 1 2  3  4  5  6  7  8  9
			# missing JL:JP ==> 5 6
			split($173,OutArr,":")
			split(OutArr[2],AdArr,",")
			DP =  OutArr[3]
			AD2 = AdArr[2]
			new_var = new_var "\t" OutArr[1] "\t" OutArr[2] "\t" OutArr[3] "\t" OutArr[4] "\t"  "NA"  "\t" "NA"   "\t"  OutArr[5] "\t" OutArr[6] "\t"  OutArr[7]  "\t" OutArr[8] "\t" AdArr[1] "\t" AdArr[2] "\t" AdArr[3]
		}
		else if ($172 ~ "GT:AD:DP:GQ:PL:PP"){
			# GT:AD:DP:GQ:PL:PP
			# 1  2  3  4  5  6 
			# missing JL:JP:PGT:PID ==> 5 6 7 8
			split($173,OutArr,":")
			split(OutArr[2],AdArr,",")
			DP =  OutArr[3]
			AD2 = AdArr[2]
			new_var = new_var "\t" OutArr[1] "\t" OutArr[2] "\t" OutArr[3] "\t" OutArr[4] "\t"  "NA"  "\t" "NA"   "\t" "NA"  "\t" "NA"  "\t"  OutArr[5] "\t" OutArr[6] "\t" AdArr[1] "\t" AdArr[2] "\t" AdArr[3]
		}
		else {
			new_var = new_var "\t\t\t\t\t\t\t\t\t\t" 
		}
		
		if (match($171,"loConfDeNovo=MF034041" ) > 0) {
			new_var = new_var "\tloConf"
		} 
	    else if (match($171,"hiConfDeNovo=MF034041") > 0) {
            new_var = new_var "\thiConf"
        }
		else{
			new_var = new_var "\t"
		}
    

		if ($38 > $40 && $38 > $42  && $38 > $44 && $38 > $45 && $38 > $46){
			PopMax =$38
			new_var = new_var "\t" $38
		}
	        else if ($40 > $38 && $40 > $42  && $40 > $44 && $40 > $45 && $40 > $46){
			PopMax =$40
			new_var = new_var "\t" $40
		}
		else if ($42 > $40 && $42 > $38  && $42 > $44 && $42 > $45 && $42 > $46){
			PopMax =$42
			new_var = new_var "\t" $42
		}
		else if ($44 > $40 && $44 > $42  && $44 > $38 && $44 > $45 && $44 > $46){
			PopMax =$44
			new_var = new_var "\t" $44
		}
		else if ($45 > $40 && $45 > $42  && $45 > $44 && $45 > $38 && $45 > $46){
			PopMax =$45
			new_var = new_var "\t" $45
		}
		else if ($46 > $40 && $46 > $42  && $46 > $44 && $46 > $45 && $46 > $38){
			PopMax =$46
			new_var = new_var "\t" $46
		}
        else{
			new_var = new_var "\t" "0"
        }
		
		if (DP>0){
			VarAlFreq = (AD2/DP)
			new_var = new_var "\t" (AD2/DP)
		}else{
			new_var = new_var "\t0"
		}
		print new_var
	}
}

