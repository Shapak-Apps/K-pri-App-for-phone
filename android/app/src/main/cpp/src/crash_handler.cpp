#include <jni.h>
#include <android/log.h>
#include <signal.h>
#include <unistd.h>
#include <sys/syscall.h>
#include <pthread.h>
#include <cstring>
#include <cstdio>
#include <cstdlib>
#include <atomic>
#include <unwind.h>
#include <dlfcn.h>
#include <ucontext.h>

#define CRASH_TAG "KOPRI_CRASH"

// Global old signal handlers
static struct sigaction old_sigsegv;
static struct sigaction old_sigabrt;
static struct sigaction old_sigbus;
static struct sigaction old_sigfpe;
static struct sigaction old_sigill;

// Anti-recursion flag
static volatile sig_atomic_t g_in_handler = 0;

// Guard against multiple installations
static std::atomic<bool> g_handler_installed{false};

// Safe gettid implementation
static pid_t safe_gettid() {
    return static_cast<pid_t>(syscall(SYS_gettid));
}

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

[[gnu::cold]] static void dump_backtrace() {
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
        std::memset(&info, 0, sizeof(info));

        if (dladdr(addr, &info)) {
            if (info.dli_sname && info.dli_saddr) {
                unsigned long offset = (unsigned long)((uintptr_t)addr - (uintptr_t)info.dli_saddr);
                __android_log_print(ANDROID_LOG_FATAL, CRASH_TAG,
                                    " #%02d pc %p %s + 0x%lx (%s)",
                                    i, addr, info.dli_sname, offset,
                                    info.dli_fname ? info.dli_fname : "?");
            } else {
                __android_log_print(ANDROID_LOG_FATAL, CRASH_TAG,
                                    " #%02d pc %p (%s)",
                                    i, addr, info.dli_fname ? info.dli_fname : "?");
            }
        } else {
            __android_log_print(ANDROID_LOG_FATAL, CRASH_TAG, " #%02d pc %p", i, addr);
        }
    }
    __android_log_print(ANDROID_LOG_FATAL, CRASH_TAG, "=== END BACKTRACE ===");
}

[[gnu::const]] static const char* signal_name(int sig) noexcept {
    switch (sig) {
        case SIGSEGV: return "SIGSEGV (segfault)";
        case SIGABRT: return "SIGABRT (abort)";
        case SIGBUS: return "SIGBUS (bus error)";
        case SIGFPE: return "SIGFPE (float error)";
        case SIGILL: return "SIGILL (illegal instruction)";
    }
    return "UNKNOWN";
}

