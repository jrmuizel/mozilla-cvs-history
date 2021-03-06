/* -*- Mode: C++; tab-width: 2; indent-tabs-mode: nil; c-basic-offset: 2 -*- */
/* ***** BEGIN LICENSE BLOCK *****
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
* The Original Code is Camino code.
*
* The Initial Developer of the Original Code is
* Stuart Morgan.
* Portions created by the Initial Developer are Copyright (C) 2007
* the Initial Developer. All Rights Reserved.
*
* Contributor(s):
*   Stuart Morgan <stuart.morgan@alumni.case.edu>
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

#import <Cocoa/Cocoa.h>

// WebSearchField
//
// A search field that knows how to manage a web search engine list, for use as
// the toolbar web search field.
@interface WebSearchField : NSSearchField {
  NSImage* mDetectedSearchPluginImage; // strong
}

// Takes an array of dictionaries, using the keys declared in SearchEngineManger.h,
// describing the search engines to populate the menu with.
- (void)setSearchEngines:(NSArray*)searchEngines;

// Changes the current search engine setting to the one names |engineName|.
- (void)setCurrentSearchEngine:(NSString*)engineName;

// Takes an array of dictionaries, using the keys declared in XMLSearchPluginParser.h, to
// populate the menu with search plugins available to install. Plugin menu items send the
// |installSearchPlugin:| action to the search field's target, and each item's |representedObject|
// is the search plugin dictionary.
//
// The search field will automatically indicate if plugins are available in its menu.
// Calling this method with nil or an empty array will remove all existing items.
- (void)setDetectedSearchPlugins:(NSArray*)detectedSearchPlugins;

// Returns the name of the currently selected search engine.
- (NSString*)currentSearchEngine;

// Returns the search URL for the currently selected search engine.
- (NSString*)currentSearchURL;

@end

@interface WebSearchField (DelegateMethods)

- (BOOL)webSearchField:(WebSearchField*)webSearchField shouldListDetectedSearchPlugin:(NSDictionary *)searchPluginInfoDict;

@end
