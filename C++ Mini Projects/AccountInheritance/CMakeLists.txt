cmake_minimum_required(VERSION 3.6)
project(A7_1)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

set(SOURCE_FILES main.cpp Account.cpp Account.h Savings.cpp Savings.h Checking.cpp Checking.h)
add_executable(A7_1 ${SOURCE_FILES})