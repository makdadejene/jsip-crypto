open! Core
open! Crypto_src
open! Crypto_src.Types.Crypto
module Gp = Gnuplot

let () = Command_unix.run Visualize_graph.command

(* let _bitcoin_data = Fetch_data.get_minute_data Bitcoin *)

(* let _ethereum_data = Fetch_data.get_data Ethereum let _xrp_data =
   Fetch_data.get_data XRP;; let _mvg = Moving_average.get_moving_avgs
   _bitcoin_data 5;; *)

(* print_s [%message(mvg: (float list))] *)
