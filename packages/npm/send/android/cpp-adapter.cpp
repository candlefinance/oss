#include <jni.h>
#include "candlefinance-send.h"

extern "C"
JNIEXPORT jdouble JNICALL
Java_com_candlefinance_send_SendModule_nativeMultiply(JNIEnv *env, jclass type, jdouble a, jdouble b) {
    return candlefinance_send::multiply(a, b);
}
