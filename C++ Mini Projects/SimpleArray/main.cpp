// CS2024 -- Assignment 8
// kjk225  Kanu Kanu  11/3/2016
//
// Simple Array class:
// -allows for the user to specify the type stored in the array
// -takes a template parameter specifying the size of the array
// -implements operator[] such that a simple exception is thrown
//  if a bad index is specified.

#include <iostream>
using namespace std;

template <typename  T> class SimpleArray{
private:
    int size;
    //user can specify type stored in array
    T *s_array;

public:
    //constructor allows user to specify size of array
    SimpleArray(int s){
        size = s;
        s_array = new T[size];
    }

    T& operator[](int index){
        //if index is less than 0 or greater than size of array it is invalid
        string error = "Invalid Index";
        if (index < 0 || index > size -1){
            throw error;
        }

        //otherwise return specified index
        return s_array[index];
    }

    int getsize() { return size;};
};

int main()
{
    //SimpleArray of type int
    SimpleArray <int> int_array(10);

    //array loaded with ints corresponding to index
    for (int i = 0; i < int_array.getsize() ; ++i) {
        int_array[i] = i;
    }

    int v1 = int_array[0];
    cout << v1 << " is the first valid index in this array" << endl;
    int v2 = int_array[9];
    cout << v2 << " is the last valid index in this array" << endl;

    try{
        int v3 = int_array[10];
        //will not print because exception is thrown
        cout << v3 << " is an invalid index in this array" << endl;
    }
    catch(string &s) {
        cout << "Caught STRING: " << s << endl;
    }

    //SimpleArray of type char
    SimpleArray <char> char_array(6);

    //array loaded with chars from hi array
    char hi[6] = {'H', 'E', 'L', 'L', 'O', '!'};
    for (int i = 0; i < sizeof(hi); ++i) {
        char_array[i] = hi[i];
    }

    cout << char_array[0];
    cout << char_array[1];
    cout << char_array[2];
    cout << char_array[3];
    cout << char_array[4];
    cout << char_array[5] << endl;

    try{
        //out of bounds index will not print. Exception will be thrown
        cout << char_array[6];
    }
    catch(string &s) {
        cout << "Caught STRING: " << s << endl;
    }

    return 0;
}