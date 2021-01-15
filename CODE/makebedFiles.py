def main():
    file = open("/home/sanne/bioinf/course9_a.k.a_stage/opdrachtdata/analyse2/ANALYSIS/OTHERSAMPLES/IGVLocationsMF03404HiLoConf.txt", "r")
    regels = lijstenmaken(file)
    regels = locatiemin(regels)
    writetabfile(regels)
    #writefile(regels)

def lijstenmaken(bestand):
    """

    """
    regels = []
    x = 1

    for line in bestand:
        if x > 1:
            if line.startswith('"') and line.endswith('"'):
                string = string[1:-1]
            regel = line.replace("\n", "").split("\t")
            regels.append(regel)
        x += 1
        print(line)
    return regels


def locatiemin(regels):
    for regel in regels:
        if regel[0].startswith('"') and regel[0].endswith('"'):
            regel[0] = regel[0][1:-1]
        #regel[1] = int(regel[1]) - 499
        #regel[2] = int(regel[2]) + 500
    return regels


def writetabfile(regels):
    f = open("/home/sanne/bioinf/course9_a.k.a_stage/opdrachtdata/analyse2/ANALYSIS/OTHERSAMPLES/IGVLocationsMF03404HiLoConf.bed", "w+")
    for regel in regels:
        c, a, b = regel
        c = c.replace('\'', '').replace('\"', '')
        f.write(f'{c}\t{a}\t{b}')
        f.write("\n")

def writefile(regels):
    f = open("/home/sanne/bioinf/course9_a.k.a_stage/opdrachtdata/analyse2/ANALYSIS/OTHERSAMPLES/IGVLocationsMF03404HiLoConfSlice.bed", "w+")
    for regel in regels:
        c, a, b = regel
        c = c.replace('\'', '').replace('\"', '')
        f.write(f'{c}:{a}-{b}')
        f.write("\n")

main()
