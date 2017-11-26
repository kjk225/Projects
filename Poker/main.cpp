#include <iostream>
#include <vector>
#include "DeckofCards.h"
#include "Card.h"
#include "Hand.h"
using namespace std;


int main() {
    cout << "Start the poker match" << endl;
    DeckofCards deck = DeckofCards();
    deck.shuffle();

    Hand newHand = Hand();

    newHand.handofCards.push_back(deck.dealCard());
    newHand.handofCards.push_back(deck.dealCard());
    newHand.handofCards.push_back(deck.dealCard());
    newHand.handofCards.push_back(deck.dealCard());
    newHand.handofCards.push_back(deck.dealCard());

    if (newHand.contains_pair()) cout << "You have a pair!" << endl;
    if (newHand.contains_2pairs()) cout << "You have 2 pairs!" << endl;
    if (newHand.contains_3ofkind()) cout << "You have 3 of a kind!" << endl;
    if (newHand.contains_4ofkind()) cout << "You have 4 of a kind!" << endl;
    if (newHand.contains_flush()) cout << "You have a royal flush!" << endl;
    if (newHand.contains_straight()) cout << "You have a straight!" << endl;

}