[[gnu::cold]] static void dump_registers(void* context) {
    if (!context) return;

    ucontext_t* uc = static_cast<ucontext_t*>(context);

#if defined(__aarch64__)
    __android_log_print(ANDROID_LOG_FATAL, CRASH_TAG, " Registers (AArch64):");
    __android_log_print(ANDROID_LOG_FATAL, CRASH_TAG,
                        "  PC: 0x%lx  LR: 0x%lx  SP: 0x%lx",
                        (unsigned long)uc->uc_mcontext.pc,
                        (unsigned long)uc->uc_mcontext.regs[30],
                        (unsigned long)uc->uc_mcontext.sp);
    __android_log_print(ANDROID_LOG_FATAL, CRASH_TAG,
                        "  x0: 0x%lx  x1: 0x%lx  x2: 0x%lx  x3: 0x%lx",
                        (unsigned long)uc->uc_mcontext.regs[0],
                        (unsigned long)uc->uc_mcontext.regs[1],
                        (unsigned long)uc->uc_mcontext.regs[2],
                        (unsigned long)uc->uc_mcontext.regs[3]);
#elif defined(__arm__)
    __android_log_print(ANDROID_LOG_FATAL, CRASH_TAG, " Registers (ARM32):");
    __android_log_print(ANDROID_LOG_FATAL, CRASH_TAG,
        "  PC: 0x%lx  LR: 0x%lx  SP: 0x%lx",
        (unsigned long)uc->uc_mcontext.arm_pc,
        (unsigned long)uc->uc_mcontext.arm_lr,
        (unsigned long)uc->uc_mcontext.arm_sp);
    __android_log_print(ANDROID_LOG_FATAL, CRASH_TAG,
        "  r0: 0x%lx  r1: 0x%lx  r2: 0x%lx  r3: 0x%lx",
        (unsigned long)uc->uc_mcontext.arm_r0,
        (unsigned long)uc->uc_mcontext.arm_r1,
        (unsigned long)uc->uc_mcontext.arm_r2,
        (unsigned long)uc->uc_mcontext.arm_r3);
#elif defined(__x86_64__)
    __android_log_print(ANDROID_LOG_FATAL, CRASH_TAG, " Registers (x86_64):");
    __android_log_print(ANDROID_LOG_FATAL, CRASH_TAG,
        "  RIP: 0x%lx  RSP: 0x%lx  RBP: 0x%lx",
        (unsigned long)uc->uc_mcontext.gregs[REG_RIP],
        (unsigned long)uc->uc_mcontext.gregs[REG_RSP],
        (unsigned long)uc->uc_mcontext.gregs[REG_RBP]);
    __android_log_print(ANDROID_LOG_FATAL, CRASH_TAG,
        "  RAX: 0x%lx  RBX: 0x%lx  RCX: 0x%lx  RDX: 0x%lx",
        (unsigned long)uc->uc_mcontext.gregs[REG_RAX],
        (unsigned long)uc->uc_mcontext.gregs[REG_RBX],
        (unsigned long)uc->uc_mcontext.gregs[REG_RCX],
        (unsigned long)uc->uc_mcontext.gregs[REG_RDX]);
#elif defined(__i386__)
    __android_log_print(ANDROID_LOG_FATAL, CRASH_TAG, " Registers (x86):");
    __android_log_print(ANDROID_LOG_FATAL, CRASH_TAG,
        "  EIP: 0x%lx  ESP: 0x%lx  EBP: 0x%lx",
        (unsigned long)uc->uc_mcontext.gregs[REG_EIP],
        (unsigned long)uc->uc_mcontext.gregs[REG_ESP],
        (unsigned long)uc->uc_mcontext.gregs[REG_EBP]);
    __android_log_print(ANDROID_LOG_FATAL, CRASH_TAG,
        "  EAX: 0x%lx  EBX: 0x%lx  ECX: 0x%lx  EDX: 0x%lx",
        (unsigned long)uc->uc_mcontext.gregs[REG_EAX],
        (unsigned long)uc->uc_mcontext.gregs[REG_EBX],
        (unsigned long)uc->uc_mcontext.gregs[REG_ECX],
        (unsigned long)uc->uc_mcontext.gregs[REG_EDX]);
#endif
}

[[gnu::cold]] static void dump_faulting_instruction(void* context) {
    if (!context) return;

    ucontext_t* uc = static_cast<ucontext_t*>(context);
    void* pc = nullptr;

#if defined(__aarch64__)
    pc = (void*)uc->uc_mcontext.pc;
#elif defined(__arm__)
    pc = (void*)uc->uc_mcontext.arm_pc;
#elif defined(__x86_64__)
    pc = (void*)uc->uc_mcontext.gregs[REG_RIP];
#elif defined(__i386__)
    pc = (void*)uc->uc_mcontext.gregs[REG_EIP];
#endif

    if (!pc) return;

    char hex[64];
    hex[0] = '\0';
    int pos = 0;

    const unsigned char* bytes = (const unsigned char*)pc;
    for (int i = 0; i < 16; ++i) {
        unsigned char b = bytes[i];
        int written = snprintf(hex + pos, sizeof(hex) - pos, "%02x ", b);
        if (written < 0 || pos + written >= (int)sizeof(hex) - 4) break;
        pos += written;
    }

    __android_log_print(ANDROID_LOG_FATAL, CRASH_TAG,
                        " Faulting instruction at %p: %s", pc, hex);
}

static void reset_to_default_and_raise(int sig) {
    struct sigaction dfl;
    std::memset(&dfl, 0, sizeof(dfl));
    dfl.sa_handler = SIG_DFL;
    sigemptyset(&dfl.sa_mask);
    dfl.sa_flags = 0;
    sigaction(sig, &dfl, nullptr);

    sigset_t set;
    sigemptyset(&set);
    sigaddset(&set, sig);
    pthread_sigmask(SIG_UNBLOCK, &set, nullptr);
    raise(sig);
}

static void call_previous_handler(struct sigaction* old, int sig, siginfo_t* info, void* context) {
    if (old && (old->sa_flags & SA_SIGINFO) && old->sa_sigaction) {
        old->sa_sigaction(sig, info, context);
        return;
    }
    if (old && old->sa_handler != SIG_DFL && old->sa_handler != SIG_IGN) {
        old->sa_handler(sig);
        return;
    }
    reset_to_default_and_raise(sig);
}

