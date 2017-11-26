//
// Created by Kanu Jason Kanu (kjk225) on 10/8/16.
// "Savings" Account inherited from the base class "Account"
//

#ifndef A7_SAVINGS_H
#define A7_SAVINGS_H

#include "Account.h"

class Savings: public Account {
private:
    double interest;

public:
    Savings(double bal, double rate) : Account(bal) {interest = rate/100;}
    double calculateInterest();

};

#endif //A7_SAVINGS_H
