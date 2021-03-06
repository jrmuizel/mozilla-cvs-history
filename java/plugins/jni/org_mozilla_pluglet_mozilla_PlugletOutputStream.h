/* 
 * The contents of this file are subject to the Mozilla Public
 * License Version 1.1 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of
 * the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS
 * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * rights and limitations under the License.
 *
 * The Original Code is mozilla.org code.
 *
 * The Initial Developer of the Original Code is Sun Microsystems,
 * Inc. Portions created by Sun are
 * Copyright (C) 1999 Sun Microsystems, Inc. All
 * Rights Reserved.
 *
 * Contributor(s): 
 */

/* DO NOT EDIT THIS FILE - it is machine generated */
#include <jni.h>
/* Header for class org_mozilla_pluglet_mozilla_PlugletOutputStream */

#ifndef _Included_org_mozilla_pluglet_mozilla_PlugletOutputStream
#define _Included_org_mozilla_pluglet_mozilla_PlugletOutputStream
#ifdef __cplusplus
extern "C" {
#endif
/*
 * Class:     org_mozilla_pluglet_mozilla_PlugletOutputStream
 * Method:    flush
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_org_mozilla_pluglet_mozilla_PlugletOutputStream_flush
  (JNIEnv *, jobject);

/*
 * Class:     org_mozilla_pluglet_mozilla_PlugletOutputStream
 * Method:    close
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_org_mozilla_pluglet_mozilla_PlugletOutputStream_close
  (JNIEnv *, jobject);

/*
 * Class:     org_mozilla_pluglet_mozilla_PlugletOutputStream
 * Method:    nativeWrite
 * Signature: ([BII)V
 */
JNIEXPORT void JNICALL Java_org_mozilla_pluglet_mozilla_PlugletOutputStream_nativeWrite
  (JNIEnv *, jobject, jbyteArray, jint, jint);

/*
 * Class:     org_mozilla_pluglet_mozilla_PlugletOutputStream
 * Method:    nativeFinalize
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_org_mozilla_pluglet_mozilla_PlugletOutputStream_nativeFinalize
  (JNIEnv *, jobject);

/*
 * Class:     org_mozilla_pluglet_mozilla_PlugletOutputStream
 * Method:    nativeInitialize
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_org_mozilla_pluglet_mozilla_PlugletOutputStream_nativeInitialize
  (JNIEnv *, jobject);

#ifdef __cplusplus
}
#endif
#endif
