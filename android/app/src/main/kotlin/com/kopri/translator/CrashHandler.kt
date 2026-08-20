package com.kopri.translator

object CrashHandler {
    init {
        System.loadLibrary("profile_native")
    }

    external fun nativeInit()
}