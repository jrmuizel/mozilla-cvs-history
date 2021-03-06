/* -*- Mode: C++; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 2 -*-
 *
 * ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1/GPL 2.0/LGPL 2.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is mozilla.org code.
 *
 * The Initial Developer of the Original Code is
 * Netscape Communications Corporation.
 * Portions created by the Initial Developer are Copyright (C) 1998
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 * Alternatively, the contents of this file may be used under the terms of
 * either the GNU General Public License Version 2 or later (the "GPL"), or
 * the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
 * in which case the provisions of the GPL or the LGPL are applicable instead
 * of those above. If you wish to allow use of your version of this file only
 * under the terms of either the GPL or the LGPL, and not to allow others to
 * use your version of this file under the terms of the MPL, indicate your
 * decision by deleting the provisions above and replace them with the notice
 * and other provisions required by the GPL or the LGPL. If you do not delete
 * the provisions above, a recipient may use your version of this file under
 * the terms of any one of the MPL, the GPL or the LGPL.
 *
 * ***** END LICENSE BLOCK ***** */
/*******************************************************************************
 * Source date: 9 Apr 1997 21:45:13 GMT
 * netscape/fonts/nffmi public interface
 * Generated by jmc version 1.8 -- DO NOT EDIT
 ******************************************************************************/

#ifndef _Mnffmi_H_
#define _Mnffmi_H_

#include "jmc.h"

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

/*******************************************************************************
 * nffmi
 ******************************************************************************/

/* The type of the nffmi interface. */
struct nffmiInterface;

/* The public type of a nffmi instance. */
typedef struct nffmi {
	const struct nffmiInterface*	vtable;
} nffmi;

/* The inteface ID of the nffmi interface. */
#ifndef JMC_INIT_nffmi_ID
extern EXTERN_C_WITHOUT_EXTERN const JMCInterfaceID nffmi_ID;
#else
EXTERN_C const JMCInterfaceID nffmi_ID = { 0x22420e05, 0x574c4001, 0x5a4e671e, 0x0b464713 };
#endif /* JMC_INIT_nffmi_ID */
/*******************************************************************************
 * nffmi Operations
 ******************************************************************************/

#define nffmi_getInterface(self, a, exception)	\
	(((self)->vtable->getInterface)(self, nffmi_getInterface_op, a, exception))

#define nffmi_addRef(self, exception)	\
	(((self)->vtable->addRef)(self, nffmi_addRef_op, exception))

#define nffmi_release(self, exception)	\
	(((self)->vtable->release)(self, nffmi_release_op, exception))

#define nffmi_hashCode(self, exception)	\
	(((self)->vtable->hashCode)(self, nffmi_hashCode_op, exception))

#define nffmi_equals(self, a, exception)	\
	(((self)->vtable->equals)(self, nffmi_equals_op, a, exception))

#define nffmi_clone(self, exception)	\
	(((self)->vtable->clone)(self, nffmi_clone_op, exception))

#define nffmi_toString(self, exception)	\
	(((self)->vtable->toString)(self, nffmi_toString_op, exception))

#define nffmi_finalize(self, exception)	\
	(((self)->vtable->finalize)(self, nffmi_finalize_op, exception))

#define nffmi_GetValue(self, a, exception)	\
	(((self)->vtable->GetValue)(self, nffmi_GetValue_op, a, exception))

#define nffmi_ListAttributes(self, exception)	\
	(((self)->vtable->ListAttributes)(self, nffmi_ListAttributes_op, exception))

/*******************************************************************************
 * nffmi Interface
 ******************************************************************************/

struct netscape_jmc_JMCInterfaceID;
struct java_lang_Object;
struct java_lang_String;
struct netscape_jmc_ConstCString;

struct nffmiInterface {
	void*	(*getInterface)(struct nffmi* self, jint op, const JMCInterfaceID* a, JMCException* *exception);
	void	(*addRef)(struct nffmi* self, jint op, JMCException* *exception);
	void	(*release)(struct nffmi* self, jint op, JMCException* *exception);
	jint	(*hashCode)(struct nffmi* self, jint op, JMCException* *exception);
	jbool	(*equals)(struct nffmi* self, jint op, void* a, JMCException* *exception);
	void*	(*clone)(struct nffmi* self, jint op, JMCException* *exception);
	const char*	(*toString)(struct nffmi* self, jint op, JMCException* *exception);
	void	(*finalize)(struct nffmi* self, jint op, JMCException* *exception);
	void*	(*GetValue)(struct nffmi* self, jint op, const char* a, JMCException* *exception);
	void*	(*ListAttributes)(struct nffmi* self, jint op, JMCException* *exception);
};

/*******************************************************************************
 * nffmi Operation IDs
 ******************************************************************************/

typedef enum nffmiOperations {
	nffmi_getInterface_op,
	nffmi_addRef_op,
	nffmi_release_op,
	nffmi_hashCode_op,
	nffmi_equals_op,
	nffmi_clone_op,
	nffmi_toString_op,
	nffmi_finalize_op,
	nffmi_GetValue_op,
	nffmi_ListAttributes_op
} nffmiOperations;

/******************************************************************************/

#ifdef __cplusplus
} /* extern "C" */
#endif /* __cplusplus */

#endif /* _Mnffmi_H_ */
