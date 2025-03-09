def isEqual(headerSum, rowSum, maxDifference):
    if ((headerSum-rowSum) <= maxDifference):
        return True
    return False