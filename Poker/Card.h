//
// Created by Kanu Jason Kanu on 9/29/16.
//

#include <iostream>
using namespace std;

#ifndef A5_CARD_H
#define A5_CARD_H


class Card {

public:
    int face;
    int suit;

    Card();
    Card(int face, int suit);

    string toString();

    static string facearray[];
    static string suitarray[];

    friend class DeckofCards;
    friend class Hand;

};


#endif //A5_CARD_H
