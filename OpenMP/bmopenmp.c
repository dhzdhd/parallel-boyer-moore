#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <omp.h>

#define ALPHABET_SIZE 256

void precomputeBadCharacterShift(const char *pattern, int patternLength, int *badCharacterShift)
{
    for (int i = 0; i < ALPHABET_SIZE; i++)
    {
        badCharacterShift[i] = patternLength;
    }
    for (int i = 0; i < patternLength - 1; i++)
    {
        badCharacterShift[(int)pattern[i]] = patternLength - i - 1;
    }
}

void boyerMoore(const char *text, int textLength, const char *pattern, int patternLength, int *results)
{
    int badCharacterShift[ALPHABET_SIZE];
    precomputeBadCharacterShift(pattern, patternLength, badCharacterShift);
#pragma omp parallel for
    for (int skip = 0; skip <= textLength - patternLength; skip++)
    {
        int j = patternLength - 1;
        while (j >= 0 && pattern[j] == text[skip + j])
        {
            j--;
        }
        if (j < 0)
        {
#pragma omp atomic write
            results[skip] = 1; // Match found
            printf("Thread %d writing :\n", omp_get_thread_num());
            skip += badCharacterShift[(int)text[skip + patternLength]];
        }
        else
        {
            skip += badCharacterShift[(int)text[skip + j]];
        }
    }
}

int main()
{
    const char *text = "AABAACAADAABAABA";
    const char *pattern = "AABA";

    int textLength = strlen(text);
    int patternLength = strlen(pattern);
    int *results = (int *)malloc(textLength * sizeof(int));
    memset(results, 0, textLength * sizeof(int));

    boyerMoore(text, textLength, pattern, patternLength, results);

    printf("Pattern found at positions: ");
    for (int i = 0; i < textLength; i++)
    {
        if (results[i] == 1)
        {
            printf("%d ", i);
        }
    }
    printf("\n");

    free(results);

    return 0;
}