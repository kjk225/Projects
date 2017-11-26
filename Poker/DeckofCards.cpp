//
// Created by Kanu Jason Kanu on 9/29/16.
//

#include "DeckofCards.h"
using namespace std;

DeckofCards::DeckofCards(){
    deck = new Card[52];
    currentCard = 0;
    for(int i = 0; i < 52; i++)
    {
        deck[i] = Card(i % 13, i%4);
    }

}

void DeckofCards::shuffle() {
    random_shuffle(&deck[0], &deck[51]);
}

Card DeckofCards::dealCard() {
    if (moreCards())
        return deck[currentCard++];
    else
        cout << "Out of Cards" << endl;
}

bool DeckofCards::moreCards() {
    if (currentCard < 52) return true;
    cout << "Out of Cards" << endl;
    return false;
}

