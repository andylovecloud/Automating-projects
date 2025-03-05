# Check the Reference Number in the invoices

def isRefCorrect(referencenumber):
    listed = list(referencenumber)
    checknumber = listed.pop()
    totalAmount = 0
    product = 1

    while len(listed) > 0:
        if product == 1:
            product = 7
        elif product == 3:
            product = 1
        else:
            product = 3
        totalAmount += product * int(listed.pop())

    result = (10 - (totalAmount % 10)) % 10
    return result == int(checknumber)

def isEqual(headerTotal, rowTotal, maxDifference):
    if (abs(headerTotal - rowTotal) < maxDifference):
        return True
    return False

if __name__ == '__main__':
    #ref = '7701003100356403' #real format of reference number -> True
    ref = '7672682';            #testing ref numnber -> False
    val = isRefCorrect(ref)
    print(val)