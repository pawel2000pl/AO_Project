clear; close all; clc;
fileName = input("Wpisz plik do przetworzenia: ");
im = imread(fileName);
letters = FindLetterImages(im);

!python3 letter_classification/app.py letter_classification/enhanced-custom-dataset-model.h5 &

client(letters)