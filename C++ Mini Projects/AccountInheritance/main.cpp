#include <iostream>
#include "Account.h"
#include "Checking.h"
#include "Savings.h"
using namespace std;

// CS2024 -- Assignment 7
// kjk225  Kanu Kanu  10/16/2016
// Exercise 11.10, Deitel & Deitel's "C++ How to Program"
//
// All customers at this bank can deposit (i.e., credit) money into their
// accounts and withdraw (i.e., debit) money from their accounts.
// Savings accounts, for instance, earn interest on the money they hold.
// Checking accounts, on the other hand, charge a fee per transaction (i.e., credit or debit).

int main() {

    //Instances of all three classes
    Account *myAccount = new Account(2000);
    Savings *mysAccount = new Savings(100, 10);
    Checking *mycAccount = new Checking(1000, 5);

    //Tests
    cout << "Before interest credit, savings balance is: " << (*mysAccount).getbal() << endl;
    double interest_earned = (*mysAccount).calculateInterest();
    (*mysAccount).credit(interest_earned);
    cout << "After interest credit, savings balance is: " << (*mysAccount).getbal() << endl << endl;

    cout << "(2)Before debit, savings balance is: " << (*mysAccount).getbal() << endl;
    (*mysAccount).debit(1000);
    cout << "(2)After debit, savings balance is: " << (*mysAccount).getbal() << endl << endl;

    cout << "Before debit, checking balance is: " << (*mycAccount).getbal() << endl;
    (*mycAccount).debit(1000);
    cout << "After debit, checking balance is: " << (*mycAccount).getbal() << endl << endl;

    cout << "Before credit, checking balance is: " << (*mycAccount).getbal() << endl;
    (*mycAccount).credit(1000);
    cout << "After credit, checking balance is: " << (*mycAccount).getbal() << endl << endl;



}