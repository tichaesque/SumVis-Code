import random

currID = 1

f = open('testVOGfile2.model', 'w')

# makes full-clique with size number of nodes
def makeFullClique(size):
    global currID
    result = 'fc'
    for i in range(size):
        result += ' ' + str(currID)
        currID = currID+1

    f.write(result + '\n')

# makes star with size number of nodes
def makeStar(size):
    global currID
    result = 'st'

    for i in range(size):
        result += ' ' + str(currID)

        if i == 0:
            result += ',' 
        currID = currID+1

    f.write(result + '\n')

# makes chain with size number of nodes
def makeChain(size):
    global currID
    result = 'ch' 

    for i in range(size):
        result += ' ' + str(currID)
        currID = currID+1

    f.write(result + '\n')

# makes bipartite core with size number of nodes
def makeBC(size):
    global currID
    result = 'bc' 
    separator = random.randint(1, size-3)

    for i in range(size):
        result += ' ' + str(currID)

        if i == separator:
            result += ','
        currID = currID+1

    f.write(result + '\n')


makeFullClique(5)
makeStar(5)
makeBC(5)
makeChain(5)

f.close()

# edge file
lines = [line.rstrip('\n') for line in open('testVOGfile2.model')]

# VOG output file
l = open('testInputFile2.out', 'w')

for line in lines:
    prefix = line[:2]
    nodes = line[3:]

    if prefix == 'st':
        center = nodes.split(",")[0]
        satellites = nodes.split(",")[1].strip().split(" ")

        for i in range(len(satellites)):
            l.write(center+','+satellites[i]+',1\n')

    elif prefix == 'fc':
        members = nodes.split(" ")
        
        for i in range(len(members)): 
            for j in range(i + 1, len(members)):
                l.write(members[i]+','+members[j]+',1\n')

    elif prefix == 'ch':
        members = nodes.split(" ")
        
        for i in range(1,len(members)): 
            l.write(members[i-1]+','+members[i]+',1\n')

    elif prefix == 'bc':
        setA = nodes.split(",")[0].strip().split(" ")
        setB = nodes.split(",")[1].strip().split(" ")

        for elem1 in setA:
            for elem2 in setB:
                l.write(elem1+','+elem2+',1\n')

