#include <mpi.h>
#include <stdio.h>
#include <string.h>
#include <malloc.h>

#define ALPHABET_SIZE 256

void precomputeBadCharacterShift(const char* pattern, int patternLength, int* badCharacterShift) {
    for (int i = 0; i < ALPHABET_SIZE; i++) {
        badCharacterShift[i] = patternLength;
    }
    for (int i = 0; i < patternLength - 1; i++) {
        badCharacterShift[(int)pattern[i]] = patternLength - i - 1;
    }
}

void boyerMoore(int rank, const char* text, int textLength, const char* pattern, int patternLength, int* results) {
    if (rank < textLength - patternLength + 1) {
        int badCharacterShift[ALPHABET_SIZE];
        precomputeBadCharacterShift(pattern, patternLength, badCharacterShift);

        int skip = 0;
        while (skip <= textLength - patternLength) {
            int j = patternLength - 1;
            while (j >= 0 && pattern[j] == text[rank + j]) {
                j--;
            }
            if (j < 0) {
                results[rank] = 1;
                return;
            }
            else {
                int badCharIndex = (int)text[rank + j];
                skip += badCharacterShift[badCharIndex];
            }
            rank += skip;
        }
    }
}

int main(int argc, char** argv) {
    const char* text = "abcdefghi";
    const char* pattern = "gh";

    int textLength = strlen(text);
    int patternLength = strlen(pattern);
    int* results = (int*)malloc(textLength * sizeof(int));

    int rank, size;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    boyerMoore(rank, text, textLength, pattern, patternLength, results);

    MPI_Barrier(MPI_COMM_WORLD);

    if (rank == 0) {
        printf("Pattern found at positions: ");
        for (int i = 0; i < textLength; i++) {
            if (results[i] == 1) {
                printf("%d ", i);
            }
        }
        printf("\n");

        free(results);
    }

    MPI_Finalize();

    return 0;
}
