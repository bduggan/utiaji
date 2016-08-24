#| Dispatch HTTP requests.
unit role Utiaji::Dispatcher;

use Utiaji::Request;
use Utiaji::Log;
use Utiaji::Response;
use Utiaji::Error;

method dispatch-request($route,
    Match $captures,
    Utiaji::Request $req,
) is export {
   my Code $cb = $route.code;

   my @args;
   if $captures && $captures.hash.elems {
       @args.push($captures);
   }
   if $cb.signature.count > @args {
       @args.push($req);
   }
   my $response;
   try {
       CATCH {
           when Utiaji::Error {
               my $status = $_.status // 400;;
               my $text = $_.message // 'unknown error';
               $response = self.render(:$status, :$text);
               error "Error generating error { $response.gist }" unless $response ~~ Utiaji::Response;
           }
       }
       $response = $cb(|@args);
   }
   unless $response ~~ Utiaji::Response {
       $response = self.render(|$response);
   }
   return $response;
}
