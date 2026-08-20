#include <jni.h>
#include <android/log.h>
#include <signal.h>
#include <unistd.h>
#include <cstring>
#include <unwind.h>
#include <dlfcn.h>

#define CRASH_TAG "KOPRI_CRASH"

static struct sigaction old_sigsegv;
static struct sigaction old_sigabrt;
static struct sigaction old_sigbus;
static struct sigaction old_sigfpe;
static struct sigaction old_sigill;

struct BacktraceState {
    void** current;
    void** end;
};

static _Unwind_Reason_Code unwind_callback(struct _Unwind_Context* context, void* arg) {
    BacktraceState* state = static_cast<BacktraceState*>(arg);
    uintptr_t pc = _Unwind_GetIP(context);
    if (pc) {
        if (state->current == state->end) {
            return _URC_END_OF_STACK;
        }
        *state->current++ = reinterpret_cast<void*>(pc);
    }
    return _URC_NO_REASON;
}

static void dump_backtrace() {
    const int MAX_FRAMES = 64;
    void* buffer[MAX_FRAMES];
    BacktraceState state = {buffer, buffer + MAX_FRAMES};

    _Unwind_Backtrace(unwind_callback, &state);

    int frame_count = static_cast<int>(state.current - buffer);

    __android_log_print(ANDROID_LOG_FATAL, CRASH_TAG,
                        "=== NATIVE CRASH BACKTRACE (%d frames) ===", frame_count);

    for (int i = 0; i < frame_count; ++i) {
        const void* addr = buffer[i];
        Dl_info info;

        if (dladdr(addr, &info) && info.dli_sname) {
            unsigned long offset = (unsigned long)(
                    (char*)addr - (char*)info.dli_saddr
            );
            __android_log_print(ANDROID_LOG_FATAL, CRASH_TAG,
                                "  #%02d pc %p  %s + 0x%lx  (%s)",
                                i, addr,
                                info.dli_sname,
                                offset,
                                info.dli_fname ? info.dli_fname : "?");
        } else {
            __android_log_print(ANDROID_LOG_FATAL, CRASH_TAG,
                                "  #%02d pc %p", i, addr);
        }
    }

    __android_log_print(ANDROID_LOG_FATAL, CRASH_TAG,
                        "=== END BACKTRACE ===");
}

static void crash_handler(int sig, siginfo_t* info, void* context) {
    const char* name = "UNKNOWN";
    switch (sig) {
        case SIGSEGV: name = "SIGSEGV (segfault)"; break;
        case SIGABRT: name = "SIGABRT (abort)"; break;
        case SIGBUS:  name = "SIGBUS (bus error)"; break;
        case SIGFPE:  name = "SIGFPE (float error)"; break;
        case SIGILL:  name = "SIGILL (illegal instruction)"; break;
    }

    __android_log_print(ANDROID_LOG_FATAL, CRASH_TAG,
                        "!!! NATIVE CRASH DETECTED !!!");
    __android_log_print(ANDROID_LOG_FATAL, CRASH_TAG,
                        "  Signal:  %d (%s)", sig, name);
    __android_log_print(ANDROID_LOG_FATAL, CRASH_TAG,
                        "  Address: %p", info ? info->si_addr : nullptr);
    __android_log_print(ANDROID_LOG_FATAL, CRASH_TAG,
                        "  PID:     %d", (int)getpid());
    __android_log_print(ANDROID_LOG_FATAL, CRASH_TAG,
                        "  TID:     %d", (int)gettid());
    if (info) {
        __android_log_print(ANDROID_LOG_FATAL, CRASH_TAG,
                            "  si_code: %d", info->si_code);
    }

    dump_backtrace();
    struct sigaction* old = nullptr;
    switch (sig) {
        case SIGSEGV: old = &old_sigsegv; break;
        case SIGABRT: old = &old_sigabrt; break;
        case SIGBUS:  old = &old_sigbus;  break;
        case SIGFPE:  old = &old_sigfpe;  break;
        case SIGILL:  old = &old_sigill;  break;
    }

    if (old && old->sa_sigaction) {
        old->sa_sigaction(sig, info, context);
    } else if (old && old->sa_handler != SIG_DFL && old->sa_handler != SIG_IGN) {
        old->sa_handler(sig);
    } else {
        signal(sig, SIG_DFL);
        raise(sig);
    }
}

extern "C" JNIEXPORT void JNICALL
Java_com_kopri_translator_CrashHandler_nativeInit(JNIEnv*, jobject) {
    struct sigaction sa;
    std::memset(&sa, 0, sizeof(sa));
    sigemptyset(&sa.sa_mask);
    sa.sa_sigaction = crash_handler;
    sa.sa_flags = SA_SIGINFO | SA_ONSTACK;

    sigaction(SIGSEGV, &sa, &old_sigsegv);
    sigaction(SIGABRT, &sa, &old_sigabrt);
    sigaction(SIGBUS,  &sa, &old_sigbus);
    sigaction(SIGFPE,  &sa, &old_sigfpe);
    sigaction(SIGILL,  &sa, &old_sigill);

    __android_log_print(ANDROID_LOG_INFO, CRASH_TAG,
                        "✅ Native crash handler installed for pid=%d",
                        (int)getpid());
    __android_log_print(ANDROID_LOG_INFO, CRASH_TAG,
                        "   Catching: SIGSEGV, SIGABRT, SIGBUS, SIGFPE, SIGILL");
}