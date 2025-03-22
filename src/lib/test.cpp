#include <iostream>
#include "recomp_lib_api.hpp"

RECOMP_EXPORT extern "C" uint32_t recomp_api_version = RECOMP_API_VERSION;

RECOMP_DLL_FUNC(test_func) {
    std::cout << "Sanity Check Passed\n";
}

