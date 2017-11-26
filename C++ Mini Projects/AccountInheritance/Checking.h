//
// Created by Kanu Jason Kanu (kjk225) on 10/8/16.
// "Checking" Account inherited from the base class "Account"
//

#ifndef A7_CHECKING_H
#define A7_CHECKING_H

#include "Account.h"

class Checking : public Account {
private:
    double fee;

public:
    Checking(double bal, double feerate) : Account(bal) { fee = feerate/100; }
    void credit(double amount);
    bool debit(double amount);

};

#endif //A7_CHECKING_H
