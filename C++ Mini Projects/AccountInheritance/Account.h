//
// Created by Kanu Jason Kanu (Kjk225) on 10/8/16.
// Base class "Account" interface
//

#ifndef A7_ACCOUNT_H
#define A7_ACCOUNT_H


class Account {

protected:
    //only available to inherited classes
    double balance;
public:
    Account(double bal);
    //can be overrided by inherited functions
    virtual void credit(double amount);
    virtual bool debit(double amount);

    //used to get the balance of the account
    double getbal() { return balance;}

};


#endif //A7_ACCOUNT_H
