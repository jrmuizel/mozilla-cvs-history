# -*- mode: cperl; c-basic-offset: 8; indent-tabs-mode: nil; -*-

=head1 COPYRIGHT

 # ***** BEGIN LICENSE BLOCK *****
 # Version: MPL 1.1
 #
 # The contents of this file are subject to the Mozilla Public License
 # Version 1.1 (the "License"); you may not use this file except in
 # compliance with the License. You may obtain a copy of the License
 # at http://www.mozilla.org/MPL/
 #
 # Software distributed under the License is distributed on an "AS IS"
 # basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
 # the License for the specific language governing rights and
 # limitations under the License.
 #
 # The Original Code is Litmus.
 #
 # The Initial Developer of the Original Code is
 # the Mozilla Corporation.
 # Portions created by the Initial Developer are Copyright (C) 2006
 # the Initial Developer. All Rights Reserved.
 #
 # Contributor(s):
 #   Chris Cooper <ccooper@deadsquid.com>
 #   Zach Lipton <zach@zachlipton.com>
 #
 # ***** END LICENSE BLOCK *****

=cut

package Litmus::DB::LogTestresult;

use strict;
use base 'Litmus::DBI';

Litmus::DB::LogTestresult->table('testresult_logs_join');

Litmus::DB::LogTestresult->columns(Primary => qw/test_result_id log_id/);
Litmus::DB::LogTestresult->columns(TEMP => qw //);

Litmus::DB::LogTestresult->column_alias("test_result_id", "test_result");

Litmus::DB::LogTestresult->has_a(test_result => "Litmus::DB::Testresult");
Litmus::DB::LogTestresult->has_a(log_id => "Litmus::DB::Log");

1;
