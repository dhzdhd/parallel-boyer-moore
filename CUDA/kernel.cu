﻿#include <cuda_runtime.h>
#include <stdio.h>
#include<string.h>
#include<time.h>
#define ALPHABET_SIZE 256

__device__ void precomputeBadCharacterShift(const char* pattern, int patternLength, int* badCharacterShift) {
    for (int i = 0; i < ALPHABET_SIZE; i++) {
        badCharacterShift[i] = patternLength;
    }
    for (int i = 0; i < patternLength - 1; i++) {
        badCharacterShift[(int)pattern[i]] = patternLength - i - 1;
    }
}

__global__ void boyerMoore(const char* text, int textLength, const char* pattern, int patternLength, int* results) {
    int tid = blockIdx.x * blockDim.x + threadIdx.x;

    if (tid < textLength - patternLength + 1) {
        int badCharacterShift[ALPHABET_SIZE];
        precomputeBadCharacterShift(pattern, patternLength, badCharacterShift);

        int skip = 0;
        while (skip <= textLength - patternLength) {
            int j = patternLength - 1;
            while (j >= 0 && pattern[j] == text[tid + j]) {
                j--;
            }
            if (j < 0) {
                results[tid] = 1; // Match found
                return;
            }
            else {
                int badCharIndex = (int)text[tid + j];
                skip += badCharacterShift[badCharIndex];
            }
            tid += skip;
        }
    }
}

void cudaBoyerMoore(const char* text, int textLength, const char* pattern, int patternLength, int* results) {
    char* d_text;
    char* d_pattern;
    int* d_results;
    
    cudaMalloc((void**)&d_text, textLength * sizeof(char));
    cudaMalloc((void**)&d_pattern, patternLength * sizeof(char));
    cudaMalloc((void**)&d_results, textLength * sizeof(int));

    cudaMemcpy(d_text, text, textLength * sizeof(char), cudaMemcpyHostToDevice);
    cudaMemcpy(d_pattern, pattern, patternLength * sizeof(char), cudaMemcpyHostToDevice);

    int blockSize = 256;
    int numBlocks = (textLength + blockSize - 1) / blockSize;

    boyerMoore << <numBlocks, blockSize >> > (d_text, textLength, d_pattern, patternLength, d_results);

    cudaMemcpy(results, d_results, textLength * sizeof(int), cudaMemcpyDeviceToHost);

    cudaFree(d_text);
    cudaFree(d_pattern);
    cudaFree(d_results);
}

