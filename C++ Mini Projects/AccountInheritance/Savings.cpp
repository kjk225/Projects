//
// Created by Kanu Jason Kanu (kjk225) on 10/8/16.
// "Savings" Account implementation
//

#include "Savings.h"

double Savings::calculateInterest() {
    double earned = balance * interest;
    return earned;
}