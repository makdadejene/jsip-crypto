open Core
open Async_kernel
open Jsonaf_kernel
module Server = Cohttp_async.Server

let handler ~body:_ _sock req =
  let uri = Cohttp.Request.uri req in
  let request = Uri.path uri |> String.split ~on:'/' in
  match request with
  | [ coin; year ] ->
    let response =
      Simple_model.predict ~coin ~year
      |> Simple_model.json_of_t
      |> Josnaf.to_string
    in
    Server.respond_string response
  | _ -> Server.respond_string ~status:`Not_found "Route not found"
;;

let start_server port () =
  Stdlib.Printf.eprintf "Listening for HTTP on\n   port %d\n" port;
  Stdlib.Printf.eprintf
    "Try 'curl\n   http://localhost:%d/test?hello=xyz'\n%!"
    port;
  let%bind _server =
    Server.create
      ~on_handler_error:`Raise
      (Async.Tcp.Where_to_listen.of_port port)
      handler
  in
  Deferred.never ()
;;

let () =
  let module Command = Async_command in
  Command.async_spec
    ~summary:"Start a hello world Async server"
    Command.Spec.(
      empty
      +> flag
           "-p"
           (optional_with_default 8080 int)
           ~doc:"int Source port to listen on")
    start_server
  |> Command_unix.run
;;
