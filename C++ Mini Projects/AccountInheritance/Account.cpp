//
// Created by Kanu Jason Kanu (kjk225) on 10/8/16.
// Base class "Account" implementation
//

#include "Account.h"
#include <iostream>
using namespace std;

Account::Account(double bal) {
    if (bal >= 0) balance = bal;
    else {
        balance = 0;
        cout << "Invalid balance. Please re-enter." << endl;
    }
}

void Account::credit(double amount) {
    balance = balance + amount;
}

bool Account::debit(double amount) {
    if (amount > balance){
        cout << "Debit amount exceeded account balance." << endl;
        return false;
    }
    else{
        balance = balance - amount;
        return true;
    }
}
