// Reproduction + regression test for K-pri#12:
// detect_script() never returns "tk" because the Turkmen letter check
// lives inside the ASCII branch.
#include "translate_engine.h"
#include <iostream>

static int fails = 0;
static void chk(const std::string& t, const std::string& want) {
    const std::string got = kt::detect_script(t);
    const bool ok = got == want;
    if (!ok) ++fails;
    std::cout << (ok ? "ok  " : "FAIL") << "  detect_script(\"" << t << "\") = " << got
                << " (want " << want << ")\n";
}

int main() {
    // The reporter's exact cases
    chk("Salam", "lat");              // plain Latin, no Turkmen letters
    chk("\u00fd\u00e4\u0161", "tk");  // "yash" (Turkmen)
    chk("Meni\u0148 adym", "tk");     // "Meni\u00f7 adym"
    chk("n\u00e4hili", "tk");         // "nahili" with a-grave

    // Pure Cyrillic still wins
    chk("\u041f\u0440\u0438\u0432\u0435\u0442", "cyr"); // "Privet"
    // Arabic
    chk("\u0628\u0633\u0645\u0627", "ara");
    // Mixed Latin + Turkmen letters -> tk
    chk("Salam, \u00e4li g\u00f6r\u0161\u00fcm", "tk");
    // Empty -> default lat
    chk("", "lat");

    std::cout << (fails == 0 ? "ALL PASS\n" : "FAILURES\n");
    return fails == 0 ? 0 : 1;
}
