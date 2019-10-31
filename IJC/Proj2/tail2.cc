//
// Created by Radim Šustek on 05-Apr-18.
// tail2.cc
// reseni: IJC-PROJ2
// Author: Radim Sustek (xsuste11),FIT
// prelozeno gcc 7.2
//

#include <iostream>
#include <fstream>
#include <string.h>

#define MAXLINE 1024
using namespace std;

int main(int argc, char *argv[]) {
    char ch;
    char line[1024];
    int num_lines = 0;
    int num = 0;
    if (argc == 2) {
        ifstream f;
        f.open(argv[1], ios::in);
        if (f.is_open()) {

            while (f.get(ch)) {
                if (ch == '\n') {
                    num_lines++;
                }
            }
            f.clear();
            f.seekg(0);
            if (num_lines <= 10) {
                while(f.getline(line,MAXLINE)){
                    cout << line << endl;
                }
            }
            else {
		num_lines -=10;
                while (f.getline(line,MAXLINE)){
                    if (num >= num_lines) {
                        cout << line << endl;
                    }
                    num++;
                }
            }
            f.close();
        } else {
            cout << "CHYBA: Nepodarilo se otevrit soubor";
            return 1;
        }
    }
    else if (argc == 3)
        if (strcmp(argv[1],"-n") == 0){
            int cislo = atoi(argv[2]);
            while (cin.get(ch)){
                if (ch == '\n') {
                    num_lines++;
                }
            }
            cin.clear();
            cin.seekg(0);
            if (num_lines <= cislo) {
                while(cin.getline(line,MAXLINE)){
                    cout << line << endl;
                }
            }
            else {
                num_lines -=cislo;
                while (cin.getline(line,MAXLINE)){
                    if (num >= num_lines) {
                        cout << line << endl;
                    }
                    num++;
                }
            }
        }
    return 0;
}
