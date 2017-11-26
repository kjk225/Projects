//
// Created by Kanu Jason Kanu on 10/1/16.
//

#ifndef A5_HAND_H
#define A5_HAND_H

#include "Card.h"
#include "DeckofCards.h"
#include <vector>

class Hand {

public:
    Hand();
    vector<Card> handofCards;
    bool contains_pair();
    bool contains_2pairs();
    bool contains_3ofkind();
    bool contains_4ofkind();
    bool contains_flush();
    bool contains_straight();
};


#endif //A5_HAND_H
