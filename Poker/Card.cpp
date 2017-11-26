//
// Created by Kanu Jason Kanu on 9/29/16.
//

#include "Card.h"
using namespace std;

Card::Card(){

}
Card::Card(int face, int suit):
            face(face), suit(suit) {}

string Card::facearray[] = {"Ace", "2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King"};
string Card::suitarray[] = {"Hearts", "Diamonds", "Clubs", "Spades"};


string Card::toString() {

    string cardname = facearray[face] + " of " + suitarray[suit];
    return cardname;
}


