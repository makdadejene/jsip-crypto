open! Core
open! Crypto_src
open! Crypto_src.Types.Crypto
open! Interface_lib
module Gp = Gnuplot

(* let () = Command_unix.run Visualize_graph.command *)

(* let test_table = Hashtbl.create (module Types.Crypto);;

   Interface_lib.Crypto_interface.init test_table;

   let _url_response = Interface_lib.Cohttp_server.handle
   "http://ec2-44-196-240-247.compute-1.amazonaws.com:8181/bitcoin/30"
   test_table ;; *)

(* print_s [%message (url_response : string)] *)

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
    Interface_lib.Cohttp_server.start_server
  |> Command_unix.run
;;
