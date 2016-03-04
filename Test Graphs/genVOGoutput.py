import random

# edge file
l = open('testInputfile.out', 'w')
# VOG output file
f = open('testVOGfile.model', 'w')

# makes full-clique with size number of nodes
def makeFullClique(size):
    result = 'fc'
    resultlist = random.sample(range(1,50), size)

    for i in range(len(resultlist)):
        result += ' ' + str(resultlist[i])

        for j in range(i + 1, len(resultlist)):
            l.write(str(resultlist[i])+','+str(resultlist[j])+',1\n')

    f.write(result + '\n')

# makes star with size number of nodes
def makeStar(size):
    result = 'st'

    resultlist = random.sample(range(1,50), size)

    for i in range(len(resultlist)):
        result += ' ' + str(resultlist[i])

        if i == 0:
            result += ','
        else:
            l.write(str(resultlist[0])+','+str(resultlist[i])+',1\n')

    f.write(result + '\n')

# makes chain with size number of nodes
def makeChain(size):
    result = 'ch'
    resultlist = random.sample(range(1,50), size)

    for i in range(len(resultlist)):
        result += ' ' + str(resultlist[i])

        if i < len(resultlist)-1:
            l.write(str(resultlist[i])+','+str(resultlist[i+1])+',1\n')

    f.write(result + '\n')

# makes bipartite core with size number of nodes
def makeBC(size):
    result = 'bc'
    resultlist = random.sample(range(1,50), size)
    separator = random.randint(1, size-3)

    for i in range(len(resultlist)):
        result += ' ' + str(resultlist[i])

        if i == separator:
            result += ','

    sets = result.strip().split(",")

    setA = sets[0].split(" ")[1:]
    setB = sets[1].split(" ")[1:]

    for elem1 in setA:
        for elem2 in setB:
            l.write(elem1+','+elem2+',1\n')

    f.write(result + '\n')

# generates 10 of each structure

for i in range(10):
    makeFullClique(random.randint(5,20))
    makeStar(random.randint(5,20))
    makeChain(random.randint(5,20))
    makeBC(random.randint(5,20))


