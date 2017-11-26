//
// Created by Kanu Jason Kanu on 10/1/16.
//

#include "Hand.h"
using namespace std;

int pairs = 0;
bool threeofkind;
bool fourofkind;
int *numfaces = new int[13];

Hand::Hand() {

    for (int i = 0; i < handofCards.size() ; i++) {
        numfaces[(handofCards[i].face)]++;
    }

    for (int j = 0; j < 13; j++){
        switch (numfaces[j]){
            case 2:
                pairs++;
                break;
            case 3:
                threeofkind = true;
                break;
            case 4:
                fourofkind = true;
                break;

            default:
                break;

        }
    }

}

bool Hand::contains_pair() {
    return (pairs >= 2);
}

bool Hand::contains_2pairs() {
    return (pairs == 2);
}

bool Hand::contains_3ofkind() {
    return threeofkind;
}

bool Hand::contains_4ofkind() {
    return fourofkind;
}

bool Hand::contains_flush() {
    return (handofCards[0].suit == handofCards[1].suit &&
            handofCards[1].suit == handofCards[2].suit &&
            handofCards[2].suit == handofCards[3].suit &&
            handofCards[3].suit == handofCards[4].suit &&
            handofCards[4].suit == handofCards[5].suit);
}

bool Hand::contains_straight() {
    for (int j = 0; j < sizeof(numfaces) - 4; j++) {
        if (numfaces[j] == 1 &&
            numfaces[j + 1] == 1 &&
            numfaces[j + 2] == 1 &&
            numfaces[j + 3] == 1 &&
            numfaces[j + 4] == 1) {
            return true;
        }
    }
    return false;
}