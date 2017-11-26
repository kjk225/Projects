cmake_minimum_required(VERSION 3.6)
project(A5)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

set(SOURCE_FILES main.cpp Card.cpp Card.h DeckofCards.cpp DeckofCards.h Hand.cpp Hand.h)
add_executable(A5 ${SOURCE_FILES})