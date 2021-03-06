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
 * The Original Code is Zip Writer Component.
 *
 * The Initial Developer of the Original Code is
 * Dave Townsend <dtownsend@oxymoronical.com>.
 *
 * Portions created by the Initial Developer are Copyright (C) 2008
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
 * ***** END LICENSE BLOCK *****
 */

const DIRNAME = "test/";
const time = Date.now();

function run_test()
{
  // Copy in the test file.
  var source = do_get_file("modules/libjar/zipwriter/test/unit/data/test.zip");
  source.copyTo(tmpFile.parent, tmpFile.leafName);

  // Open it and add something so the CDS is rewritten.
  zipW.open(tmpFile, PR_RDWR | PR_APPEND);
  zipW.addEntryDirectory(DIRNAME, time * PR_USEC_PER_MSEC, false);
  do_check_true(zipW.hasEntry(DIRNAME));
  zipW.close();

  var zipR = new ZipReader(tmpFile);
  do_check_true(zipR.hasEntry(DIRNAME));
  zipR.close();

  // Adding the directory would have added a fixed amount to the file size.
  // Any difference suggests the CDS was written out incorrectly.
  var extra = ZIP_FILE_HEADER_SIZE + ZIP_CDS_HEADER_SIZE + (DIRNAME.length * 2);
  do_check_eq(source.fileSize + extra, tmpFile.fileSize);
}