[[gnu::cold]] static void crash_handler(int sig, siginfo_t* info, void* context) {
    if (g_in_handler) {
        _exit(128 + sig);
    }
    g_in_handler = 1;

    __android_log_print(ANDROID_LOG_FATAL, CRASH_TAG, "!!! NATIVE CRASH DETECTED !!!");
    __android_log_print(ANDROID_LOG_FATAL, CRASH_TAG, " Signal: %d (%s)", sig, signal_name(sig));
    __android_log_print(ANDROID_LOG_FATAL, CRASH_TAG, " Address: %p",
                        info ? static_cast<void*>(info->si_addr) : nullptr);
    __android_log_print(ANDROID_LOG_FATAL, CRASH_TAG, " PID: %d", (int)getpid());
    __android_log_print(ANDROID_LOG_FATAL, CRASH_TAG, " TID: %d", (int)safe_gettid());
    if (info) {
        __android_log_print(ANDROID_LOG_FATAL, CRASH_TAG, " si_code: %d", info->si_code);
    }

    dump_registers(context);
    dump_backtrace();
    dump_faulting_instruction(context);

    struct sigaction* old = nullptr;
    switch (sig) {
        case SIGSEGV: old = &old_sigsegv; break;
        case SIGABRT: old = &old_sigabrt; break;
        case SIGBUS: old = &old_sigbus; break;
        case SIGFPE: old = &old_sigfpe; break;
        case SIGILL: old = &old_sigill; break;
    }

    call_previous_handler(old, sig, info, context);
    _exit(128 + sig);
}

static void install_alt_stack_for_current_thread() {
    static thread_local unsigned char* stack = nullptr;
    if (!stack) {
        stack = static_cast<unsigned char*>(std::malloc(64 * 1024));
    }
    if (!stack) {
        __android_log_print(ANDROID_LOG_WARN, CRASH_TAG,
                            "Failed to allocate alternate stack for thread");
        return;
    }

    stack_t ss;
    ss.ss_sp = stack;
    ss.ss_size = 64 * 1024;
    ss.ss_flags = 0;

    if (sigaltstack(&ss, nullptr) != 0) {
        __android_log_print(ANDROID_LOG_ERROR, CRASH_TAG,
                            "sigaltstack failed for current thread");
    }
}

extern "C" JNIEXPORT void JNICALL
Java_com_kopri_translator_CrashHandler_nativeInit(JNIEnv* env, jobject thiz) {
    (void)env;
    (void)thiz;

    // Always install alternate stack for current thread
    install_alt_stack_for_current_thread();

    // Only install handlers once
    if (!g_handler_installed.exchange(true)) {
        struct sigaction sa;
        std::memset(&sa, 0, sizeof(sa));
        sigemptyset(&sa.sa_mask);
        sa.sa_sigaction = crash_handler;
        sa.sa_flags = SA_SIGINFO | SA_ONSTACK;

        if (sigaction(SIGSEGV, &sa, &old_sigsegv) != 0) {
            __android_log_print(ANDROID_LOG_ERROR, CRASH_TAG,
                                "Failed to install SIGSEGV handler");
        }
        if (sigaction(SIGABRT, &sa, &old_sigabrt) != 0) {
            __android_log_print(ANDROID_LOG_ERROR, CRASH_TAG,
                                "Failed to install SIGABRT handler");
        }
        if (sigaction(SIGBUS, &sa, &old_sigbus) != 0) {
            __android_log_print(ANDROID_LOG_ERROR, CRASH_TAG,
                                "Failed to install SIGBUS handler");
        }
        if (sigaction(SIGFPE, &sa, &old_sigfpe) != 0) {
            __android_log_print(ANDROID_LOG_ERROR, CRASH_TAG,
                                "Failed to install SIGFPE handler");
        }
        if (sigaction(SIGILL, &sa, &old_sigill) != 0) {
            __android_log_print(ANDROID_LOG_ERROR, CRASH_TAG,
                                "Failed to install SIGILL handler");
        }

        __android_log_print(ANDROID_LOG_INFO, CRASH_TAG,
                            "Native crash handler installed for pid=%d", (int)getpid());
        __android_log_print(ANDROID_LOG_INFO, CRASH_TAG,
                            " Catching: SIGSEGV, SIGABRT, SIGBUS, SIGFPE, SIGILL");
    }
}