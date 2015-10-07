package Biller;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
  my $self = shift;

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer');

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->get('/entity/:entity')->to('entity#get');
  $r->get('/entity/:entity/children')->to('entity#get_children');
  $r->get('/entity/:entity/related')->to('entity#get_related');
  $r->post('/entity')->to('entity#post');
  $r->patch('/entity/:entity')->to('entity#patch');
}

1;
