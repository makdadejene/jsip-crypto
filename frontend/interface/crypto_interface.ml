open! Core
open! Owl_base
open! Crypto_src
open! Crypto_src.Types
open! Crypto_src.Simple_model
module Gp = Gnuplot

let init crypto_table =
  let all_coins = Crypto.all in
  List.iter all_coins ~f:(fun coin ->
    let coin_model = Simple_model.ArimaModel.create coin () in
    Hashtbl.set crypto_table ~key:coin ~data:coin_model)
;;

let get_coin_data crypto_table coin =
  let coin =
    match coin with
    | "bitcoin" -> Crypto.Bitcoin
    | "ethereum" -> Crypto.Ethereum
    | "xrp" -> Crypto.XRP
    | _ -> failwith "That is not a valid coin"
  in
  let model = Hashtbl.find_exn crypto_table coin in
  Simple_model.ArimaModel.data_graph_points model
;;

let predict_all_prices crypto_table coin window_size =
  let coin =
    match coin with
    | "bitcoin" -> Crypto.Bitcoin
    | "ethereum" -> Crypto.Ethereum
    | "xrp" -> Crypto.XRP
    | _ -> failwith "That is not a valid coin"
  in
  let window_size = int_of_string window_size in
  let model = Hashtbl.find_exn crypto_table coin in
  Simple_model.ArimaModel.predict_all_prices model window_size;
  Simple_model.ArimaModel.predictions_graph_points model
;;

(* let update data = data;; *)
