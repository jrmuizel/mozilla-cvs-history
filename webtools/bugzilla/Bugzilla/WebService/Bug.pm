# -*- Mode: perl; indent-tabs-mode: nil -*-
#
# The contents of this file are subject to the Mozilla Public
# License Version 1.1 (the "License"); you may not use this file
# except in compliance with the License. You may obtain a copy of
# the License at http://www.mozilla.org/MPL/
#
# Software distributed under the License is distributed on an "AS
# IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
# implied. See the License for the specific language governing
# rights and limitations under the License.
#
# The Original Code is the Bugzilla Bug Tracking System.
#
# Contributor(s): Marc Schumann <wurblzap@gmail.com>
#                 Max Kanat-Alexander <mkanat@bugzilla.org>
#                 Mads Bondo Dydensborg <mbd@dbc.dk>
#                 Tsahi Asher <tsahi_75@yahoo.com>
#                 Noura Elhawary <nelhawar@redhat.com>

package Bugzilla::WebService::Bug;

use strict;
use base qw(Bugzilla::WebService);

use Bugzilla::Constants;
use Bugzilla::Error;
use Bugzilla::Field;
use Bugzilla::WebService::Constants;
use Bugzilla::Bug;
use Bugzilla::BugMail;
use Bugzilla::Constants;

#############
# Constants #
#############

# This maps the names of internal Bugzilla bug fields to things that would
# make sense to somebody who's not intimately familiar with the inner workings
# of Bugzilla. (These are the field names that the WebService uses.)
use constant FIELD_MAP => {
    status      => 'bug_status',
    severity    => 'bug_severity',
    description => 'comment',
    summary     => 'short_desc',
    platform    => 'rep_platform',
};

use constant GLOBAL_SELECT_FIELDS => qw(
    bug_severity
    bug_status
    op_sys
    priority
    rep_platform
    resolution
);

use constant PRODUCT_SPECIFIC_FIELDS => qw(version target_milestone component);

######################################################
# Add aliases here for old method name compatibility #
######################################################

BEGIN { *get_bugs = \&get }

###########
# Methods #
###########

sub get {
    my ($self, $params) = @_;
    my $ids = $params->{ids};
    defined $ids || ThrowCodeError('param_required', { param => 'ids' });

    my @return;
    foreach my $bug_id (@$ids) {
        my $bug = Bugzilla::Bug->check($bug_id);

        # Timetracking fields are deleted if the user doesn't belong to
        # the corresponding group.
        unless (Bugzilla->user->in_group(Bugzilla->params->{'timetrackinggroup'})) {
            delete $bug->{'estimated_time'};
            delete $bug->{'remaining_time'};
            delete $bug->{'deadline'};
        }
        # This is done in this fashion in order to produce a stable API.
        # The internals of Bugzilla::Bug are not stable enough to just
        # return them directly.
        my %item;
        $item{'creation_time'}    = $self->type('dateTime', $bug->creation_ts);
        $item{'last_change_time'} = $self->type('dateTime', $bug->delta_ts);
        $item{'internals'}        = $bug;
        $item{'id'}               = $self->type('int', $bug->bug_id);
        $item{'summary'}          = $self->type('string', $bug->short_desc);

        if (Bugzilla->params->{'usebugaliases'}) {
            $item{'alias'} = $self->type('string', $bug->alias);
        }
        else {
            # For API reasons, we always want the value to appear, we just
            # don't want it to have a value if aliases are turned off.
            $item{'alias'} = undef;
        }

        push(@return, \%item);
    }

    return { bugs => \@return };
}

