# Sanitize BUILD_HOME
BUILD_HOME := $(shell cd $(BUILD_HOME); pwd)

$(info Using BUILD_HOME=${BUILD_HOME})

# Compilers
CPP = g++
LD = ${CPP}

# Compiler flags
CXXFLAGS = -g -Wall -pedantic -O3 -MMD -MP -fPIC
#						-fprofile-arcs -ftest-coverages
LDFLAGS = -Wall -g -O3 -fPIC
#										 -lgcov -coverage

# Tools
MakeDir = mkdir -p


PYTHON_VERSION ?= $(shell python -c "import distutils.sysconfig; print(distutils.sysconfig.get_python_version())")
PYTHON_INCLUDE_PREFIX ?= $(shell python -c "import distutils.sysconfig; print(distutils.sysconfig.get_python_inc())")
PYTHON_LIB_PREFIX ?= $(shell python -c "from distutils.sysconfig import get_python_lib; import os.path; print(os.path.split(get_python_lib(standard_lib=True))[0])")

# Construct C++ compiler suffix for RPM release field (tested with clang & gcc)
CPP_VERSION_TAG = $(word 1, $(shell ${CPP} --version))
CPP_VERSION_TAG := $(subst g++,gcc,${CPP_VERSION_TAG})
CPP_VERSION_TAG := ${CPP_VERSION_TAG}$(shell ${CPP} -dumpfullversion -dumpversion)
CPP_VERSION_TAG := $(subst .,_,${CPP_VERSION_TAG})


ifneq (,$(wildcard ${EXTERN_BOOST_LIB_PREFIX}/libboost_thread-mt.so ${EXTERN_BOOST_LIB_PREFIX}/libboost_thread-mt.dylib))
  BOOST_THREAD_LIB = boost_thread-mt
else ifneq (,$(wildcard ${EXTERN_BOOST_LIB_PREFIX}/libboost_thread.so ${EXTERN_BOOST_LIB_PREFIX}/libboost_thread.dylib))
  BOOST_THREAD_LIB = boost_thread
else ifeq (,$(shell LANG=C ${CPP} -lboost_thread-mt 2>&1 | grep -E 'ld: (cannot find|library not found)'))
  BOOST_THREAD_LIB = boost_thread-mt
else
  BOOST_THREAD_LIB = boost_thread
endif
