//
// Created by Kanu Jason Kanu on 9/29/16.
//

#ifndef A5_DECKOFCARDS_H
#define A5_DECKOFCARDS_H

#include "Card.h"

class DeckofCards {

public:
    Card *deck;
    int currentCard;

    DeckofCards();
    void shuffle();
    Card dealCard();
    bool moreCards();

    friend class Hand;
};


#endif //A5_DECKOFCARDS_H
