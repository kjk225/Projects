// Kanu Kanu (kjk225)
// Assignment 10
// Deitel & Deitel Exercise 14.12, pg 636.

// Given a seven-digit number the program
// writes to a file every possible seven-letter word
// corresponding to that number. There are 2187
// (3 to the seventh power) such words.

// Numbers with the digits 0 and 1 are not allowed

#include <iostream>
#include <fstream>
using namespace std;

int main()
{
    //the 7 digit input from the user
    int phoneNumber;

    //string representations of each number on the keypad
    string two = "ABC";
    string three = "DEF";
    string four = "GHI";
    string five =  "JKL";
    string six =  "MNO";
    string seven =  "PQRS";
    string eight =  "TUV";
    string nine =  "WXYZ";

    //used to store the the strings representations of
    // each digit of the phone number
    string keypad[7];

    cout << "Please enter a your seven digit phone number: ";

    cin >> phoneNumber;

    for (int i = 6; i < 0; i--){

        // if a digit 0 or 1 is in the phonenumber
        // or if there are less than 7 digits in the phonenumber
        // it is invalid
        if (phoneNumber % 10 < 2 ){
            cout << "You entered an invalid number. Please try again." << endl;
            return -1;
        }

        // get each digit of the phonenumber and assign
        // assign it to the corresponding string representation
        switch(phoneNumber % 10){
            case 2: keypad[i] = two;
            case 3: keypad[i] = three;
            case 4: keypad[i] = four;
            case 5: keypad[i] = five;
            case 6: keypad[i] = six;
            case 7: keypad[i] = seven;
            case 8: keypad[i] = eight;
            default: keypad[i]= nine; //case 9
        }
        // update phone number
        phoneNumber /= 10;
    }

    //write output stream to file
    ofstream out("output.dat");

    //checks if outstream is open
    if (!out.is_open()){
        cerr << "Couldn't open output stream" << endl;
        return -1;
    }

    // output all possible combinations
    // sizeof(keypad[i]) is the length of the string + 1
    for ( int i1 = 0; i1 < sizeof(keypad[0])-1 ; i1++ ){
     for ( int i2 = 0; i2 < sizeof(keypad[1]) -1; i2++ ){
         for ( int i3 = 0; i3 < sizeof(keypad[2]) -1; i3++ ){
             for ( int i4 = 0; i4 < sizeof(keypad[3]) -1; i4++ ){
                 for ( int i5 = 0; i5 < sizeof(keypad[4]) -1; i5++ ){
                     for ( int i6 = 0; i6 < sizeof(keypad[5]) -1; i6++ ){
                         for ( int i7 = 0; i7 < sizeof(keypad[6]) -1 ; i7++ ){

                             // writes to a file every possible seven-letter word
                             // corresponding to phoneNumber
                             // keypad[i][j] is the jth charachter of string keypad[i]
                             out << keypad[0][i1] << keypad[1][i2]
                                 << keypad[2][i3] << keypad[3][i4]
                                 << keypad[4][i5] << keypad[5][i6]
                                 << keypad[6][i7] << endl;
                            }
                        }
                    }
                }
            }
        }
    }

    //close stream
    out.close();

    return 0;
}
