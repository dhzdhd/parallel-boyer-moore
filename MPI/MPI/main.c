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

int presentInArray(int *arr, int size, int val) {
    for (int i = 0; i < size; i++) {
        if (arr[i] == val) {
            return 1;
        }
    }
    return 0;
}

int main(int argc, char** argv) {
    const char* text = "AABAACAADAABAABAAABABKJAHDKAHSJDKJFHKSHHAHDGFJGHJKJSDLKJSDKHAKHFSPJSFKJSDHKLSDJHAKJHSKSJHDSHBAABAABA";
    const char* pattern = "BAA";

    int rank, size;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    double start = MPI_Wtime();

    int textLength = strlen(text);
    int patternLength = strlen(pattern);
    int* results = (int*)malloc(textLength * sizeof(int));
    int* buf = (int*)malloc(textLength * size * sizeof(int));

    for (int i = 0; i < textLength; i++) {
        results[i] = 0;
        
    }
    for (int i = 0; i < textLength * textLength; i++) {
        buf[i] = 0;
    }

    boyerMoore(rank, text, textLength, pattern, patternLength, results);

    MPI_Barrier(MPI_COMM_WORLD);
    MPI_Gather(results, textLength, MPI_INT, buf, textLength, MPI_INT, 0, MPI_COMM_WORLD);

    double end = MPI_Wtime();

    MPI_Finalize();

    if (rank == 0) {       
        int indices[100], ctr = 0;
        for (int i = 0; i < textLength * size; i++) {
            if (buf[i] == 1) {
                if (presentInArray(indices, ctr, i % textLength) == 0) {
                    indices[ctr++] = i % textLength;
                }
            }
        }

        printf("Pattern found at positions: ");
        for (int i = 0; i < ctr; i++) {
            printf("%d ", indices[i]);
        } 
        printf("\n");

        printf("Time taken: %g\n", end - start);
    }
   
    return 0;
}
