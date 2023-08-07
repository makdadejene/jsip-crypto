open! Core
open! Crypto_src
open! Crypto_src.Types.Crypto
open! Interface_lib
module Gp = Gnuplot

let () = Command_unix.run Visualize_graph.command

let url_response =
  Interface_lib.Cohttp_server.handle
    "http://ec2-44-196-240-247.compute-1.amazonaws.com:8181/bitcoin/30"
;;

print_s [%message (url_response : string)]