# this is a function that gets bug activity for list of bug ids 
# it can be called as the following:
# $call = $rpc->call( 'Bug.get_history', { ids => [1,2] });
sub get_history {
    my ($self, $params) = @_;

    my $ids = $params->{ids};
    defined $ids || ThrowCodeError('param_required', { param => 'ids' });

    my @return;
    foreach my $bug_id (@$ids) {
        my %item;
        my $bug = Bugzilla::Bug->check($bug_id);
        $bug_id = $bug->id;

        my ($activity) = Bugzilla::Bug::GetBugActivity($bug_id);
        $item{$bug_id} = [];

        foreach my $changeset (@$activity) {
            my %bug_history;
            $bug_history{when} = $self->type('dateTime',
                $self->datetime_format($changeset->{when}));
            $bug_history{who}  = $self->type('string', $changeset->{who});
            $bug_history{changes} = [];
            foreach my $change (@{ $changeset->{changes} }) {
                my $attach_id = delete $change->{attachid};
                if ($attach_id) {
                    $change->{attachment_id} = $self->type('int', $attach_id);
                }
                $change->{removed} = $self->type('string', $change->{removed});
                $change->{added}   = $self->type('string', $change->{added});
                $change->{field_name} = $self->type('string',
                    delete $change->{fieldname});
                # This is going to go away in the future from GetBugActivity
                # so we shouldn't put it in the API.
                delete $change->{field};
                push (@{$bug_history{changes}}, $change);
            }
            
            push (@{$item{$bug_id}}, \%bug_history);
        }   

        # alias is returned in case users passes a mixture of ids and aliases
        # then they get to know which bug activity relates to which value  
        # they passed
        if (Bugzilla->params->{'usebugaliases'}) {
            $item{alias} = $self->type('string', $bug->alias);
        }
        else {
            # For API reasons, we always want the value to appear, we just
            # don't want it to have a value if aliases are turned off.
            $item{alias} = undef;
        }

        push(@return, \%item);
    }

    return { bugs => \@return };
}

sub create {
    my ($self, $params) = @_;

    Bugzilla->login(LOGIN_REQUIRED);

    my %field_values;
    foreach my $field (keys %$params) {
        my $field_name = FIELD_MAP->{$field} || $field;
        $field_values{$field_name} = $params->{$field}; 
    }

    # WebService users can't set the creation date of a bug.
    delete $field_values{'creation_ts'};

    my $bug = Bugzilla::Bug->create(\%field_values);

    Bugzilla::BugMail::Send($bug->bug_id, { changer => $bug->reporter->login });

    return { id => $self->type('int', $bug->bug_id) };
}

sub legal_values {
    my ($self, $params) = @_;
    my $field = FIELD_MAP->{$params->{field}} || $params->{field};

    my @custom_select =
        Bugzilla->get_fields({ type => FIELD_TYPE_SINGLE_SELECT });
    # We only want field names.
    @custom_select = map {$_->name} @custom_select;

    my $values;
    if (grep($_ eq $field, GLOBAL_SELECT_FIELDS, @custom_select)) {
        $values = get_legal_field_values($field);
    }
    elsif (grep($_ eq $field, PRODUCT_SPECIFIC_FIELDS)) {
        my $id = $params->{product_id};
        defined $id || ThrowCodeError('param_required',
            { function => 'Bug.legal_values', param => 'product_id' });
        grep($_->id eq $id, @{Bugzilla->user->get_accessible_products})
            || ThrowUserError('product_access_denied', { product => $id });

        my $product = new Bugzilla::Product($id);
        my @objects;
        if ($field eq 'version') {
            @objects = @{$product->versions};
        }
        elsif ($field eq 'target_milestone') {
            @objects = @{$product->milestones};
        }
        elsif ($field eq 'component') {
            @objects = @{$product->components};
        }

        $values = [map { $_->name } @objects];
    }
    else {
        ThrowCodeError('invalid_field_name', { field => $params->{field} });
    }

    my @result;
    foreach my $val (@$values) {
        push(@result, $self->type('string', $val));
    }

    return { values => \@result };
}

sub add_comment {
    my ($self, $params) = @_;
    
    #The user must login in order add a comment
    Bugzilla->login(LOGIN_REQUIRED);
    
    # Check parameters
    defined $params->{id} 
        || ThrowCodeError('param_required', { param => 'id' }); 
    my $comment = $params->{comment}; 
    defined $comment
        || ThrowCodeError('param_required', { param => 'comment' });
    
    my $bug = Bugzilla::Bug->check($params->{id});
    
    Bugzilla->user->can_edit_product($bug->product_id)
        || ThrowUserError("product_edit_denied", {product => $bug->product});
        
    # Append comment
    $bug->add_comment($comment, { isprivate => $params->{private},
                                  work_time => $params->{work_time} });
    $bug->update();
    
    # Send mail.
    Bugzilla::BugMail::Send($bug->bug_id, { changer => Bugzilla->user->login });
    return undef;
}

1;

__END__

=head1 NAME

Bugzilla::Webservice::Bug - The API for creating, changing, and getting the
details of bugs.

=head1 DESCRIPTION

This part of the Bugzilla API allows you to file a new bug in Bugzilla,
or get information about bugs that have already been filed.

=head1 METHODS

