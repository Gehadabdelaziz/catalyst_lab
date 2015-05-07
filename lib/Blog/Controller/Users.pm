package Blog::Controller::Users;
use Moose;
use namespace::autoclean;
use Digest::MD5 qw(md5 md5_hex md5_base64);

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Blog::Controller::Users - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut
sub list :Local {
        my ($self, $c) = @_;
        $c->stash(users => [$c->model('DB::User')->all()]);
        $c->stash(template => 'users/list.tt');
}

sub base :Chained('/') :PathPart('users'):CaptureArgs(0) {
        my ($self, $c) = @_;
        # Store the ResultSet in stash so it's available for other methods
        $c->stash(resultset => $c->model('DB::User'));
        # Print a message to the debug log
        $c->log->debug('*** INSIDE BASE METHOD ***');
}

sub form_new :Chained('base'):PathPart('new') :Args(0) {
        my ($self, $c) = @_;
        # Set the TT template to use
        $c->stash(template => 'users/form.tt');
}

sub form_create :Chained('base'):PathPart('create') :Args(0) {
        my ($self, $c) = @_;
        my $username = $c->request->params->{username} || 'N/A';
        my $email = $c->request->params->{email} || 'N/A';
        my $password= $c->request->params->{password} || 'N/A';
        # Create the user
        my $user = $c->model('DB::User')->create({
        username => $username,
        email => $email,
        password => md5($password)
        });
        # Store new model object in stash and set template
        $c->stash(user => $user,template => 'users/show.tt');
}

sub object :Chained('base') :PathPart('id') :CaptureArgs(1) {
        # $id = primary key of user to delete
        my ($self, $c, $id) = @_;
    
        # Find the user object and store it in the stash
        $c->stash(object => $c->stash->{resultset}->find($id));
    
        # Make sure the lookup was successful.  You would probably
        # want to do something like this in a real app:
        #   $c->detach('/error_404') if !$c->stash->{object};
        die "User $id not found!" if !$c->stash->{object};
    
        # Print a message to the debug log
        $c->log->debug("*** INSIDE OBJECT METHOD for obj id=$id ***");
    }
sub delete :Chained('object') :PathPart('delete') :Args(0) {
        my ($self, $c) = @_;
        $c->stash->{object}->delete;
    
        # Redirect the user back to the list page with status msg as an arg
        $c->response->redirect($c->uri_for($self->action_for('list'),
            {status_msg => "User deleted."}));
}

 sub edit :Chained('object') :PathPart('edit') :Args(0){
        my ($self, $c) = @_;  
        # Get the specified book already saved by the 'object' method
        my $user = $c->stash->{object};
        $c->stash(user => $user,template => 'users/form_edit.tt');
        }
        
 sub update :Chained('object'):PathPart('update') :Args(0) {
        my ($self, $c) = @_;
        my $username = $c->request->params->{username} || 'N/A';
        my $email = $c->request->params->{email} || 'N/A';
        my $password= $c->request->params->{password} || 'N/A';
        # update the user
        my $user =  $c->stash->{object}->update({
        username => $username,
        email => $email,
        password => md5($password)
        });
        # Store new model object in stash and set template
        $c->forward('list');
}       

       
   
       
    
        
=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Blog::Controller::Users in Users.');
}



=encoding utf8

=head1 AUTHOR

gehad,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
