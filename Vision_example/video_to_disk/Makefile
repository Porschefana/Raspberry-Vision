SRCS=$(wildcard *.cpp)
OBJS=$(SRCS:.cpp=.o)
DEPS=$(SRCS:.cpp=.d)
BINS=$(SRCS:.cpp=)
SCRIPTS=$(SRCS:.cpp=.sh)

WPILIB_ROOT_DIR=/usr/local/wpilib
WPILIB_INC_DIR=$(WPILIB_ROOT_DIR)/include

OPENCV_LIB_DIR=/usr/local/lib
WPIUTIL_INC_DIR=$(WPILIB_INC_DIR)/wpiutil
CSCORE_INC_DIR=$(WPILIB_INC_DIR)/cscore
NTCORE_INC_DIR=$(WPILIB_INC_DIR)/ntcore
WPILIB_LIB_DIR=$(WPILIB_ROOT_DIR)/lib

CXX=g++
CXXFLAGS=-I$(NTCORE_INC_DIR) -I$(WPIUTIL_INC_DIR) -I$(CSCORE_INC_DIR) -O0 -g3 -Wall  -fmessage-length=0 -std=c++11 -g -rdynamic -MMD
LDFLAGS=-L$(WPILIB_LIB_DIR) -L$(OPENCV_LIB_DIR) -lcscore -lwpiutil -lopencv_core -lopencv_videoio -lrt -lpthread

all: $(BINS)

$(BINS): $(OBJS)
	g++ $< -o $@ $(CXXFLAGS) $(LDFLAGS) 

.PHONY: clean run

clean:
	$(RM) $(OBJS) $(DEPS) $(BINS)

run:
	./$(SCRIPTS)