int main() {
    const char* text = "AABAACAADAABAABAAABABKJAHDKAHSJDKJFHKSHHAHDGFJGHJKJSDLKJSDKHAKHFSPJSFKJSDHKLSDJHAKJHSKSJHDSHBAABAABAABAABAABABAABAABAABAABBABBAAABAAAAABAACAADAABAABAAABABKJAHDKAHSJDKJFHKSHHAHDGFJGHJKJSDLKJSDKHAKHFSPJSFKJSDHKLSDJHAKJHSKSJHDSHBAABAABAABAABAABABAABAABAABAABBABBAAABAAAAABAACAADAABAABAAABABKJAHDKAHSJDKJFHKSHHAHDGFJGHJKJSDLKJSDKHAKHFSPJSFKJSDHKLSDJHAKJHSKSJHDSHBAABAABAABAABAABABAABAABAABAABBABBAAABAAAAABAACAADAABAABAAABABKJAHDKAHSJDKJFHKSHHAHDGFJGHJKJSDLKJSDKHAKHFSPJSFKJSDHKLSDJHAKJHSKSJHDSHBAABAABAABAABAABABAABAABAABAABBABBAAABAAAAABAACAADAABAABAAABABKJAHDKAHSJDKJFHKSHHAHDGFJGHJKJSDLKJSDKHAKHFSPJSFKJSDHKLSDJHAKJHSKSJHDSHBAABAABAABAABAABABAABAABAABAABBABBAAABAAAAABAACAADAABAABAAABABKJAHDKAHSJDKJFHKSHHAHDGFJGHJKJSDLKJSDKHAKHFSPJSFKJSDHKLSDJHAKJHSKSJHDSHBAABAABAABAABAABABAABAABAABAABBABBAAABAAAAABAACAADAABAABAAABABKJAHDKAHSJDKJFHKSHHAHDGFJGHJKJSDLKJSDKHAKHFSPJSFKJSDHKLSDJHAKJHSKSJHDSHBAABAABAABAABAABABAABAABAABAABBABBAAABAAAAABAACAADAABAABAAABABKJAHDKAHSJDKJFHKSHHAHDGFJGHJKJSDLKJSDKHAKHFSPJSFKJSDHKLSDJHAKJHSKSJHDSHBAABAABAABAABAABABAABAABAABAABBABBAAABAAAAABAACAADAABAABAAABABKJAHDKAHSJDKJFHKSHHAHDGFJGHJKJSDLKJSDKHAKHFSPJSFKJSDHKLSDJHAKJHSKSJHDSHBAABAABAABAABAABABAABAABAABAABBABBAAABAAAAABAACAADAABAABAAABABKJAHDKAHSJDKJFHKSHHAHDGFJGHJKJSDLKJSDKHAKHFSPJSFKJSDHKLSDJHAKJHSKSJHDSHBAABAABAABAABAABABAABAABAABAABBABBAAABAAAAABAACAADAABAABAAABABKJAHDKAHSJDKJFHKSHHAHDGFJGHJKJSDLKJSDKHAKHFSPJSFKJSDHKLSDJHAKJHSKSJHDSHBAABAABAABAABAABABAABAABAABAABBABBAAABAAAAABAACAADAABAABAAABABKJAHDKAHSJDKJFHKSHHAHDGFJGHJKJSDLKJSDKHAKHFSPJSFKJSDHKLSDJHAKJHSKSJHDSHBAABAABAABAABAABABAABAABAABAABBABBAAABAAAAABAACAADAABAABAAABABKJAHDKAHSJDKJFHKSHHAHDGFJGHJKJSDLKJSDKHAKHFSPJSFKJSDHKLSDJHAKJHSKSJHDSHBAABAABAABAABAABABAABAABAABAABBABBAAABAAAAABAACAADAABAABAAABABKJAHDKAHSJDKJFHKSHHAHDGFJGHJKJSDLKJSDKHAKHFSPJSFKJSDHKLSDJHAKJHSKSJHDSHBAABAABAABAABAABABAABAABAABAABBABBAAABAAAAABAACAADAABAABAAABABKJAHDKAHSJDKJFHKSHHAHDGFJGHJKJSDLKJSDKHAKHFSPJSFKJSDHKLSDJHAKJHSKSJHDSHBAABAABAABAABAABABAABAABAABAABBABBAAABAAAAABAACAADAABAABAAABABKJAHDKAHSJDKJFHKSHHAHDGFJGHJKJSDLKJSDKHAKHFSPJSFKJSDHKLSDJHAKJHSKSJHDSHBAABAABAABAABAABABAABAABAABAABBABBAAABAAAAABAACAADAABAABAAABABKJAHDKAHSJDKJFHKSHHAHDGFJGHJKJSDLKJSDKHAKHFSPJSFKJSDHKLSDJHAKJHSKSJHDSHBAABAABAABAABAABABAABAABAABAABBABBAAABAAAAABAACAADAABAABAAABABKJAHDKAHSJDKJFHKSHHAHDGFJGHJKJSDLKJSDKHAKHFSPJSFKJSDHKLSDJHAKJHSKSJHDSHBAABAABAABAABAABABAABAABAABAABBABBAAABAAAAABAACAADAABAABAAABABKJAHDKAHSJDKJFHKSHHAHDGFJGHJKJSDLKJSDKHAKHFSPJSFKJSDHKLSDJHAKJHSKSJHDSHBAABAABAABAABAABABAABAABAABAABBABBAAABAAAAABAACAADAABAABAAABABKJAHDKAHSJDKJFHKSHHAHDGFJGHJKJSDLKJSDKHAKHFSPJSFKJSDHKLSDJHAKJHSKSJHDSHBAABAABAABAABAABABAABAABAABAABBABBAAABAAAAABAACAADAABAABAAABABKJAHDKAHSJDKJFHKSHHAHDGFJGHJKJSDLKJSDKHAKHFSPJSFKJSDHKLSDJHAKJHSKSJHDSHBAABAABAABAABAABABAABAABAABAABBABBAAABAAAAABAACAADAABAABAAABABKJAHDKAHSJDKJFHKSHHAHDGFJGHJKJSDLKJSDKHAKHFSPJSFKJSDHKLSDJHAKJHSKSJHDSHBAABAABAABAABAABABAABAABAABAABBABBAAABAAAAABAACAADAABAABAAABABKJAHDKAHSJDKJFHKSHHAHDGFJGHJKJSDLKJSDKHAKHFSPJSFKJSDHKLSDJHAKJHSKSJHDSHBAABAABAABAABAABABAABAABAABAABBABBAAABAAACAADAABAABAAABABKJAHDKAHSJDKJFHKSHHAHDGFJGHJKJSDLKJSDKHAKHFSPJSFKJSDHKLSDJHAKJHSKSJHDSHBAABAABAABAABAABABAABAABAABAABBABBAAABAAACAADAABAABAAABABKJAHDKAHSJDKJFHKSHHAHDGFJGHJKJSDLKJSDKHAKHFSPJSFKJSDHKLSDJHAKJHSKSJHDSHBAABAABAABAABAABABAABAABAABAABBABBAAABAAACAADAABAABAAABABKJAHDKAHSJDKJFHKSHHAHDGFJGHJKJSDLKJSDKHAKHFSPJSFKJSDHKLSDJHAKJHSKSJHDSHBAABAABAABAABAABABAABAABAABAABBABBAAABAAA";
    const char* pattern = "BAA";
    float start = clock();
    int textLength = strlen(text);
    int patternLength = strlen(pattern);
    int* results = (int*)malloc(textLength * sizeof(int));

    cudaBoyerMoore(text, textLength, pattern, patternLength, results);

    printf("Pattern found at positions: ");
    for (int i = 0; i < textLength; i++) {
        if (results[i] == 1) {
            printf("%d ", i);
        }
    }
    printf("\n");
    free(results);
    float end = clock();
    printf("Time used : %f", (end - start)/CLOCKS_PER_SEC);

    return 0;
}