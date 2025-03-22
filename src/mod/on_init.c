#include "modding.h"
#include "global.h"
#include "recomputils.h"
#include "recompconfig.h"
#include "recompui.h"
#include "z64recomp_api.h"

RECOMP_IMPORT(".", void test_func());

RECOMP_CALLBACK("*", recomp_on_init) void load_lib () {
    test_func();
}