FILENAME==ARGV[4] {  file1A[FNR] = $0 ; next }
FILENAME==ARGV[3] {  file2A[$1$2$3] = $0 ; next }
FILENAME==ARGV[2] {  file3A[$1$2$3] = $0 ; next }
FILENAME==ARGV[1] {  file4A[$1$2$3] = $0 ; next }

END{ 
print (file1A[1]"\tTP.FP")

	for (key in file1A) { 
			if (key == 1 ){
				#header
				#De index is door elkaar dus de header is al geprint
			}else{
				found=0
				split(file1A[key],file1AS,"\t")
				for (key2 in file2A) {
					if (key2==file1AS[1]file1AS[2]file1AS[3] && found==0){
						print file1A[key] "\tFP"
						found=1
					}
				}
				if (found==0){
					for (key4 in file4A) {
						if (key4==file1AS[1]file1AS[2]file1AS[3] && found==0){
							print file1A[key] "\tTP1"
							found=1
						}
					}
				}
				if (found==0){
					for (key3 in file3A) {
						if (key3==file1AS[1]file1AS[2]file1AS[3] && found==0){
							print file1A[key] "\tTP"
							found=1
						}
				}
				}
				if (found==0){
						print file1A[key] "\t"
				}
			}
		}
	}