See L<Bugzilla::WebService> for a description of B<STABLE>, B<UNSTABLE>,
and B<EXPERIMENTAL>.

=head2 Utility Functions

=over

=item C<legal_values> B<EXPERIMENTAL>

=over

=item B<Description>

Tells you what values are allowed for a particular field.

=item B<Params>

=over

=item C<field> - The name of the field you want information about.
This should be the same as the name you would use in L</create>, below.

=item C<product_id> - If you're picking a product-specific field, you have
to specify the id of the product you want the values for.

=back

=item B<Returns> 

C<values> - An array of strings: the legal values for this field.
The values will be sorted as they normally would be in Bugzilla.

=item B<Errors>

=over

=item 106 (Invalid Product)

You were required to specify a product, and either you didn't, or you
specified an invalid product (or a product that you can't access).

=item 108 (Invalid Field Name)

You specified a field that doesn't exist or isn't a drop-down field.

=back

=back


=back

=head2 Bug Creation and Modification

=over

=item C<get> B<EXPERIMENTAL>

=over

=item B<Description>

Gets information about particular bugs in the database.

Note: Can also be called as "get_bugs" for compatibilty with Bugzilla 3.0 API.

=item B<Params>

=over

=item C<ids>

An array of numbers and strings.

If an element in the array is entirely numeric, it represents a bug_id
from the Bugzilla database to fetch. If it contains any non-numeric 
characters, it is considered to be a bug alias instead, and the bug with 
that alias will be loaded. 

Note that it's possible for aliases to be disabled in Bugzilla, in which
case you will be told that you have specified an invalid bug_id if you
try to specify an alias. (It will be error 100.)

=back

=item B<Returns>

A hash containing a single element, C<bugs>. This is an array of hashes. 
Each hash contains the following items:

=over

=item id

C<int> The numeric bug_id of this bug.

=item alias

C<string> The alias of this bug. If there is no alias or aliases are 
disabled in this Bugzilla, this will be an empty string.

=item summary

C<string> The summary of this bug.

=item creation_time

C<dateTime> When the bug was created.

=item last_change_time

C<dateTime> When the bug was last changed.

=item internals B<UNSTABLE>

A hash. The internals of a L<Bugzilla::Bug> object. This is extremely
unstable, and you should only rely on this if you absolutely have to. The
structure of the hash may even change between point releases of Bugzilla.

=back

=item B<Errors>

=over

=item 100 (Invalid Bug Alias)

If you specified an alias and either: (a) the Bugzilla you're querying
doesn't support aliases or (b) there is no bug with that alias.

=item 101 (Invalid Bug ID)

The bug_id you specified doesn't exist in the database.

=item 102 (Access Denied)

You do not have access to the bug_id you specified.

=back

=back

=item C<get_history> B<UNSTABLE>

=over

=item B<Description>

Gets the history of changes for particular bugs in the database.

=item B<Params>

=over

=item C<ids>

An array of numbers and strings.

If an element in the array is entirely numeric, it represents a bug_id 
from the Bugzilla database to fetch. If it contains any non-numeric 
characters, it is considered to be a bug alias instead, and the data bug 
with that alias will be loaded. 

Note that it's possible for aliases to be disabled in Bugzilla, in which
case you will be told that you have specified an invalid bug_id if you
try to specify an alias. (It will be error 100.)

=back

=item B<Returns>

A hash containing a single element, C<bugs>. This is a hash of hashes. 
Each hash has the numeric bug id as a key, and contains the following
items:

=over

=item alias

C<string> The alias of this bug. If there is no alias or aliases are 
disabled in this Bugzilla, this will be undef.

=over

=item when

C<dateTime> The date the bug activity/change happened.

=item who

C<string> The login name of the user who performed the bug change.

=item changes

C<array> An array of hashes which contain all the changes that happened
to the bug at this time (as specified by C<when>). Each hash contains 
the following items:

=over

=item field_name

C<string> The name of the bug field that has changed.

=item removed

C<string> The previous value of the bug field which has been deleted 
by the change.

=item added

C<string> The new value of the bug field which has been added by the change.

=item attachment_id

C<int> The id of the attachment that was changed. This only appears if 
the change was to an attachment, otherwise C<attachment_id> will not be
present in this hash.

=back

=back

=back

=item B<Errors>

The same as L</get>.

=back

=item C<create> B<EXPERIMENTAL>

=over

=item B<Description>

This allows you to create a new bug in Bugzilla. If you specify any
invalid fields, they will be ignored. If you specify any fields you
are not allowed to set, they will just be set to their defaults or ignored.

You cannot currently set all the items here that you can set on enter_bug.cgi.

The WebService interface may allow you to set things other than those listed
here, but realize that anything undocumented is B<UNSTABLE> and will very
likely change in the future.

=item B<Params>

Some params must be set, or an error will be thrown. These params are
marked B<Required>. 

Some parameters can have defaults set in Bugzilla, by the administrator.
If these parameters have defaults set, you can omit them. These parameters
are marked B<Defaulted>.

Clients that want to be able to interact uniformly with multiple
Bugzillas should always set both the params marked B<Required> and those 
marked B<Defaulted>, because some Bugzillas may not have defaults set
for B<Defaulted> parameters, and then this method will throw an error
if you don't specify them.

The descriptions of the parameters below are what they mean when Bugzilla is
being used to track software bugs. They may have other meanings in some
installations.

=over

=item C<product> (string) B<Required> - The name of the product the bug
is being filed against.

=item C<component> (string) B<Required> - The name of a component in the
product above.

=item C<summary> (string) B<Required> - A brief description of the bug being
filed.

=item C<version> (string) B<Required> - A version of the product above;
the version the bug was found in.

=item C<description> (string) B<Defaulted> - The initial description for 
this bug. Some Bugzilla installations require this to not be blank.

=item C<op_sys> (string) B<Defaulted> - The operating system the bug was
discovered on.

=item C<platform> (string) B<Defaulted> - What type of hardware the bug was
experienced on.

=item C<priority> (string) B<Defaulted> - What order the bug will be fixed
in by the developer, compared to the developer's other bugs.

=item C<severity> (string) B<Defaulted> - How severe the bug is.

=item C<alias> (string) - A brief alias for the bug that can be used 
instead of a bug number when accessing this bug. Must be unique in
all of this Bugzilla.

=item C<assigned_to> (username) - A user to assign this bug to, if you
don't want it to be assigned to the component owner.

=item C<cc> (array) - An array of usernames to CC on this bug.

=item C<qa_contact> (username) - If this installation has QA Contacts
enabled, you can set the QA Contact here if you don't want to use
the component's default QA Contact.

=item C<status> (string) - The status that this bug should start out as.
Note that only certain statuses can be set on bug creation.

=item C<target_milestone> (string) - A valid target milestone for this
product.

=back

In addition to the above parameters, if your installation has any custom
fields, you can set them just by passing in the name of the field and
its value as a string.

=item B<Returns>

A hash with one element, C<id>. This is the id of the newly-filed bug.

=item B<Errors>

=over

=item 51 (Invalid Object)

The component you specified is not valid for this Product.

=item 103 (Invalid Alias)

The alias you specified is invalid for some reason. See the error message
for more details.

=item 104 (Invalid Field)

One of the drop-down fields has an invalid value, or a value entered in a
text field is too long. The error message will have more detail.

=item 105 (Invalid Component)

You didn't specify a component.

=item 106 (Invalid Product)

Either you didn't specify a product, this product doesn't exist, or
you don't have permission to enter bugs in this product.

=item 107 (Invalid Summary)

You didn't specify a summary for the bug.

=item 504 (Invalid User)

Either the QA Contact, Assignee, or CC lists have some invalid user
in them. The error message will have more details.

=back

=item B<History>

=over

=item Before B<3.0.4>, parameters marked as B<Defaulted> were actually
B<Required>, due to a bug in Bugzilla.

=back

=back

=item C<add_comment> B<EXPERIMENTAL>

=over

=item B<Description>

This allows you to add a comment to a bug in Bugzilla.

=item B<Params>

=over

=item C<id> (int) B<Required> - The id or alias of the bug to append a 
comment to.

=item C<comment> (string) B<Required> - The comment to append to the bug.

=item C<private> (boolean) - If set to true, the comment is private, otherwise
it is assumed to be public.

=item C<work_time> (double) - Adds this many hours to the "Hours Worked"
on the bug. If you are not in the time tracking group, this value will
be ignored.


=back

=item B<Errors>

=over

=item 100 (Invalid Bug Alias) 

If you specified an alias and either: (a) the Bugzilla you're querying
doesn't support aliases or (b) there is no bug with that alias.

=item 101 (Invalid Bug ID)

The id you specified doesn't exist in the database.

=item 108 (Bug Edit Denied)

You did not have the necessary rights to edit the bug.

=back

=back


=back
