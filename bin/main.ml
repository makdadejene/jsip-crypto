open! Core
open! Crypto_src
open! Crypto_src.Types.Crypto
module Gp = Gnuplot

let () = Command_unix.run Visualize_graph.command