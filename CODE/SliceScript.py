from subprocess import call

mnregionfiles = 'IGVLocations.bed'
somebamfile = 'sample.PE.ra.md.bam'

fileNames = []

# open locations file
with open(mnregionfiles, 'r') as f:
        for line in f:
                # for evey line slice piece out of the BAM file                
                region = line.strip('\n')
                outputfileBAM = f"sample{region}.bam"
                outputfileBAI = f"sample{region}.bam.bai"
                fileNames.append(outputfileBAM)
                command = f'samtools view -b {somebamfile} {region} > {outputfileBAM}'
                command2 = f'samtools index {outputfileBAM} {outputfileBAI}'
                call(command, shell=True)
                call(command2, shell=True)

        b = ' '.join(fileNames)
        print(b)
        #merge all slices into one big file
        command3 =  f'samtools merge tmp.slice.bam {b}'
        call(command3, shell=True)
        # sort all slices of the big file
        command4 = 'samtools sort -o all.slices.sorted.bam tmp.slice.bam'
        call(command4, shell=True)
        # make index the big file
        command5 = 'samtools index all.slices.sorted.bam all.slices.sorted.bam.bai'
        call(command5, shell=True)
       


