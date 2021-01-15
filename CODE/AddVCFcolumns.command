{
	if (NR < 2 ){
		print $0 "\tAC\tAN\tBaseQRankSum\tClippingRankSum\tExcessHet\tFS\tMLEAC\tMLEAF\tMQ\tMQRankSum\tMQRankSum\tNEGATIVE_TRAIN_SITE\tPG\tQD\tReadPosRankSum\tSOR\tVQSLOD\tculprit"

	}else{
		new_var = $0 
        split($171,OutArr,";")
		# ------------------------------------------------------------------------ AC
		velden="AC\tAN\tBaseQRankSum\tClippingRankSum\tExcessHet\tFS\tMLEAC\tMLEAF\tMQ\tMQRankSum\tMQRankSum\tNEGATIVE_TRAIN_SITE\tPG\tQD\tReadPosRankSum\tSOR\tVQSLOD\tculprit"
		split(velden, VeldenA, "\\t")
		for (counter = 1; counter <19; counter++){
			Zoekstr =  VeldenA[counter] "="
#			print Zoekstr
			found=0
			for (o in OutArr){
				if (index(OutArr[o], Zoekstr) && found != 1){
					split(OutArr[o], printArr, "=")
					found=1
					new_var = new_var "\t" printArr[2]
				}
			}
			if (found = 0){	new_var = new_var "\t"}
		}
		# ------------------------------------------------------------------------
	print new_var	
	}
    
}
        
