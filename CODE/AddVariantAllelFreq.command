{
	if (NR < 2 ){
		print $0 "\tVarAlFreq"
	}else{
		if ($187 > 0 && $178 > 0){
		print $0 "\t" ($187/$178)
        }
		else{
		print $0 "\t0"
		}
	}
}