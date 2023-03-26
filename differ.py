# From https://github.com/florian/diff-tool/blob/main/differ.py , https://florian.github.io/diffing/

"""Computes diffs of lines."""

from dataclasses import dataclass

@dataclass(frozen=True)
class Addition:
    """Represents an addition in a diff."""
    content: str

@dataclass(frozen=True)
class Removal:
    """Represents a removal in a diff."""
    content: str

@dataclass(frozen=True)
class Unchanged:
    """Represents something unchanged in a diff."""
    content: str

# Try to import faster version of `_compute_longest_common_subsequence`
#outputsString = False # Assume False
outputsVArray = False # Assume False
try:
    import pylcs
    #_compute_longest_common_subsequence = pylcs.lcs_matrix # Custom build of pylcs to include the internal matrix output
    #_compute_longest_common_subsequence = pylcs.lcs_sparse_matrix # Custom build of pylcs to include the internal matrix output
    #_compute_longest_common_subsequence = pylcs.lcs_string # Custom build of pylcs to output the longest common subsequence as a string
    #outputsString = True
    _compute_longest_common_subsequence = pylcs.diff # Custom build of pylcs to output a varray of changes (from version 0.8.10 of libmba's diff.c on https://www.ioplex.com/~miallen/libmba/dl/src/diff.c and https://github.com/innerout/libmba/blob/master/src/diff.c )
    outputsVArray = True
except:
    def _compute_longest_common_subsequence(text1, text2):
        """Computes the longest common subsequence of the two given strings.
        The result is a table where cell (i, j) tells you the length of the
        longest common subsequence of text1[:i] and text2[:j].
        """
        n = len(text1)
        m = len(text2)

        lcs = [[None for _ in range(m + 1)]
                     for _ in range(n + 1)]

        for i in range(0, n + 1):
            for j in range(0, m + 1):
                if i == 0 or j == 0:
                    lcs[i][j] = 0
                elif text1[i - 1] == text2[j - 1]:
                    lcs[i][j] = 1 + lcs[i - 1][j - 1]
                else:
                    lcs[i][j] = max(lcs[i - 1][j], lcs[i][j - 1])

        return lcs

def diff(text1, text2):
    """Computes the optimal diff of the two given inputs.
    The result is a list where all elements are Removals, Additions or
    Unchanged elements.
    """
    lcs = _compute_longest_common_subsequence(text1, text2)
    #if not outputsString:
    if not outputsVArray:
        results = []

        i = len(text1)
        j = len(text2)

        while i != 0 or j != 0:
            # If we reached the end of text1 (i == 0) or text2 (j == 0), then we
            # just need to print the remaining additions and removals.
            if i == 0:
                results.append(Addition(text2[j - 1]))
                j -= 1
            elif j == 0:
                results.append(Removal(text1[i - 1]))
                i -= 1
            # Otherwise there's still parts of text1 and text2 left. If the
            # currently considered part is equal, then we found an unchanged part,
            # which belongs to the longest common subsequence.
            elif text1[i - 1] == text2[j - 1]:
                results.append(Unchanged(text1[i - 1]))
                i -= 1
                j -= 1
            # In any other case, we go in the direction of the longest common
            # subsequence.
            elif lcs[i - 1][j] <= lcs[i][j - 1]:
                results.append(Addition(text2[j - 1]))
                j -= 1
            else:
                results.append(Removal(text1[i - 1]))
                i -= 1

        # print(list(reversed(results)))
        # exit()
        return list(reversed(results))
    else:
        varray = lcs
        results = []
        print(next(iter(varray)))
        for diff in varray:
            print(diff.op)
            if diff.op == pylcs.DIFF_MATCH:
                results.append(Unchanged(text1[diff.off:diff.off+diff.len]))
            elif diff.op == pylcs.DIFF_INSERT:
                results.append(Addition(text2[diff.off:diff.off+diff.len]))
            elif diff.op == pylcs.DIFF_DELETE:
                results.append(Removal(text1[diff.off:diff.off+diff.len]))
            else:
                assert False

        return results

    # else:
        # NOTE: this implementation doesn't always work properly, so it has been disabled:
        # # Find each character of the string in text1 and text2.
        # lcs, members = lcs
        # results = []
        # iInLcs = 0
        # iInText1 = 0
        # iInText2 = 0
        # debugOutput=False
        # if debugOutput:
        #     import sys
        #     print("lcs:",lcs, file=sys.stderr)
        # while iInLcs < len(lcs):
        #     c1 = text1[iInText1]
        #     c2 = text2[iInText2]
        #     if c1 != lcs[iInLcs]:
        #         results.append(Removal(c1))
        #         iInText1 += 1
        #     elif c2 != lcs[iInLcs]:
        #         results.append(Addition(c2))
        #         iInText2 += 1
        #     else:
        #         if debugOutput and (c1 == '\n' or c2 == '\n'):
        #             print("--", file=sys.stderr)
        #             print(iInLcs, repr(lcs[iInLcs:]), file=sys.stderr)
        #             print(iInText1, repr(text1[iInText1:]), file=sys.stderr)
        #             print(iInText2, repr(text2[iInText2:]), file=sys.stderr)
        #             print(members[iInText1], file=sys.stderr)
        #         results.append(Unchanged(lcs[iInLcs]))
        #         iInLcs += 1
        #         iInText1 += 1
        #         iInText2 += 1
        # # We now add all remaining additions since they may not be in `lcs`:
        # for i in range(iInText2, len(text2)):
        #     results.append(Addition(text2[i]))
        #     if debugOutput:
        #         print('++++++++++++++++++++++++++++++++++++++++',text2[i], file=sys.stderr)
        
        # if debugOutput:
        #     print(results, file=sys.stderr)
        # # print(results)
        # # exit()
        # return results

        # # # Find each character of the string in text1 and text2.
        # # results = []
        # # iInLcs1 = 0
        # # iInLcs2 = 0
        # # iInText1 = 0
        # # iInText2 = 0
        # # while iInLcs1 < len(lcs):
        # #     c1 = text1[iInText1]
        # #     c2 = text2[iInText2]
        # #     if c1 != lcs[iInLcs1]:
        # #         results.append(Removal(c1))
        # #         iInText1 += 1
        # #     if c1 != c2:
        # #         results.append(Addition(c2))
        # #         iInText2 += 1
        # #     elif c2 != lcs[iInLcs2]:
        # #         iInText2 += 1
            
        # #     if c1 == lcs[iInLcs1]:
        # #         results.append(Unchanged(lcs[iInLcs1]))
        # #         iInLcs1 += 1
        # #     if c2 == lcs[iInLcs2]:
        # #         iInLcs2 += 1
        # # # We now add all remaining additions since they may not be in `lcs`:
        # # for i in range(iInText2, len(text2)):
        # #     results.append(Addition(text2[i]))

        # # print(results)
        # # return results

'''(.venv) >python diffs.py human chimpanzee
[Addition(content='c'), Unchanged(content='h'), Removal(content='u'), Addition(c
ontent='i'), Unchanged(content='m'), Addition(content='p'), Unchanged(content='a
'), Unchanged(content='n'), Addition(content='z'), Addition(content='e'), Additi
on(content='e')]
c{Right}{Right}{Backspace}i{Right}p{Right}{Right}zee'''
