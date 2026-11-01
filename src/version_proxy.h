#pragma once
#include <windows.h>

static HMODULE g_hRealVersion = nullptr;

static FARPROC fp_GetFileVersionInfoA         = nullptr;
static FARPROC fp_GetFileVersionInfoByHandle  = nullptr;
static FARPROC fp_GetFileVersionInfoExA       = nullptr;
static FARPROC fp_GetFileVersionInfoExW       = nullptr;
static FARPROC fp_GetFileVersionInfoSizeA     = nullptr;
static FARPROC fp_GetFileVersionInfoSizeExA   = nullptr;
static FARPROC fp_GetFileVersionInfoSizeExW   = nullptr;
static FARPROC fp_GetFileVersionInfoSizeW     = nullptr;
static FARPROC fp_GetFileVersionInfoW         = nullptr;
static FARPROC fp_VerFindFileA                = nullptr;
static FARPROC fp_VerFindFileW                = nullptr;
static FARPROC fp_VerInstallFileA             = nullptr;
static FARPROC fp_VerInstallFileW             = nullptr;
static FARPROC fp_VerLanguageNameA            = nullptr;
static FARPROC fp_VerLanguageNameW            = nullptr;
static FARPROC fp_VerQueryValueA              = nullptr;
static FARPROC fp_VerQueryValueW              = nullptr;

inline void InitVersionProxy() {
    char sysPath[MAX_PATH] = { 0 };
    GetSystemDirectoryA(sysPath, MAX_PATH);
    strcat_s(sysPath, "\\version.dll");

    g_hRealVersion = LoadLibraryA(sysPath);
    if (!g_hRealVersion) return;

    fp_GetFileVersionInfoA        = GetProcAddress(g_hRealVersion, "GetFileVersionInfoA");
    fp_GetFileVersionInfoByHandle = GetProcAddress(g_hRealVersion, "GetFileVersionInfoByHandle");
    fp_GetFileVersionInfoExA      = GetProcAddress(g_hRealVersion, "GetFileVersionInfoExA");
    fp_GetFileVersionInfoExW      = GetProcAddress(g_hRealVersion, "GetFileVersionInfoExW");
    fp_GetFileVersionInfoSizeA    = GetProcAddress(g_hRealVersion, "GetFileVersionInfoSizeA");
    fp_GetFileVersionInfoSizeExA  = GetProcAddress(g_hRealVersion, "GetFileVersionInfoSizeExA");
    fp_GetFileVersionInfoSizeExW  = GetProcAddress(g_hRealVersion, "GetFileVersionInfoSizeExW");
    fp_GetFileVersionInfoSizeW    = GetProcAddress(g_hRealVersion, "GetFileVersionInfoSizeW");
    fp_GetFileVersionInfoW        = GetProcAddress(g_hRealVersion, "GetFileVersionInfoW");
    fp_VerFindFileA               = GetProcAddress(g_hRealVersion, "VerFindFileA");
    fp_VerFindFileW               = GetProcAddress(g_hRealVersion, "VerFindFileW");
    fp_VerInstallFileA            = GetProcAddress(g_hRealVersion, "VerInstallFileA");
    fp_VerInstallFileW            = GetProcAddress(g_hRealVersion, "VerInstallFileW");
    fp_VerLanguageNameA           = GetProcAddress(g_hRealVersion, "VerLanguageNameA");
    fp_VerLanguageNameW           = GetProcAddress(g_hRealVersion, "VerLanguageNameW");
    fp_VerQueryValueA             = GetProcAddress(g_hRealVersion, "VerQueryValueA");
    fp_VerQueryValueW             = GetProcAddress(g_hRealVersion, "VerQueryValueW");
}

inline void FreeVersionProxy() {
    if (g_hRealVersion) {
        FreeLibrary(g_hRealVersion);
        g_hRealVersion = nullptr;
    }
}

#define DEFINE_PROXY(name) \
    extern "C" __declspec(naked) void Proxy_##name() { \
        __asm { jmp fp_##name } \
    }

DEFINE_PROXY(GetFileVersionInfoA)
DEFINE_PROXY(GetFileVersionInfoByHandle)
DEFINE_PROXY(GetFileVersionInfoExA)
DEFINE_PROXY(GetFileVersionInfoExW)
DEFINE_PROXY(GetFileVersionInfoSizeA)
DEFINE_PROXY(GetFileVersionInfoSizeExA)
DEFINE_PROXY(GetFileVersionInfoSizeExW)
DEFINE_PROXY(GetFileVersionInfoSizeW)
DEFINE_PROXY(GetFileVersionInfoW)
DEFINE_PROXY(VerFindFileA)
DEFINE_PROXY(VerFindFileW)
DEFINE_PROXY(VerInstallFileA)
DEFINE_PROXY(VerInstallFileW)
DEFINE_PROXY(VerLanguageNameA)
DEFINE_PROXY(VerLanguageNameW)
DEFINE_PROXY(VerQueryValueA)
DEFINE_PROXY(VerQueryValueW)