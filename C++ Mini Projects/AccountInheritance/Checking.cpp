//
// Created by Kanu Jason Kanu (kjk225) on 10/8/16.
// Inherited "Checking" Account implementation
//

#include "Checking.h"
#include <iostream>
using namespace std;

void Checking ::credit(double amount) {
    Account::credit(amount);
    balance = balance - (amount * fee);
}

bool Checking ::debit(double amount) {
    if (Account::debit(amount)){
        balance = balance - (amount * fee);
        return true;
    }
    else {
        return false;

    }
}
