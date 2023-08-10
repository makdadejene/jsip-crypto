open! Core
open! Jsonaf
open! Async_kernel
open! Crypto_src.Types
open Jsonaf.Export
module Server = Cohttp_async.Server

type data =
  { date : string
  ; price : float
  }
[@@deriving jsonaf]

type t =
  { real_data : data array
  ; pred_data : data array
  }
[@@deriving jsonaf]

let crypto_table = Hashtbl.create (module Crypto)

let handler ~body:_ _sock req =
  let uri = Cohttp.Request.uri req in
  let request = Uri.path uri |> String.split ~on:'/' in
  match request with
  | [ _; "api"; coin ] ->
    let response =
      Crypto_interface.predict_all_prices crypto_table coin ()
    in
    let second_response = Crypto_interface.get_coin_data crypto_table coin in
    let pred_data =
      Array.map response ~f:(fun (date, price) -> { date; price })
    in
    let real_data =
      Array.map second_response ~f:(fun (date, price) -> { date; price })
    in
    let json_response =
      { real_data; pred_data } |> jsonaf_of_t |> to_string
    in
    Server.respond_string json_response
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
  Crypto_interface.init crypto_table;
  Deferred.never ()
;;
