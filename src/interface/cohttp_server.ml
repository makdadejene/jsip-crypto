open! Core
open! Jsonaf_kernel
open! Async_kernel
open! Crypto_src.Types
module Server = Cohttp_async.Server

let crypto_table = Hashtbl.create (module Crypto)

let handler ~body:_ _sock req =
  let uri = Cohttp.Request.uri req in
  let request = Uri.path uri |> String.split ~on:'/' in
  match request with
  | [ _; _; _; coin; window ] ->
    let response =
      Crypto_interface.predict_all_prices crypto_table coin window
    in
    let dates, prices =
      ( Array.map response ~f:(fun data_tuple ->
          Jsonaf.of_string (fst data_tuple) |> Jsonaf.jsonaf_of_t)
      , Array.map response ~f:(fun data_tuple ->
          Jsonaf.of_string (Float.to_string (snd data_tuple))
          |> Jsonaf.jsonaf_of_t) )
    in
    let dates = `Array (dates |> Array.to_list) in
    let prices = `Array (prices |> Array.to_list) in
    let response =
      `Array [ dates; prices ] |> Jsonaf.jsonaf_of_t |> Jsonaf.to_string
    in
    Server.respond_string response
  | _ -> Server.respond_string ~status:`Not_found "Route not found"
;;

let handle url =
  let crypto_table = Hashtbl.create (module Crypto) in
  Crypto_interface.init crypto_table;
  let request = url |> String.split ~on:'/' in
  print_s [%message (request : string list)];
  match request with
  | [ _; _; _; coin; window ] ->
    let response =
      Crypto_interface.predict_all_prices crypto_table coin window
    in
    let dates, prices =
      ( Array.map response ~f:(fun data_tuple ->
          Jsonaf.of_string (fst data_tuple) |> Jsonaf.jsonaf_of_t)
      , Array.map response ~f:(fun data_tuple ->
          Jsonaf.of_string (Float.to_string (snd data_tuple))
          |> Jsonaf.jsonaf_of_t) )
    in
    let dates = `Array (dates |> Array.to_list) in
    let prices = `Array (prices |> Array.to_list) in
    let response =
      `Array [ dates; prices ] |> Jsonaf.jsonaf_of_t |> Jsonaf.to_string
    in
    print_s [%message (response : string)];
    response
  | _ -> "Server.respond_string ~status:`Not_found"
;;

let%expect_test "check_response" =
  let url_response =
    handle
      "http://ec2-44-196-240-247.compute-1.amazonaws.com:8181/bitcoin/30"
  in
  print_s [%message (url_response : string)];
  [%expect {|(url_response((1,2,3|}]
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
